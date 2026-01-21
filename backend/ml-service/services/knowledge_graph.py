"""
Knowledge Graph Service
Manages cybersecurity knowledge in Neo4j graph database
"""

import logging
from typing import Dict, List, Any, Optional
from neo4j import GraphDatabase, Driver

logger = logging.getLogger(__name__)


class KnowledgeGraphService:
    """Manage cybersecurity knowledge graph in Neo4j"""
    
    def __init__(self, driver: Driver):
        self.driver = driver
    
    def store_document_knowledge(self, document_id: str, extracted_data: Dict[str, Any]) -> bool:
        """
        Store extracted knowledge from document into Neo4j graph
        
        Args:
            document_id: Unique identifier for the document
            extracted_data: Extracted knowledge data
        
        Returns:
            True if successful, False otherwise
        """
        try:
            with self.driver.session() as session:
                # Create document node
                session.run(
                    """
                    MERGE (d:Document {id: $document_id})
                    SET d.title = $title,
                        d.processed_at = datetime(),
                        d.summary = $summary
                    """,
                    document_id=document_id,
                    title=extracted_data.get('text', '')[:100],
                    summary=extracted_data.get('summary', '')
                )
                
                # Store attack techniques
                for technique in extracted_data.get('attack_techniques', []):
                    session.run(
                        """
                        MATCH (d:Document {id: $document_id})
                        MERGE (t:AttackTechnique {name: $technique_name})
                        SET t.description = $description,
                            t.confidence = $confidence
                        MERGE (d)-[:DESCRIBES]->(t)
                        """,
                        document_id=document_id,
                        technique_name=technique.get('technique', ''),
                        description=technique.get('context', ''),
                        confidence=technique.get('confidence', 0.0)
                    )
                
                # Store exploit patterns
                for pattern in extracted_data.get('exploit_patterns', []):
                    session.run(
                        """
                        MATCH (d:Document {id: $document_id})
                        MERGE (p:ExploitPattern {identifier: $identifier})
                        SET p.type = $type,
                            p.confidence = $confidence
                        MERGE (d)-[:CONTAINS]->(p)
                        """,
                        document_id=document_id,
                        identifier=pattern.get('identifier', ''),
                        type=pattern.get('type', ''),
                        confidence=pattern.get('confidence', 0.0)
                    )
                
                # Store defense strategies
                for strategy in extracted_data.get('defense_strategies', []):
                    session.run(
                        """
                        MATCH (d:Document {id: $document_id})
                        MERGE (s:DefenseStrategy {name: $strategy_name})
                        SET s.description = $description,
                            s.confidence = $confidence
                        MERGE (d)-[:RECOMMENDS]->(s)
                        """,
                        document_id=document_id,
                        strategy_name=strategy.get('strategy', ''),
                        description=strategy.get('context', ''),
                        confidence=strategy.get('confidence', 0.0)
                    )
                
                # Create relationships between techniques and strategies
                session.run(
                    """
                    MATCH (t:AttackTechnique), (s:DefenseStrategy)
                    WHERE EXISTS {
                        MATCH (d:Document)-[:DESCRIBES]->(t)
                        MATCH (d)-[:RECOMMENDS]->(s)
                    }
                    MERGE (s)-[:COUNTERS]->(t)
                    """
                )
                
                logger.info(f"Successfully stored knowledge for document {document_id}")
                return True
                
        except Exception as e:
            logger.error(f"Error storing knowledge graph data: {str(e)}")
            return False
    
    def query_knowledge(self, query: str) -> List[Dict[str, Any]]:
        """
        Query the knowledge graph
        
        Args:
            query: Search query string
        
        Returns:
            List of matching knowledge entries
        """
        try:
            with self.driver.session() as session:
                # Simple text search across nodes
                result = session.run(
                    """
                    MATCH (n)
                    WHERE toLower(n.name) CONTAINS toLower($query)
                         OR toLower(n.description) CONTAINS toLower($query)
                         OR toLower(n.identifier) CONTAINS toLower($query)
                    RETURN n, labels(n) as labels
                    LIMIT 50
                    """,
                    query=query
                )
                
                results = []
                for record in result:
                    node = dict(record['n'])
                    node['labels'] = record['labels']
                    results.append(node)
                
                return results
                
        except Exception as e:
            logger.error(f"Error querying knowledge graph: {str(e)}")
            return []
    
    def get_attack_techniques(self, limit: int = 20) -> List[Dict[str, Any]]:
        """Get all attack techniques from knowledge graph"""
        try:
            with self.driver.session() as session:
                result = session.run(
                    """
                    MATCH (t:AttackTechnique)
                    RETURN t
                    ORDER BY t.confidence DESC
                    LIMIT $limit
                    """,
                    limit=limit
                )
                
                return [dict(record['t']) for record in result]
                
        except Exception as e:
            logger.error(f"Error getting attack techniques: {str(e)}")
            return []
    
    def get_defense_strategies(self, technique_name: Optional[str] = None) -> List[Dict[str, Any]]:
        """Get defense strategies, optionally filtered by attack technique"""
        try:
            with self.driver.session() as session:
                if technique_name:
                    result = session.run(
                        """
                        MATCH (t:AttackTechnique {name: $technique_name})<-[:COUNTERS]-(s:DefenseStrategy)
                        RETURN s
                        """,
                        technique_name=technique_name
                    )
                else:
                    result = session.run(
                        """
                        MATCH (s:DefenseStrategy)
                        RETURN s
                        LIMIT 50
                        """
                    )
                
                return [dict(record['s']) for record in result]
                
        except Exception as e:
            logger.error(f"Error getting defense strategies: {str(e)}")
            return []
    
    def create_threat_pattern(self, threat_data: Dict[str, Any]) -> bool:
        """Create a threat pattern node in the knowledge graph"""
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
                    id=threat_data.get('id'),
                    type=threat_data.get('type'),
                    severity=threat_data.get('severity'),
                    description=threat_data.get('description')
                )
                
                # Link to related attack techniques
                for technique_name in threat_data.get('related_techniques', []):
                    session.run(
                        """
                        MATCH (tp:ThreatPattern {id: $pattern_id})
                        MATCH (t:AttackTechnique {name: $technique_name})
                        MERGE (tp)-[:USES]->(t)
                        """,
                        pattern_id=threat_data.get('id'),
                        technique_name=technique_name
                    )
                
                return True
                
        except Exception as e:
            logger.error(f"Error creating threat pattern: {str(e)}")
            return False
