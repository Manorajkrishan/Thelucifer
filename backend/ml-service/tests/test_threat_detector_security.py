"""Inference regressions: no model or broken model must never become a threat."""
import numpy as np
import pytest

from services.threat_detector import ThreatDetector


class StubModel:
    n_features_in_ = len(ThreatDetector.FEATURE_FIELDS)

    def __init__(self, result):
        self.result = result
        self.seen = None

    def predict(self, features):
        self.seen = features.copy()
        return np.asarray([self.result])


def test_missing_model_does_not_raise_an_alert(monkeypatch):
    monkeypatch.delenv("THREAT_MODEL_PATH", raising=False)
    detector = ThreatDetector()
    response = detector.detect_threat({"network": {"connection_count": 90}})
    assert response["status"] == "unavailable"
    assert response["threat_detected"] is False


def test_sparse_telemetry_has_stable_feature_shape(monkeypatch):
    monkeypatch.delenv("THREAT_MODEL_PATH", raising=False)
    detector = ThreatDetector()
    model = StubModel(1)
    detector.model = model
    response = detector.detect_threat({"network": {"connection_count": 2}})
    assert response["status"] == "ok"
    assert response["threat_detected"] is False
    assert model.seen.shape == (1, len(ThreatDetector.FEATURE_FIELDS))
    assert model.seen[0, 2] == 2
    assert model.seen[0, -1] == 0


def test_anomaly_from_model_can_be_reported(monkeypatch):
    monkeypatch.delenv("THREAT_MODEL_PATH", raising=False)
    detector = ThreatDetector()
    detector.model = StubModel(-1)
    result = detector.detect_threat({"network": {"connection_count": 80}})
    assert result["status"] == "ok"
    assert result["threat_detected"] is True
    assert result["confidence_source"] == "heuristic_not_calibrated"


def test_bad_input_is_not_a_detection(monkeypatch):
    monkeypatch.delenv("THREAT_MODEL_PATH", raising=False)
    detector = ThreatDetector()
    for data in ({}, {"network": {"connection_count": -4}}, {"network": {"connection_count": "many"}}, {"network": {"packet_count": float("nan")}}):
        result = detector.detect_threat(data)
        assert result["status"] == "invalid_input"
        assert result["threat_detected"] is False


def test_model_failure_is_unavailable_not_anomaly(monkeypatch):
    monkeypatch.delenv("THREAT_MODEL_PATH", raising=False)
    detector = ThreatDetector()
    class Broken:
        def predict(self, features):
            raise RuntimeError("broken model")
    detector.model = Broken()
    result = detector.detect_threat({"behavior": {"privilege_escalation": 2}})
    assert result["status"] == "unavailable"
    assert result["threat_detected"] is False
