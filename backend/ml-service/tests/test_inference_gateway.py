"""Tiny ARM-staging Flask interface must require an internal token."""
import pytest
from app_inference import app


@pytest.fixture
def client(monkeypatch):
    monkeypatch.setenv("ML_INTERNAL_TOKEN", "test-token-for-ci-only")
    app.config["TESTING"] = True
    return app.test_client()


def test_health_does_not_expose_private_configuration(client):
    result = client.get("/health")
    assert result.status_code == 200
    assert result.json["status"] == "healthy"
    assert "ML_INTERNAL_TOKEN" not in str(result.json)


def test_internal_status_is_auth_gated(client):
    assert client.get("/api/v1/status").status_code == 401
    result = client.get("/api/v1/status", headers={"Authorization": "Bearer test-token-for-ci-only"})
    assert result.status_code == 200
    assert result.json["model_available"] is False


def test_no_model_does_not_fabricate_detection(client):
    result = client.post("/api/v1/threats/detect",
                         headers={"Authorization": "Bearer test-token-for-ci-only"},
                         json={"network": {"connection_count": 95}})
    assert result.status_code == 503
    assert result.json["detection"]["status"] == "unavailable"
    assert result.json["detection"]["threat_detected"] is False


def test_invalid_telemetry_is_rejected(client):
    result = client.post("/api/v1/threats/detect",
                         headers={"Authorization": "Bearer test-token-for-ci-only"},
                         json={"network": {"connection_count": "not a number"}})
    assert result.status_code == 422


def test_document_ingest_and_offensive_routes_are_absent(client):
    token = {"Authorization": "Bearer test-token-for-ci-only"}
    assert client.post("/api/v1/documents/process", json={}, headers=token).status_code == 404
    assert client.post("/api/v1/war/attack", json={}, headers=token).status_code == 404
