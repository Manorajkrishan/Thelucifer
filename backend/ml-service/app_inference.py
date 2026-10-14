"""Minimal private-only ML inference gateway for ARM64 staging.

This process does NOT offer ingestion, dataset downloading, counteroffensive
operations, scheduled learning, model training or arbitrary file access.
Without a validated THREAT_MODEL_PATH, inference intentionally returns 503.
"""
import os

from flask import Flask, jsonify, request
from security import internal_api_error
from services.threat_detector import ThreatDetector

app = Flask(__name__)
app.config["MAX_CONTENT_LENGTH"] = 32768

# Loaded only by the operator's static, controlled deployment configuration.
detector = ThreatDetector()


@app.get("/health")
def health():
    return jsonify({
        "status": "healthy",
        "service": "Lucifer staging ML inference",
        "model_available": detector.model is not None,
    })


@app.before_request
def require_internal_auth():
    if request.method == "GET" and request.path == "/health":
        return None
    error = internal_api_error()
    if error:
        reason, status = error
        return jsonify({"success": False, "error": reason}), status
    return None


@app.get("/api/v1/status")
def internal_status():
    return jsonify({
        "success": True,
        "service": "Lucifer inference staging",
        "model_available": detector.model is not None,
    })


@app.post("/api/v1/threats/detect")
def detect():
    data = request.get_json(silent=True)
    if not isinstance(data, dict):
        return jsonify({"success": False, "error": "JSON object required"}), 422
    result = detector.detect_threat(data)
    status = result.get("status")
    code = 503 if status == "unavailable" else 422 if status == "invalid_input" else 200
    return jsonify({"success": status == "ok", "detection": result}), code
