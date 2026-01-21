"""
Threat Detection Engine
Detects and classifies cyber threats using ML models
"""

import logging
from typing import Dict, List, Any
import numpy as np
from sklearn.ensemble import IsolationForest
from sklearn.preprocessing import StandardScaler
import pickle
import os

logger = logging.getLogger(__name__)


class ThreatDetector:
    """Detect and classify cyber threats"""
    
    def __init__(self):
        self.models = {}
        self.scaler = StandardScaler()
        
        # Initialize anomaly detection model
        self.anomaly_detector = IsolationForest(contamination=0.1, random_state=42)
        
        # Threat type classifiers (can be loaded from trained models)
        self.threat_classifiers = {
            'malware': self._classify_malware,
            'trojan': self._classify_trojan,
            'ransomware': self._classify_ransomware,
            'phishing': self._classify_phishing,
            'zero_day': self._classify_zero_day,
        }
    
    def detect_threat(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Detect and classify cyber threats from input data
        
        Args:
            data: Input data containing network traffic, system logs, etc.
        
        Returns:
            Detection results with threat classification and confidence
        """
        try:
            features = self._extract_features(data)
            
            # Anomaly detection
            is_anomaly = self._detect_anomaly(features)
            
            if not is_anomaly:
                return {
                    'threat_detected': False,
                    'confidence': 0.0,
                    'classification': None
                }
            
            # Classify threat type
            classification_result = self._classify_threat(data, features)
            
            # Calculate severity
            severity = self._calculate_severity(data, classification_result)
            
            return {
                'threat_detected': True,
                'classification': classification_result['type'],
                'confidence': classification_result['confidence'],
                'severity': severity,
                'description': classification_result['description'],
                'recommendations': classification_result.get('recommendations', [])
            }
            
        except Exception as e:
            logger.error(f"Error detecting threat: {str(e)}")
            raise
    
    def _extract_features(self, data: Dict[str, Any]) -> np.ndarray:
        """Extract features from input data for ML models"""
        features = []
        
        # Network traffic features
        if 'network' in data:
            network = data['network']
            features.extend([
                network.get('packet_count', 0),
                network.get('bytes_transferred', 0),
                network.get('connection_count', 0),
                network.get('port_count', 0),
            ])
        
        # System log features
        if 'system_logs' in data:
            logs = data['system_logs']
            features.extend([
                len(logs.get('error_logs', [])),
                len(logs.get('warning_logs', [])),
                logs.get('process_count', 0),
                logs.get('file_access_count', 0),
            ])
        
        # Behavioral features
        if 'behavior' in data:
            behavior = data['behavior']
            features.extend([
                behavior.get('suspicious_file_access', 0),
                behavior.get('unusual_network_activity', 0),
                behavior.get('privilege_escalation', 0),
            ])
        
        # If no features extracted, return zeros
        if not features:
            features = [0] * 11
        
        return np.array(features).reshape(1, -1)
    
    def _detect_anomaly(self, features: np.ndarray) -> bool:
        """Detect if the features represent an anomaly"""
        try:
            # Normalize features
            features_scaled = self.scaler.fit_transform(features)
            
            # Predict anomaly
            prediction = self.anomaly_detector.predict(features_scaled)
            
            # -1 means anomaly, 1 means normal
            return prediction[0] == -1
            
        except Exception as e:
            logger.warning(f"Error in anomaly detection: {e}")
            return True  # Assume anomaly if detection fails
    
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
