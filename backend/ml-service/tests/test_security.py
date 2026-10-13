"""Test internal authentication and file path confinement without the full ML stack."""
from pathlib import Path

from flask import Flask
import pytest

from security import internal_api_error, trusted_document_path


def test_unconfigured_internal_auth_fails_closed(monkeypatch):
    monkeypatch.delenv("ML_INTERNAL_TOKEN", raising=False)
    app = Flask(__name__)
    with app.test_request_context("/api/v1/threats/detect", method="POST"):
        assert internal_api_error() == ("internal_auth_not_configured", 503)


def test_internal_bearer_token(monkeypatch):
    monkeypatch.setenv("ML_INTERNAL_TOKEN", "a-test-secret-only")
    app = Flask(__name__)
    with app.test_request_context("/api/v1/threats/detect", method="POST"):
        assert internal_api_error() == ("unauthorized", 401)
    with app.test_request_context("/api/v1/threats/detect", method="POST", headers={"Authorization": "Bearer wrong"}):
        assert internal_api_error() == ("unauthorized", 401)
    with app.test_request_context("/api/v1/threats/detect", method="POST", headers={"Authorization": "Bearer a-test-secret-only"}):
        assert internal_api_error() is None


def test_documents_cannot_escape_ingest_root(monkeypatch, tmp_path):
    root = tmp_path / "ingest"
    root.mkdir()
    good = root / "normal.txt"
    good.write_text("safe")
    bad = tmp_path / "outside.txt"
    bad.write_text("private")
    monkeypatch.setenv("ML_DOCUMENT_ROOT", str(root))
    assert trusted_document_path("normal.txt") == str(good.resolve())
    with pytest.raises(ValueError):
        trusted_document_path("../outside.txt")
    link = root / "escape.txt"
    link.symlink_to(bad)
    with pytest.raises(ValueError):
        trusted_document_path("escape.txt")
