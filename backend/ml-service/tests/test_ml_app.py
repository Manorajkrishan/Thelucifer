"""Flask app integration tests. Require ml-service running or mocked Redis/Neo4j."""
import os
import sys

import pytest

# Avoid importing app until we optionally mock deps
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, ROOT)


@pytest.fixture
def client():
    """Flask test client. Skips if app fails to import (e.g. Redis/Neo4j down)."""
    try:
        from app import app
    except Exception as e:
        pytest.skip(f"App import failed (Redis/Neo4j?): {e}")
    app.config["TESTING"] = True
    return app.test_client()


def test_health(client):
    r = client.get("/health")
    assert r.status_code == 200
    data = r.get_json()
    assert data["status"] == "healthy"
    assert data["service"] == "ML Service"


def test_datasets_available(client):
    r = client.get("/api/v1/datasets?type=available")
    assert r.status_code == 200
    data = r.get_json()
    assert data["success"] is True
    assert "datasets" in data
    assert "cicids2017" in data["datasets"]


def test_knowledge_status(client):
    r = client.get("/api/v1/knowledge/status")
    assert r.status_code == 200
    data = r.get_json()
    assert data["success"] is True
    assert "neo4j" in data
    assert data["backend"] in ("neo4j", "in-memory")
