"""Unit tests for KnowledgeGraphService (in-memory fallback)."""
import pytest

from services.knowledge_graph import KnowledgeGraphService


@pytest.fixture
def kg():
    """Knowledge graph with no Neo4j driver (in-memory only)."""
    return KnowledgeGraphService(driver=None)


def test_store_document_knowledge_in_memory(kg):
    data = {
        "text": "Sample document",
        "summary": "Summary",
        "attack_techniques": [
            {"technique": "SQL Injection", "context": "Web", "confidence": 0.9},
        ],
        "defense_strategies": [
            {"strategy": "Input validation", "context": "Prevent", "confidence": 0.85},
        ],
        "exploit_patterns": [],
    }
    assert kg.store_document_knowledge("doc1", data) is True


def test_query_knowledge_in_memory(kg):
    data = {
        "text": "Doc",
        "summary": "S",
        "attack_techniques": [{"technique": "XSS", "context": "Web", "confidence": 0.8}],
        "defense_strategies": [],
        "exploit_patterns": [],
    }
    kg.store_document_knowledge("d1", data)
    results = kg.query_knowledge("XSS")
    assert isinstance(results, list)
    assert len(results) >= 1


def test_get_attack_techniques_in_memory(kg):
    data = {
        "text": "T",
        "summary": "S",
        "attack_techniques": [{"technique": "Phishing", "context": "Email", "confidence": 0.7}],
        "defense_strategies": [],
        "exploit_patterns": [],
    }
    kg.store_document_knowledge("d2", data)
    tech = kg.get_attack_techniques(limit=10)
    assert isinstance(tech, list)


def test_create_threat_pattern_in_memory(kg):
    td = {"id": "tp1", "type": "malware", "severity": 8, "description": "Test", "related_techniques": []}
    assert kg.create_threat_pattern(td) is True
