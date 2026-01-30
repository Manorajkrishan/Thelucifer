"""
Auto-Learner Service
Automatically downloads documents from Drive links and learns from them
"""

import logging
from typing import Dict, List, Any, Optional
from pathlib import Path
import os

from services.drive_downloader import DriveDownloader
from services.document_processor import DocumentProcessor
from services.self_learning_engine import SelfLearningEngine
from services.knowledge_graph import KnowledgeGraphService

logger = logging.getLogger(__name__)


class AutoLearner:
    """Automatically learn from documents via Drive links"""
    
    def __init__(self, 
                 download_dir: str = "downloads",
                 neo4j_driver=None):
        self.drive_downloader = DriveDownloader(download_dir)
        self.document_processor = DocumentProcessor()
        self.self_learning_engine = SelfLearningEngine()
        self.knowledge_graph = KnowledgeGraphService(neo4j_driver)
        
        self.processed_documents = []
    
    def learn_from_drive_link(self, 
                             drive_link: str,
                             document_id: Optional[str] = None,
                             auto_learn: bool = True) -> Dict[str, Any]:
        """
        Download document from Drive link and learn from it
        
        Args:
            drive_link: Google Drive link to document
            document_id: Optional document ID (auto-generated if not provided)
            auto_learn: Whether to automatically learn from the document
        
        Returns:
            Learning results
        """
        try:
            # Generate document ID if not provided
            if not document_id:
                import hashlib
                document_id = f"doc_{hashlib.md5(drive_link.encode()).hexdigest()[:12]}"
            
            logger.info(f"Downloading document from Drive: {drive_link}")
            
            # Download document
            download_result = self.drive_downloader.download_from_drive_link(drive_link)
            
            if not download_result.get('success'):
                error_msg = 'Failed to download document'
                details = download_result
                
                # Provide helpful error message for folder links
                if 'folder' in drive_link.lower() or 'folders' in drive_link.lower():
                    error_msg = 'Folder links are not supported. Please use individual file links instead.'
                    details = {
                        **download_result,
                        'help': 'To use a folder, please share each file individually and use their file links. File links look like: https://drive.google.com/file/d/FILE_ID/view'
                    }
                
                return {
                    'success': False,
                    'error': error_msg,
                    'details': details
                }
            
            file_path = download_result['file_path']
            filename = download_result['filename']
            
            # Detect file type
            file_type = self._detect_file_type(filename)
            
            logger.info(f"Processing document: {filename} ({file_type})")
            
            # Process document
            extracted_data = self.document_processor.process_document(
                document_id, file_path, file_type
            )
            
            # Store in knowledge graph (Neo4j or in-memory fallback)
            self.knowledge_graph.store_document_knowledge(document_id, extracted_data)
            
            # Auto-learn from document if enabled
            learning_result = None
            if auto_learn:
                logger.info("Auto-learning from document...")
                try:
                    learning_result = self.self_learning_engine.learn_from_documents([extracted_data])
                    logger.info(f"Learning completed: {learning_result.get('patterns_learned', 0)} patterns learned")
                except Exception as e:
                    logger.error(f"Error during learning: {e}")
                    learning_result = {'error': str(e)}
            
            # Track processed document
            self.processed_documents.append({
                'document_id': document_id,
                'drive_link': drive_link,
                'filename': filename,
                'file_path': file_path,
                'extracted_data': extracted_data,
                'learning_result': learning_result or {}
            })
            
            logger.info(f"Document tracked in learning system: {filename}")
            
            return {
                'success': True,
                'document_id': document_id,
                'filename': filename,
                'file_path': file_path,
                'extracted_data': {
                    'attack_techniques': len(extracted_data.get('attack_techniques', [])),
                    'exploit_patterns': len(extracted_data.get('exploit_patterns', [])),
                    'defense_strategies': len(extracted_data.get('defense_strategies', [])),
                    'keywords': len(extracted_data.get('keywords', [])),
                    'summary': extracted_data.get('summary', '')[:200]
                },
                'learning_result': learning_result,
                'message': 'Document processed and learned successfully'
            }
            
        except Exception as e:
            logger.error(f"Error learning from Drive link: {str(e)}")
            return {
                'success': False,
                'error': str(e)
            }
    
    def learn_from_multiple_links(self, 
                                 drive_links: List[str],
                                 auto_learn: bool = True) -> Dict[str, Any]:
        """
        Download and learn from multiple Drive links
        
        Args:
            drive_links: List of Google Drive links
            auto_learn: Whether to automatically learn from documents
        
        Returns:
            Batch learning results
        """
        results = {
            'successful': [],
            'failed': [],
            'total': len(drive_links),
            'learned_patterns': 0
        }
        
        for link in drive_links:
            try:
                result = self.learn_from_drive_link(link, auto_learn=auto_learn)
                
                if result.get('success'):
                    results['successful'].append(result)
                    if result.get('learning_result'):
                        results['learned_patterns'] += result['learning_result'].get('patterns_learned', 0)
                else:
                    results['failed'].append({
                        'link': link,
                        'error': result.get('error', 'Unknown error')
                    })
                    
            except Exception as e:
                results['failed'].append({
                    'link': link,
                    'error': str(e)
                })
        
        results['success_count'] = len(results['successful'])
        results['failure_count'] = len(results['failed'])
        
        return results
    
    def learn_from_url(self, url: str, auto_learn: bool = True) -> Dict[str, Any]:
        """
        Learn from any URL (Drive, Dropbox, direct link, etc.)
        
        Args:
            url: Document URL
            auto_learn: Whether to automatically learn
        
        Returns:
            Learning results
        """
        try:
            # Download from URL
            download_result = self.drive_downloader.download_from_url(url)
            
            if not download_result.get('success'):
                return {
                    'success': False,
                    'error': 'Failed to download from URL'
                }
            
            file_path = download_result['file_path']
            filename = download_result['filename']
            
            # Generate document ID
            import hashlib
            document_id = f"doc_{hashlib.md5(url.encode()).hexdigest()[:12]}"
            
            # Detect file type
            file_type = self._detect_file_type(filename)
            
            # Process document
            extracted_data = self.document_processor.process_document(
                document_id, file_path, file_type
            )
            
            # Store in knowledge graph (Neo4j or in-memory fallback)
            self.knowledge_graph.store_document_knowledge(document_id, extracted_data)
            
            # Auto-learn
            learning_result = None
            if auto_learn:
                learning_result = self.self_learning_engine.learn_from_documents([extracted_data])
            
            return {
                'success': True,
                'document_id': document_id,
                'filename': filename,
                'url': url,
                'extracted_data': extracted_data,
                'learning_result': learning_result
            }
            
        except Exception as e:
            logger.error(f"Error learning from URL: {str(e)}")
            return {
                'success': False,
                'error': str(e)
            }
    
    def _detect_file_type(self, filename: str) -> str:
        """Detect file type from filename"""
        ext = Path(filename).suffix.lower()
        
        file_types = {
            '.pdf': 'pdf',
            '.docx': 'docx',
            '.doc': 'docx',
            '.txt': 'txt',
            '.md': 'txt',
            '.csv': 'csv',
            '.json': 'json'
        }
        
        return file_types.get(ext, 'txt')
    
    def get_learning_summary(self) -> Dict[str, Any]:
        """Get summary of all learned documents"""
        total_patterns = sum(
            doc.get('learning_result', {}).get('patterns_learned', 0)
            for doc in self.processed_documents
        )
        
        attack_techniques = set()
        exploit_patterns = set()
        
        for doc in self.processed_documents:
            extracted = doc.get('extracted_data', {})
            for technique in extracted.get('attack_techniques', []):
                attack_techniques.add(technique.get('technique', ''))
            for pattern in extracted.get('exploit_patterns', []):
                exploit_patterns.add(pattern.get('identifier', ''))
        
        return {
            'total_documents': len(self.processed_documents),
            'total_patterns_learned': total_patterns,
            'unique_attack_techniques': len(attack_techniques),
            'unique_exploit_patterns': len(exploit_patterns),
            'attack_techniques': list(attack_techniques),
            'exploit_patterns': list(exploit_patterns)
        }
