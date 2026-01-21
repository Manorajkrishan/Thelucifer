"""
Document Learning Engine
Extracts knowledge from cybersecurity documents using NLP
"""

import logging
from typing import Dict, List, Any
import PyPDF2
from docx import Document
import nltk
from transformers import pipeline

logger = logging.getLogger(__name__)


class DocumentProcessor:
    """Process cybersecurity documents and extract knowledge"""
    
    def __init__(self):
        # Initialize NLP models
        try:
            self.ner_model = pipeline(
                "ner",
                model="dbmdz/bert-large-cased-finetuned-conll03-english",
                aggregation_strategy="simple"
            )
            self.text_classifier = pipeline(
                "text-classification",
                model="distilbert-base-uncased-finetuned-sst-2-english"
            )
        except Exception as e:
            logger.warning(f"Could not load NLP models: {e}")
            self.ner_model = None
            self.text_classifier = None
        
        # Download required NLTK data
        try:
            nltk.data.find('tokenizers/punkt')
        except LookupError:
            nltk.download('punkt', quiet=True)
        
        try:
            nltk.data.find('corpora/stopwords')
        except LookupError:
            nltk.download('stopwords', quiet=True)
    
    def process_document(self, document_id: str, file_path: str, file_type: str) -> Dict[str, Any]:
        """
        Process a cybersecurity document and extract knowledge
        
        Args:
            document_id: Unique identifier for the document
            file_path: Path to the document file
            file_type: Type of document (pdf, docx, txt)
        
        Returns:
            Dictionary containing extracted knowledge
        """
        try:
            # Extract text from document
            text = self._extract_text(file_path, file_type)
            
            # Extract entities and knowledge
            extracted_data = {
                'document_id': document_id,
                'text': text,
                'attack_techniques': self._extract_attack_techniques(text),
                'exploit_patterns': self._extract_exploit_patterns(text),
                'defense_strategies': self._extract_defense_strategies(text),
                'entities': self._extract_entities(text),
                'keywords': self._extract_keywords(text),
                'summary': self._generate_summary(text),
            }
            
            logger.info(f"Successfully processed document {document_id}")
            return extracted_data
            
        except Exception as e:
            logger.error(f"Error processing document {document_id}: {str(e)}")
            raise
    
    def _extract_text(self, file_path: str, file_type: str) -> str:
        """Extract text content from document"""
        text = ""
        
        try:
            if file_type.lower() == 'pdf':
                with open(file_path, 'rb') as file:
                    pdf_reader = PyPDF2.PdfReader(file)
                    for page in pdf_reader.pages:
                        text += page.extract_text() + "\n"
            
            elif file_type.lower() in ['docx', 'doc']:
                doc = Document(file_path)
                for paragraph in doc.paragraphs:
                    text += paragraph.text + "\n"
            
            elif file_type.lower() == 'txt':
                with open(file_path, 'r', encoding='utf-8') as file:
                    text = file.read()
            
            return text.strip()
            
        except Exception as e:
            logger.error(f"Error extracting text from {file_path}: {str(e)}")
            raise
    
    def _extract_attack_techniques(self, text: str) -> List[Dict[str, Any]]:
        """Extract attack techniques from text"""
        techniques = []
        
        # Common attack technique keywords
        attack_keywords = [
            'trojan', 'ransomware', 'phishing', 'malware', 'virus',
            'sql injection', 'xss', 'ddos', 'mitm', 'zero-day',
            'backdoor', 'rootkit', 'spyware', 'adware', 'botnet'
        ]
        
        sentences = nltk.sent_tokenize(text.lower())
        
        for sentence in sentences:
            for keyword in attack_keywords:
                if keyword in sentence:
                    techniques.append({
                        'technique': keyword,
                        'context': sentence[:200],
                        'confidence': 0.8
                    })
        
        return techniques
    
    def _extract_exploit_patterns(self, text: str) -> List[Dict[str, Any]]:
        """Extract exploit patterns from text"""
        patterns = []
        
        # Look for patterns like CVE numbers, exploit codes, etc.
        import re
        
        cve_pattern = r'CVE-\d{4}-\d{4,7}'
        cves = re.findall(cve_pattern, text)
        
        for cve in cves:
            patterns.append({
                'type': 'cve',
                'identifier': cve,
                'confidence': 0.9
            })
        
        return patterns
    
    def _extract_defense_strategies(self, text: str) -> List[Dict[str, Any]]:
        """Extract defense strategies from text"""
        strategies = []
        
        defense_keywords = [
            'firewall', 'antivirus', 'ids', 'ips', 'encryption',
            'authentication', 'authorization', 'patch', 'update',
            'monitoring', 'logging', 'backup', 'incident response'
        ]
        
        sentences = nltk.sent_tokenize(text.lower())
        
        for sentence in sentences:
            for keyword in defense_keywords:
                if keyword in sentence:
                    strategies.append({
                        'strategy': keyword,
                        'context': sentence[:200],
                        'confidence': 0.8
                    })
        
        return strategies
    
    def _extract_entities(self, text: str) -> List[Dict[str, Any]]:
        """Extract named entities using NER model"""
        if not self.ner_model:
            return []
        
        try:
            entities = self.ner_model(text)
            return [
                {
                    'entity': ent['word'],
                    'label': ent['entity_group'],
                    'score': ent['score']
                }
                for ent in entities
            ]
        except Exception as e:
            logger.warning(f"Error extracting entities: {e}")
            return []
    
    def _extract_keywords(self, text: str) -> List[str]:
        """Extract important keywords from text"""
        from nltk.corpus import stopwords
        from nltk.tokenize import word_tokenize
        import string
        
        try:
            stop_words = set(stopwords.words('english'))
            words = word_tokenize(text.lower())
            
            keywords = [
                word for word in words
                if word not in stop_words
                and word not in string.punctuation
                and len(word) > 3
            ]
            
            # Get most common keywords
            from collections import Counter
            keyword_counts = Counter(keywords)
            top_keywords = [word for word, count in keyword_counts.most_common(20)]
            
            return top_keywords
            
        except Exception as e:
            logger.warning(f"Error extracting keywords: {e}")
            return []
    
    def _generate_summary(self, text: str, max_length: int = 200) -> str:
        """Generate a summary of the document"""
        sentences = nltk.sent_tokenize(text)
        
        if len(sentences) <= 3:
            return text[:max_length]
        
        # Simple summary: take first and last sentences
        summary = sentences[0] + " " + sentences[-1]
        return summary[:max_length]
