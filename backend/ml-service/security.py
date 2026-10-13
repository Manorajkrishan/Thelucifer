"""Minimal fail-closed authentication and trusted document path validation."""
import hmac
import os
from pathlib import Path

from flask import request


def internal_api_error():
    """Return (message, http_status) or None. Internal endpoints are never public."""
    configured = os.getenv("ML_INTERNAL_TOKEN", "")
    if not configured:
        return "internal_auth_not_configured", 503
    supplied = request.headers.get("Authorization", "")
    expected = "Bearer " + configured
    if not hmac.compare_digest(supplied.encode("utf-8"), expected.encode("utf-8")):
        return "unauthorized", 401
    return None


def trusted_document_path(relative_path):
    """Only read files inside an explicitly configured, read-only ingest directory."""
    root = os.getenv("ML_DOCUMENT_ROOT", "")
    if not root:
        raise ValueError("document_root_not_configured")
    if not isinstance(relative_path, str) or not relative_path:
        raise ValueError("invalid_document_path")
    base = Path(root).resolve(strict=True)
    candidate = (base / relative_path).resolve(strict=True)
    if not candidate.is_relative_to(base) or not candidate.is_file():
        raise ValueError("document_path_outside_trusted_root")
    return str(candidate)
