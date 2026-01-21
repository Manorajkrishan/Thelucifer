"""
SentinelAI X ML Service
AI/ML Engine for document learning, threat detection, and simulation
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_restful import Api, Resource
import redis
import psycopg2
from neo4j import GraphDatabase
import os
from dotenv import load_dotenv
import logging

from services.document_processor import DocumentProcessor
from services.threat_detector import ThreatDetector
from services.simulation_engine import SimulationEngine
from services.knowledge_graph import KnowledgeGraphService

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)
CORS(app)
api = Api(app)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize Redis connection
redis_client = redis.Redis(
    host=os.getenv('REDIS_HOST', 'localhost'),
    port=int(os.getenv('REDIS_PORT', 6379)),
    decode_responses=True
)

# Initialize PostgreSQL connection pool
def get_db_connection():
    return psycopg2.connect(
        host=os.getenv('POSTGRES_HOST', 'localhost'),
        database=os.getenv('POSTGRES_DB', 'sentinelai'),
        user=os.getenv('POSTGRES_USER', 'sentinelai_user'),
        password=os.getenv('POSTGRES_PASSWORD', 'sentinelai_password')
    )

# Initialize Neo4j driver
neo4j_driver = GraphDatabase.driver(
    os.getenv('NEO4J_URI', 'bolt://localhost:7687'),
    auth=(os.getenv('NEO4J_USER', 'neo4j'), os.getenv('NEO4J_PASSWORD', 'sentinelai_password'))
)

# Initialize services
document_processor = DocumentProcessor()
threat_detector = ThreatDetector()
simulation_engine = SimulationEngine()
knowledge_graph = KnowledgeGraphService(neo4j_driver)


class HealthCheck(Resource):
    """Health check endpoint"""
    def get(self):
        return {
            'status': 'healthy',
            'service': 'ML Service',
            'version': '1.0.0'
        }


class DocumentProcessResource(Resource):
    """Process cybersecurity documents"""
    def post(self):
        try:
            data = request.get_json()
            document_id = data.get('document_id')
            file_path = data.get('file_path')
            file_type = data.get('file_type')

            if not all([document_id, file_path, file_type]):
                return {'error': 'Missing required fields'}, 400

            # Process document
            result = document_processor.process_document(document_id, file_path, file_type)

            # Store extracted knowledge in Neo4j
            knowledge_graph.store_document_knowledge(document_id, result)

            return {
                'success': True,
                'document_id': document_id,
                'extracted_data': result,
                'message': 'Document processed successfully'
            }, 200

        except Exception as e:
            logger.error(f"Error processing document: {str(e)}")
            return {'error': str(e)}, 500


class ThreatDetectResource(Resource):
    """Detect cyber threats"""
    def post(self):
        try:
            data = request.get_json()
            
            # Detect threat
            detection_result = threat_detector.detect_threat(data)

            return {
                'success': True,
                'detection': detection_result,
                'message': 'Threat detection completed'
            }, 200

        except Exception as e:
            logger.error(f"Error detecting threat: {str(e)}")
            return {'error': str(e)}, 500


class SimulationResource(Resource):
    """Run cyber-offensive simulation"""
    def post(self):
        try:
            data = request.get_json()
            simulation_type = data.get('type')
            threat_data = data.get('threat_data')

            if not simulation_type:
                return {'error': 'Missing simulation type'}, 400

            # Run simulation in sandboxed environment
            simulation_result = simulation_engine.run_simulation(simulation_type, threat_data)

            return {
                'success': True,
                'simulation': simulation_result,
                'message': 'Simulation completed successfully'
            }, 200

        except Exception as e:
            logger.error(f"Error running simulation: {str(e)}")
            return {'error': str(e)}, 500


class KnowledgeGraphResource(Resource):
    """Query knowledge graph"""
    def get(self):
        try:
            query = request.args.get('query')
            if not query:
                return {'error': 'Missing query parameter'}, 400

            results = knowledge_graph.query_knowledge(query)

            return {
                'success': True,
                'results': results
            }, 200

        except Exception as e:
            logger.error(f"Error querying knowledge graph: {str(e)}")
            return {'error': str(e)}, 500


# Register API resources
api.add_resource(HealthCheck, '/health')
api.add_resource(DocumentProcessResource, '/api/v1/documents/process')
api.add_resource(ThreatDetectResource, '/api/v1/threats/detect')
api.add_resource(SimulationResource, '/api/v1/simulations/run')
api.add_resource(KnowledgeGraphResource, '/api/v1/knowledge/query')


@app.route('/')
def index():
    return jsonify({
        'service': 'SentinelAI X ML Service',
        'version': '1.0.0',
        'endpoints': {
            'health': '/health',
            'process_document': '/api/v1/documents/process',
            'detect_threat': '/api/v1/threats/detect',
            'run_simulation': '/api/v1/simulations/run',
            'query_knowledge': '/api/v1/knowledge/query'
        }
    })


if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=os.getenv('DEBUG', 'False') == 'True')
