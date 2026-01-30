"""
Knowledge Graph Service
Manages cybersecurity knowledge in Neo4j graph database.
Fully wired: uses Neo4j when available; falls back to in-memory store when Neo4j is down.
"""

import logging
from typing import Dict, List, Any, Optional, TYPE_CHECKING

if TYPE_CHECKING:
    from neo4j import Driver

logger = logging.getLogger(__name__)


class KnowledgeGraphService:
    """Manage cybersecurity knowledge graph in Neo4j with in-memory fallback"""

    def __init__(self, driver: Optional["Driver"] = None):
        self.driver = driver
        self._memory_docs: List[Dict[str, Any]] = []
        self._memory_techniques: List[Dict[str, Any]] = []
        self._memory_strategies: List[Dict[str, Any]] = []
        self._memory_patterns: List[Dict[str, Any]] = []

    def _store_memory(self, document_id: str, extracted_data: Dict[str, Any]) -> None:
        """Store extracted knowledge in-memory (fallback when Neo4j unavailable)."""
        title = (extracted_data.get("text") or "")[:100]
        summary = extracted_data.get("summary") or ""
        self._memory_docs.append({"id": document_id, "title": title, "summary": summary})
        for t in extracted_data.get("attack_techniques", []):
            self._memory_techniques.append({
                "name": t.get("technique", ""),
                "description": t.get("context", ""),
                "confidence": t.get("confidence", 0.0),
                "document_id": document_id,
            })
        for s in extracted_data.get("defense_strategies", []):
            self._memory_strategies.append({
                "name": s.get("strategy", ""),
                "description": s.get("context", ""),
                "confidence": s.get("confidence", 0.0),
                "document_id": document_id,
            })

    def store_document_knowledge(self, document_id: str, extracted_data: Dict[str, Any]) -> bool:
        """
        Store extracted knowledge from document into Neo4j graph.
        Falls back to in-memory store if Neo4j is unavailable.
        """
        if self.driver:
            try:
                with self.driver.session() as session:
                    title = (extracted_data.get("text") or "")[:100]
                    summary = extracted_data.get("summary") or ""
                    session.run(
                        """
                        MERGE (d:Document {id: $document_id})
                        SET d.title = $title,
                            d.processed_at = datetime(),
                            d.summary = $summary
                        """,
                        document_id=document_id,
                        title=title,
                        summary=summary,
                    )
                    for technique in extracted_data.get("attack_techniques", []):
                        session.run(
                            """
                            MATCH (d:Document {id: $document_id})
                            MERGE (t:AttackTechnique {name: $technique_name})
                            SET t.description = $description,
                                t.confidence = $confidence
                            MERGE (d)-[:DESCRIBES]->(t)
                            """,
                            document_id=document_id,
                            technique_name=technique.get("technique", ""),
                            description=technique.get("context", ""),
                            confidence=technique.get("confidence", 0.0),
                        )
                    for pattern in extracted_data.get("exploit_patterns", []):
                        session.run(
                            """
                            MATCH (d:Document {id: $document_id})
                            MERGE (p:ExploitPattern {identifier: $identifier})
                            SET p.type = $type,
                                p.confidence = $confidence
                            MERGE (d)-[:CONTAINS]->(p)
                            """,
                            document_id=document_id,
                            identifier=pattern.get("identifier", ""),
                            type=pattern.get("type", ""),
                            confidence=pattern.get("confidence", 0.0),
                        )
                    for strategy in extracted_data.get("defense_strategies", []):
                        session.run(
                            """
                            MATCH (d:Document {id: $document_id})
                            MERGE (s:DefenseStrategy {name: $strategy_name})
                            SET s.description = $description,
                                s.confidence = $confidence
                            MERGE (d)-[:RECOMMENDS]->(s)
                            """,
                            document_id=document_id,
                            strategy_name=strategy.get("strategy", ""),
                            description=strategy.get("context", ""),
                            confidence=strategy.get("confidence", 0.0),
                        )
                    # Link techniques and strategies for this document only
                    session.run(
                        """
                        MATCH (d:Document {id: $document_id})-[:DESCRIBES]->(t:AttackTechnique)
                        MATCH (d)-[:RECOMMENDS]->(s:DefenseStrategy)
                        MERGE (s)-[:COUNTERS]->(t)
                        """,
                        document_id=document_id,
                    )
                logger.info(f"Stored knowledge for document {document_id} in Neo4j")
                return True
            except Exception as e:
                logger.warning(f"Neo4j store failed, using in-memory fallback: {e}")
        self._store_memory(document_id, extracted_data)
        return True

    def query_knowledge(self, query: str) -> List[Dict[str, Any]]:
        """Query the knowledge graph. Uses Neo4j or in-memory fallback."""
        q = (query or "").strip().lower()
        if self.driver:
            try:
                with self.driver.session() as session:
                    result = session.run(
                        """
                        MATCH (n)
                        WHERE (n.name IS NOT NULL AND toLower(toString(n.name)) CONTAINS $query)
                           OR (n.description IS NOT NULL AND toLower(toString(n.description)) CONTAINS $query)
                           OR (n.identifier IS NOT NULL AND toLower(toString(n.identifier)) CONTAINS $query)
                        RETURN n, labels(n) as labels
                        LIMIT 50
                        """,
                        query=q,
                    )
                    out = []
                    for record in result:
                        node = dict(record["n"])
                        node["labels"] = list(record["labels"])
                        out.append(node)
                    return out
            except Exception as e:
                logger.warning(f"Neo4j query failed, using in-memory: {e}")
        out = []
        for t in self._memory_techniques:
            if q in (t.get("name") or "").lower() or q in (t.get("description") or "").lower():
                out.append({**t, "labels": ["AttackTechnique"]})
        for s in self._memory_strategies:
            if q in (s.get("name") or "").lower() or q in (s.get("description") or "").lower():
                out.append({**s, "labels": ["DefenseStrategy"]})
        return out[:50]

    def get_attack_techniques(self, limit: int = 20) -> List[Dict[str, Any]]:
        """Get all attack techniques from knowledge graph."""
        if self.driver:
            try:
                with self.driver.session() as session:
                    result = session.run(
                        """
                        MATCH (t:AttackTechnique)
                        RETURN t
                        ORDER BY t.confidence DESC
                        LIMIT $limit
                        """,
                        limit=limit,
                    )
                    return [dict(record["t"]) for record in result]
            except Exception as e:
                logger.warning(f"Neo4j get_attack_techniques failed: {e}")
        tech = sorted(self._memory_techniques, key=lambda x: -float(x.get("confidence", 0)))
        return tech[:limit]

    def get_defense_strategies(self, technique_name: Optional[str] = None) -> List[Dict[str, Any]]:
        """Get defense strategies, optionally filtered by attack technique."""
        if self.driver:
            try:
                with self.driver.session() as session:
                    if technique_name:
                        result = session.run(
                            """
                            MATCH (t:AttackTechnique {name: $technique_name})<-[:COUNTERS]-(s:DefenseStrategy)
                            RETURN s
                            """,
                            technique_name=technique_name,
                        )
                    else:
                        result = session.run(
                            """
                            MATCH (s:DefenseStrategy)
                            RETURN s
                            LIMIT 50
                            """
                        )
                    return [dict(record["s"]) for record in result]
            except Exception as e:
                logger.warning(f"Neo4j get_defense_strategies failed: {e}")
        if technique_name:
            return [s for s in self._memory_strategies if s.get("document_id") in {
                t.get("document_id") for t in self._memory_techniques
                if (t.get("name") or "").lower() == (technique_name or "").lower()
            }]
        return self._memory_strategies[:50]

    def create_threat_pattern(self, threat_data: Dict[str, Any]) -> bool:
        """Create a threat pattern node in the knowledge graph."""
        self._memory_patterns.append({
            "id": threat_data.get("id"),
            "type": threat_data.get("type"),
            "severity": threat_data.get("severity"),
            "description": threat_data.get("description"),
        })
        if self.driver:
            try:
                with self.driver.session() as session:
                    session.run(
                        """
                        MERGE (tp:ThreatPattern {id: $id})
                        SET tp.type = $type,
                            tp.severity = $severity,
                            tp.description = $description,
                            tp.detected_at = datetime()
                        """,
                        id=threat_data.get("id"),
                        type=threat_data.get("type"),
                        severity=threat_data.get("severity"),
                        description=threat_data.get("description") or "",
                    )
                    for technique_name in threat_data.get("related_techniques", []):
                        session.run(
                            """
                            MATCH (tp:ThreatPattern {id: $pattern_id})
                            MATCH (t:AttackTechnique {name: $technique_name})
                            MERGE (tp)-[:USES]->(t)
                            """,
                            pattern_id=threat_data.get("id"),
                            technique_name=technique_name,
                        )
                return True
            except Exception as e:
                logger.warning(f"Neo4j create_threat_pattern failed: {e}")
        return True
