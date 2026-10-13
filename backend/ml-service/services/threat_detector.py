"""
Threat detection: fail closed when a trained and trusted model is unavailable.

A deployment must explicitly provision a trusted, versioned scikit-learn pipeline
artifact. Never load a model from user input, URLs, or uploaded documents.
"""
import logging
import os
from pathlib import Path
from typing import Dict, Any

import joblib
import numpy as np

logger = logging.getLogger(__name__)


class ThreatDetector:
    """Inference-only anomaly detector. Training and model promotion are separate."""

    FEATURE_FIELDS = (
        ("network", "packet_count"),
        ("network", "bytes_transferred"),
        ("network", "connection_count"),
        ("network", "port_count"),
        ("system_logs", "process_count"),
        ("system_logs", "file_access_count"),
        ("behavior", "suspicious_file_access"),
        ("behavior", "unusual_network_activity"),
        ("behavior", "privilege_escalation"),
    )

    def __init__(self, model_path=None):
        self.model = None
        self.model_path = model_path if model_path is not None else os.getenv("THREAT_MODEL_PATH", "")
        if self.model_path:
            self._load_model(self.model_path)
        self.threat_classifiers = {
            "malware": self._classify_malware,
            "trojan": self._classify_trojan,
            "ransomware": self._classify_ransomware,
            "phishing": self._classify_phishing,
            "zero_day": self._classify_zero_day,
        }

    def _load_model(self, path):
        """Only deployer-controlled model artifacts may be deserialized."""
        try:
            model_file = Path(path)
            if not model_file.is_file():
                logger.error("Configured threat model does not exist")
                return
            model = joblib.load(model_file)
            if not callable(getattr(model, "predict", None)):
                logger.error("Configured threat model does not expose predict")
                return
            if getattr(model, "n_features_in_", len(self.FEATURE_FIELDS)) != len(self.FEATURE_FIELDS):
                logger.error("Configured threat model has the wrong feature dimension")
                return
            self.model = model
        except Exception:
            logger.exception("Unable to load configured threat model")

    def _extract_features(self, data: Dict[str, Any]) -> np.ndarray:
        if not isinstance(data, dict) or not any(
            isinstance(data.get(group), dict) for group, _ in self.FEATURE_FIELDS
        ):
            raise ValueError("At least one supported telemetry object is required")
        features = []
        for group, field in self.FEATURE_FIELDS:
            raw = data.get(group, {})
            if raw is None:
                raw = {}
            if not isinstance(raw, dict):
                raise ValueError(f"{group} must be an object")
            value = raw.get(field, 0)
            if isinstance(value, bool) or not isinstance(value, (int, float)):
                raise ValueError(f"{group}.{field} must be numeric")
            if not np.isfinite(value) or value < 0:
                raise ValueError(f"{group}.{field} must be finite and non-negative")
            features.append(float(value))
        return np.asarray([features], dtype=np.float64)

    def _detect_anomaly(self, features: np.ndarray) -> bool:
        if self.model is None:
            raise RuntimeError("threat_model_unavailable")
        prediction = self.model.predict(features)
        if len(prediction) != 1 or prediction[0] not in (-1, 1):
            raise RuntimeError("invalid_model_prediction")
        return bool(prediction[0] == -1)

    def detect_threat(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Never report detection on invalid data or inference failures."""
        try:
            features = self._extract_features(data)
        except (ValueError, TypeError, OverflowError) as exc:
            return {
                "status": "invalid_input", "threat_detected": False,
                "confidence": None, "reason": str(exc),
            }
        try:
            is_anomaly = self._detect_anomaly(features)
        except Exception:
            logger.exception("Threat inference unavailable")
            return {
                "status": "unavailable", "threat_detected": False,
                "confidence": None, "reason": "model_inference_unavailable",
            }
        if not is_anomaly:
            return {"status": "ok", "threat_detected": False, "confidence": 0.0, "classification": None}
        classification = self._classify_threat(data, features)
        return {
            "status": "ok", "threat_detected": True,
            "classification": classification["type"],
            "confidence": classification["confidence"],
            "confidence_source": "heuristic_not_calibrated",
            "severity": self._calculate_severity(data, classification),
            "description": classification["description"],
            "recommendations": classification.get("recommendations", []),
        }

    def _classify_threat(self, data: Dict[str, Any], features: np.ndarray) -> Dict[str, Any]:
        """Classify the type of threat"""
        results = []
        
        for threat_type, classifier_func in self.threat_classifiers.items():
            result = classifier_func(data, features)
            if result['detected']:
                results.append(result)
        
        if not results:
            return {
                'type': 'unknown',
                'confidence': 0.5,
                'description': 'Unknown threat type detected',
                'detected': True
            }
        
        # Return the highest confidence result
        best_result = max(results, key=lambda x: x['confidence'])
        return best_result
    
    def _classify_malware(self, data: Dict[str, Any], features: np.ndarray) -> Dict[str, Any]:
        """Classify malware threats"""
        # Simple rule-based classification (can be replaced with trained ML model)
        suspicious_indicators = 0
        
        if data.get('behavior', {}).get('suspicious_file_access', 0) > 10:
            suspicious_indicators += 1
        
        if data.get('network', {}).get('connection_count', 0) > 50:
            suspicious_indicators += 1
        
        confidence = min(0.9, 0.5 + (suspicious_indicators * 0.2))
        
        return {
            'type': 'malware',
            'confidence': confidence,
            'description': 'Malicious software detected',
            'detected': suspicious_indicators > 0,
            'recommendations': [
                'Isolate affected system',
                'Run antivirus scan',
                'Review system logs'
            ]
        }
    
    def _classify_trojan(self, data: Dict[str, Any], features: np.ndarray) -> Dict[str, Any]:
        """Classify trojan threats"""
        # Check for trojan-like behavior
        has_remote_access = data.get('behavior', {}).get('unusual_network_activity', 0) > 5
        has_backdoor = data.get('behavior', {}).get('privilege_escalation', 0) > 0
        
        detected = has_remote_access or has_backdoor
        confidence = 0.75 if detected else 0.0
        
        return {
            'type': 'trojan',
            'confidence': confidence,
            'description': 'Trojan horse detected',
            'detected': detected,
            'recommendations': [
                'Block network connections',
                'Remove suspicious files',
                'Change credentials'
            ]
        }
    
    def _classify_ransomware(self, data: Dict[str, Any], features: np.ndarray) -> Dict[str, Any]:
        """Classify ransomware threats"""
        # Check for ransomware indicators
        file_encryption = data.get('behavior', {}).get('suspicious_file_access', 0) > 20
        unusual_activity = data.get('behavior', {}).get('unusual_network_activity', 0) > 3
        
        detected = file_encryption and unusual_activity
        confidence = 0.85 if detected else 0.0
        
        return {
            'type': 'ransomware',
            'confidence': confidence,
            'description': 'Ransomware activity detected',
            'detected': detected,
            'recommendations': [
                'Disconnect from network immediately',
                'Check for encrypted files',
                'Review backup integrity',
                'Contact incident response team'
            ]
        }
    
    def _classify_phishing(self, data: Dict[str, Any], features: np.ndarray) -> Dict[str, Any]:
        """Classify phishing threats"""
        # Check for phishing indicators
        suspicious_emails = data.get('email', {}).get('suspicious_count', 0) > 0
        suspicious_links = data.get('email', {}).get('suspicious_links', 0) > 0
        
        detected = suspicious_emails or suspicious_links
        confidence = 0.7 if detected else 0.0
        
        return {
            'type': 'phishing',
            'confidence': confidence,
            'description': 'Phishing attempt detected',
            'detected': detected,
            'recommendations': [
                'Block suspicious senders',
                'Educate users',
                'Review email logs'
            ]
        }
    
    def _classify_zero_day(self, data: Dict[str, Any], features: np.ndarray) -> Dict[str, Any]:
        """Classify zero-day exploits"""
        # Zero-day detection is more complex, requires advanced behavioral analysis
        unknown_signatures = data.get('behavior', {}).get('unknown_processes', 0) > 5
        unusual_patterns = data.get('behavior', {}).get('unusual_network_activity', 0) > 10
        
        detected = unknown_signatures and unusual_patterns
        confidence = 0.6 if detected else 0.0  # Lower confidence for zero-day
        
        return {
            'type': 'zero_day',
            'confidence': confidence,
            'description': 'Possible zero-day exploit detected',
            'detected': detected,
            'recommendations': [
                'Isolate affected systems',
                'Capture forensic evidence',
                'Report to security team',
                'Monitor for new signatures'
            ]
        }
    
    def _calculate_severity(self, data: Dict[str, Any], classification: Dict[str, Any]) -> int:
        """Calculate threat severity (1-10 scale)"""
        base_severity = {
            'malware': 5,
            'trojan': 6,
            'ransomware': 9,
            'phishing': 4,
            'zero_day': 8,
            'unknown': 5,
        }
        
        severity = base_severity.get(classification['type'], 5)
        
        # Adjust based on confidence
        if classification['confidence'] > 0.8:
            severity += 1
        elif classification['confidence'] < 0.5:
            severity -= 1
        
        # Ensure severity is within 1-10 range
        return max(1, min(10, severity))
