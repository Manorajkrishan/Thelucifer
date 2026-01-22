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
from services.self_learning_engine import SelfLearningEngine
from services.dataset_manager import DatasetManager
from services.auto_learner import AutoLearner
from services.attacker_profiler import AttackerProfiler
from services.target_validator import TargetValidator
from services.counter_offensive_engine import CounterOffensiveEngine
from services.continuous_war_loop import ContinuousWarLoop

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)
# Configure CORS to allow all origins (for development)
CORS(app, resources={
    r"/*": {
        "origins": "*",
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"],
        "allow_headers": ["Content-Type", "Authorization", "X-Requested-With"],
        "supports_credentials": False
    }
})
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
self_learning_engine = SelfLearningEngine()
dataset_manager = DatasetManager()
auto_learner = AutoLearner(neo4j_driver=neo4j_driver)
attacker_profiler = AttackerProfiler()
target_validator = TargetValidator()
counter_offensive_engine = CounterOffensiveEngine()
war_loop = ContinuousWarLoop()


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


class SelfLearningResource(Resource):
    """Self-learning from datasets, threats, and documents"""
    def post(self):
        try:
            data = request.get_json()
            learning_type = data.get('type')  # 'dataset', 'threats', 'documents', 'hybrid'
            
            if learning_type == 'dataset':
                dataset_path = data.get('dataset_path')
                dataset_type = data.get('dataset_type', 'auto')
                result = self_learning_engine.learn_from_dataset(dataset_path, dataset_type)
            
            elif learning_type == 'threats':
                threats = data.get('threats', [])
                result = self_learning_engine.learn_from_threats(threats)
            
            elif learning_type == 'documents':
                documents = data.get('documents', [])
                result = self_learning_engine.learn_from_documents(documents)
            
            elif learning_type == 'hybrid':
                datasets = data.get('datasets', [])
                threats = data.get('threats', [])
                documents = data.get('documents', [])
                result = self_learning_engine.hybrid_learn(
                    datasets=datasets,
                    threats=threats,
                    documents=documents
                )
            else:
                return {'error': 'Invalid learning type'}, 400
            
            return {
                'success': True,
                'result': result,
                'message': 'Learning completed successfully'
            }, 200
            
        except Exception as e:
            logger.error(f"Error in self-learning: {str(e)}")
            return {'error': str(e)}, 500


class DatasetManagerResource(Resource):
    """Manage cybersecurity datasets"""
    def get(self):
        """List available or downloaded datasets"""
        list_type = request.args.get('type', 'available')  # 'available' or 'downloaded'
        
        if list_type == 'available':
            datasets = dataset_manager.list_available_datasets()
        else:
            datasets = dataset_manager.list_downloaded_datasets()
        
        return {
            'success': True,
            'datasets': datasets
        }, 200
    
    def post(self):
        """Download or add a dataset"""
        try:
            data = request.get_json()
            action = data.get('action')  # 'download' or 'add'
            
            if action == 'download':
                dataset_id = data.get('dataset_id')
                url = data.get('url')
                result = dataset_manager.download_dataset(dataset_id, url)
            
            elif action == 'add':
                file_path = data.get('file_path')
                dataset_id = data.get('dataset_id')
                metadata = data.get('metadata', {})
                result = dataset_manager.add_custom_dataset(file_path, dataset_id, metadata)
            
            else:
                return {'error': 'Invalid action'}, 400
            
            return {
                'success': True,
                'result': result
            }, 200
            
        except Exception as e:
            logger.error(f"Error managing dataset: {str(e)}")
            return {'error': str(e)}, 500


class DriveLinkLearnerResource(Resource):
    """Learn from Google Drive links and other URLs"""
    def post(self):
        """Download and learn from Drive link or URL"""
        try:
            data = request.get_json() or {}
            drive_link = data.get('drive_link') or data.get('url')
            document_id = data.get('document_id')
            auto_learn = data.get('auto_learn', True)
            
            if not drive_link:
                logger.warning("Missing drive_link in request")
                return {
                    'success': False,
                    'error': 'Missing drive_link or url parameter'
                }, 400
            
            logger.info(f"Processing Drive link: {drive_link[:50]}...")
            
            # Learn from Drive link
            result = auto_learner.learn_from_drive_link(
                drive_link, 
                document_id=document_id,
                auto_learn=auto_learn
            )
            
            if result.get('success'):
                logger.info(f"Successfully learned from Drive link: {result.get('filename', 'Unknown')}")
                return {
                    'success': True,
                    'result': result,
                    'message': 'Document downloaded and learned successfully'
                }, 200
            else:
                error_msg = result.get('error', 'Unknown error')
                logger.error(f"Failed to learn from Drive link: {error_msg}")
                return {
                    'success': False,
                    'error': error_msg,
                    'details': result.get('details', {})
                }, 400
                
        except Exception as e:
            error_msg = str(e)
            logger.error(f"Error learning from Drive link: {error_msg}", exc_info=True)
            return {
                'success': False,
                'error': error_msg
            }, 500
    
    def options(self):
        """Handle CORS preflight requests"""
        return {}, 200


class BatchDriveLearnerResource(Resource):
    """Learn from multiple Drive links"""
    def post(self):
        """Download and learn from multiple Drive links"""
        try:
            data = request.get_json() or {}
            drive_links = data.get('drive_links') or data.get('urls', [])
            auto_learn = data.get('auto_learn', True)
            
            if not drive_links:
                logger.warning("Missing drive_links in request")
                return {
                    'success': False,
                    'error': 'Missing drive_links or urls parameter'
                }, 400
            
            if not isinstance(drive_links, list):
                logger.warning(f"Invalid drive_links type: {type(drive_links)}")
                return {
                    'success': False,
                    'error': 'drive_links must be a list'
                }, 400
            
            logger.info(f"Processing {len(drive_links)} Drive link(s)")
            
            # Learn from multiple links
            result = auto_learner.learn_from_multiple_links(
                drive_links,
                auto_learn=auto_learn
            )
            
            return {
                'success': True,
                'result': result,
                'message': f"Processed {result.get('success_count', 0)}/{result.get('total', len(drive_links))} documents"
            }, 200
                
        except Exception as e:
            error_msg = str(e)
            logger.error(f"Error learning from multiple Drive links: {error_msg}", exc_info=True)
            return {
                'success': False,
                'error': error_msg
            }, 500
    
    def options(self):
        """Handle CORS preflight requests"""
        return {}, 200


class LearningSummaryResource(Resource):
    """Get learning summary"""
    def get(self):
        """Get summary of all learned documents"""
        try:
            summary = auto_learner.get_learning_summary()
            return {
                'success': True,
                'summary': summary
            }, 200
        except Exception as e:
            logger.error(f"Error getting learning summary: {str(e)}")
            return {'error': str(e)}, 500


class CounterOffensiveResource(Resource):
    """Autonomous Cyber Counter-Offensive System (Fictional/Simulation)"""
    def post(self):
        """
        Execute full counter-offensive cycle:
        1. Detect attack
        2. Profile attacker
        3. Validate target
        4. Execute counter-offensive (SIMULATED)
        5. Monitor for retaliation
        """
        try:
            data = request.get_json()
            attack_data = data.get('attack_data', {})
            
            # Step 1: Attack Detection (already done by threat_detector)
            # Step 2: Attacker Profiling
            attacker_profile = attacker_profiler.profile_attacker(attack_data)
            
            # Step 3: Target Validation
            validation_result = target_validator.validate_target(attacker_profile, attack_data)
            
            # Step 4: Execute Counter-Offensive (SIMULATED)
            counter_offensive_result = None
            if validation_result.get('validated'):
                counter_offensive_result = counter_offensive_engine.execute_counter_offensive(
                    attacker_profile, validation_result
                )
                
                # Step 5: Start Continuous War Loop
                war_loop.start_monitoring(
                    attacker_profile.get('attacker_id'),
                    attacker_profile
                )
            
            return {
                'success': True,
                'attacker_profile': attacker_profile,
                'validation': validation_result,
                'counter_offensive': counter_offensive_result,
                'warning': 'THIS IS A SIMULATION SYSTEM - NO ACTUAL ATTACKS ARE EXECUTED',
                'message': 'Counter-offensive cycle completed (simulated)'
            }, 200
            
        except Exception as e:
            logger.error(f"Error in counter-offensive: {str(e)}")
            return {'error': str(e)}, 500


class TrainingResource(Resource):
    """Train ML models"""
    def post(self):
        """Train threat detection or document processing models"""
        try:
            data = request.get_json()
            model_type = data.get('model_type', 'threat_detector')  # 'threat_detector' or 'document_processor'
            dataset = data.get('dataset')  # Dataset ID or path
            epochs = data.get('epochs', 10)
            batch_size = data.get('batch_size', 32)
            validation_split = data.get('validation_split', 0.2)
            
            if model_type == 'threat_detector':
                # Train threat detection model
                if dataset:
                    # Download dataset if needed
                    dataset_path = dataset_manager.download_dataset(dataset)
                    if dataset_path.get('success'):
                        result = self_learning_engine.learn_from_dataset(
                            dataset_path.get('path'),
                            dataset_type=dataset.lower()
                        )
                        return {
                            'success': True,
                            'model_type': model_type,
                            'accuracy': result.get('training_results', {}).get('accuracy', 0),
                            'loss': 1 - result.get('training_results', {}).get('accuracy', 0),
                            'result': result
                        }, 200
                    else:
                        return {'error': 'Failed to download dataset'}, 400
                else:
                    # Train on existing threats
                    result = self_learning_engine.learn_from_threats([])
                    return {
                        'success': True,
                        'model_type': model_type,
                        'result': result
                    }, 200
            
            elif model_type == 'document_processor':
                # Train document processing model
                documents = data.get('documents', [])
                result = self_learning_engine.learn_from_documents(documents)
                return {
                    'success': True,
                    'model_type': model_type,
                    'result': result
                }, 200
            
            else:
                return {'error': 'Invalid model_type'}, 400
                
        except Exception as e:
            logger.error(f"Error training model: {str(e)}")
            return {'error': str(e)}, 500


class WarLoopResource(Resource):
    """Continuous War Loop Management"""
    def get(self):
        """Get war loop status"""
        try:
            status = war_loop.get_war_status()
            retaliation = request.args.get('check_retaliation', 'false') == 'true'
            
            result = {'status': status}
            
            if retaliation:
                # Check for retaliation (requires network data)
                network_data = request.args.get('network_data')
                if network_data:
                    import json
                    retaliation_result = war_loop.detect_retaliation(json.loads(network_data))
                    result['retaliation'] = retaliation_result
            
            return {
                'success': True,
                'result': result
            }, 200
            
        except Exception as e:
            logger.error(f"Error getting war loop status: {str(e)}")
            return {'error': str(e)}, 500
    
    def post(self):
        """Evolve counter-offensive strategies"""
        try:
            data = request.get_json()
            attack_history = data.get('attack_history', [])
            success_rates = data.get('success_rates', {})
            
            evolution = war_loop.evolve_strategy(attack_history, success_rates)
            
            return {
                'success': True,
                'evolution': evolution
            }, 200
            
        except Exception as e:
            logger.error(f"Error evolving strategy: {str(e)}")
            return {'error': str(e)}, 500


# Register API resources
api.add_resource(HealthCheck, '/health')
api.add_resource(DocumentProcessResource, '/api/v1/documents/process')
api.add_resource(ThreatDetectResource, '/api/v1/threats/detect')
api.add_resource(SimulationResource, '/api/v1/simulations/run')
api.add_resource(KnowledgeGraphResource, '/api/v1/knowledge/query')
api.add_resource(SelfLearningResource, '/api/v1/learning/learn')
api.add_resource(DatasetManagerResource, '/api/v1/datasets')
api.add_resource(DriveLinkLearnerResource, '/api/v1/learning/drive-link')
api.add_resource(BatchDriveLearnerResource, '/api/v1/learning/drive-links')
api.add_resource(LearningSummaryResource, '/api/v1/learning/summary')
api.add_resource(CounterOffensiveResource, '/api/v1/counter-offensive/execute')
api.add_resource(WarLoopResource, '/api/v1/war-loop')
api.add_resource(TrainingResource, '/api/v1/training/train')

# Handle OPTIONS requests for CORS preflight
@app.route('/api/v1/learning/drive-link', methods=['OPTIONS'])
@app.route('/api/v1/learning/drive-links', methods=['OPTIONS'])
@app.route('/api/v1/<path:path>', methods=['OPTIONS'])
def handle_options(path=None):
    """Handle CORS preflight OPTIONS requests"""
    response = app.make_default_options_response()
    return response


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
            'query_knowledge': '/api/v1/knowledge/query',
            'self_learning': '/api/v1/learning/learn',
            'dataset_manager': '/api/v1/datasets',
            'drive_link_learner': '/api/v1/learning/drive-link',
            'batch_drive_learner': '/api/v1/learning/drive-links',
            'learning_summary': '/api/v1/learning/summary',
            'counter_offensive': '/api/v1/counter-offensive/execute',
            'war_loop': '/api/v1/war-loop',
            'training': '/api/v1/training/train'
        }
    })


if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=os.getenv('DEBUG', 'False') == 'True')
