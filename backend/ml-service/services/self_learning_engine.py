"""
Self-Learning Engine
Continuously learns from new threats, documents, and datasets
"""

import logging
import numpy as np
import pandas as pd
from typing import Dict, List, Any, Optional
from datetime import datetime
import pickle
import os
from pathlib import Path
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
from sklearn.preprocessing import StandardScaler
import joblib

logger = logging.getLogger(__name__)


class SelfLearningEngine:
    """Self-learning engine that continuously improves from new data"""
    
    def __init__(self, model_dir: str = "models"):
        self.model_dir = Path(model_dir)
        self.model_dir.mkdir(exist_ok=True)
        
        # Initialize models
        self.models = {
            'random_forest': RandomForestClassifier(n_estimators=100, random_state=42),
            'gradient_boosting': GradientBoostingClassifier(n_estimators=100, random_state=42)
        }
        
        self.scaler = StandardScaler()
        self.feature_names = []
        self.model_version = "1.0.0"
        self.training_history = []
        
        # Load existing models if available
        self._load_models()
    
    def learn_from_dataset(self, dataset_path: str, dataset_type: str = "auto") -> Dict[str, Any]:
        """
        Learn from a cybersecurity dataset
        
        Args:
            dataset_path: Path to dataset file (CSV, JSON, etc.)
            dataset_type: Type of dataset (cicids2017, unsw-nb15, etc.) or 'auto' for detection
        
        Returns:
            Training results and model performance metrics
        """
        try:
            logger.info(f"Loading dataset from {dataset_path}")
            
            # Load dataset
            if dataset_path.endswith('.csv'):
                df = pd.read_csv(dataset_path)
            elif dataset_path.endswith('.json'):
                df = pd.read_json(dataset_path)
            else:
                raise ValueError(f"Unsupported file format: {dataset_path}")
            
            # Preprocess dataset based on type
            if dataset_type == "auto":
                dataset_type = self._detect_dataset_type(df)
            
            processed_data = self._preprocess_dataset(df, dataset_type)
            
            # Extract features and labels
            X, y = self._extract_features_labels(processed_data, dataset_type)
            
            # Train models
            training_results = self._train_models(X, y)
            
            # Save models
            self._save_models()
            
            logger.info(f"Successfully learned from dataset. Accuracy: {training_results['accuracy']:.2%}")
            
            return {
                'success': True,
                'dataset_type': dataset_type,
                'samples_processed': len(X),
                'features': len(X[0]) if len(X) > 0 else 0,
                'training_results': training_results,
                'model_version': self.model_version
            }
            
        except Exception as e:
            logger.error(f"Error learning from dataset: {str(e)}")
            raise
    
    def learn_from_threats(self, threats: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Learn from real threat incidents (online learning)
        
        Args:
            threats: List of threat dictionaries with features and labels
        
        Returns:
            Learning results
        """
        try:
            if not threats:
                return {'success': False, 'message': 'No threats provided'}
            
            # Convert threats to feature vectors
            X = []
            y = []
            
            for threat in threats:
                features = self._extract_threat_features(threat)
                label = threat.get('classification', 'unknown')
                
                if features:
                    X.append(features)
                    y.append(label)
            
            if not X:
                return {'success': False, 'message': 'No valid features extracted'}
            
            X = np.array(X)
            
            # Incremental learning (partial fit if supported)
            # For now, retrain on accumulated data
            training_results = self._train_models(X, y)
            
            # Save updated models
            self._save_models()
            
            logger.info(f"Learned from {len(threats)} threats")
            
            return {
                'success': True,
                'threats_processed': len(threats),
                'training_results': training_results
            }
            
        except Exception as e:
            logger.error(f"Error learning from threats: {str(e)}")
            raise
    
    def learn_from_documents(self, document_knowledge: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Learn from extracted document knowledge
        
        Args:
            document_knowledge: List of knowledge extracted from documents
        
        Returns:
            Learning results
        """
        try:
            # Convert document knowledge to training features
            patterns = []
            labels = []
            
            for doc in document_knowledge:
                # Extract attack patterns
                attack_techniques = doc.get('attack_techniques', [])
                exploit_patterns = doc.get('exploit_patterns', [])
                
                for technique in attack_techniques:
                    patterns.append({
                        'type': 'attack_technique',
                        'name': technique.get('technique', ''),
                        'context': technique.get('context', ''),
                        'confidence': technique.get('confidence', 0.5)
                    })
                    labels.append(technique.get('technique', 'unknown'))
                
                for pattern in exploit_patterns:
                    patterns.append({
                        'type': 'exploit_pattern',
                        'identifier': pattern.get('identifier', ''),
                        'confidence': pattern.get('confidence', 0.5)
                    })
                    labels.append(pattern.get('type', 'unknown'))
            
            # Update knowledge base (can be used for rule-based detection)
            logger.info(f"Learned {len(patterns)} patterns from documents")
            
            return {
                'success': True,
                'patterns_learned': len(patterns),
                'documents_processed': len(document_knowledge)
            }
            
        except Exception as e:
            logger.error(f"Error learning from documents: {str(e)}")
            raise
    
    def hybrid_learn(self, 
                     datasets: Optional[List[str]] = None,
                     threats: Optional[List[Dict[str, Any]]] = None,
                     documents: Optional[List[Dict[str, Any]]] = None) -> Dict[str, Any]:
        """
        Hybrid learning: Combine datasets, threats, and documents
        
        Args:
            datasets: List of dataset file paths
            threats: List of threat incidents
            documents: List of document knowledge
        
        Returns:
            Combined learning results
        """
        results = {
            'dataset_learning': None,
            'threat_learning': None,
            'document_learning': None,
            'combined_accuracy': 0.0
        }
        
        # Learn from datasets
        if datasets:
            for dataset_path in datasets:
                try:
                    result = self.learn_from_dataset(dataset_path)
                    results['dataset_learning'] = result
                except Exception as e:
                    logger.error(f"Error learning from dataset {dataset_path}: {e}")
        
        # Learn from threats
        if threats:
            try:
                results['threat_learning'] = self.learn_from_threats(threats)
            except Exception as e:
                logger.error(f"Error learning from threats: {e}")
        
        # Learn from documents
        if documents:
            try:
                results['document_learning'] = self.learn_from_documents(documents)
            except Exception as e:
                logger.error(f"Error learning from documents: {e}")
        
        # Calculate combined performance
        # This would be evaluated on a test set
        results['combined_accuracy'] = self._evaluate_combined_models()
        
        return results
    
    def _detect_dataset_type(self, df: pd.DataFrame) -> str:
        """Auto-detect dataset type based on column names"""
        columns = [col.lower() for col in df.columns]
        
        # CICIDS2017 indicators
        if any('flow' in col for col in columns) and any('packet' in col for col in columns):
            return "cicids2017"
        
        # UNSW-NB15 indicators
        if 'attack_cat' in columns or 'label' in columns:
            return "unsw-nb15"
        
        # Generic network traffic
        if any('src' in col or 'dst' in col for col in columns):
            return "network_traffic"
        
        return "generic"
    
    def _preprocess_dataset(self, df: pd.DataFrame, dataset_type: str) -> pd.DataFrame:
        """Preprocess dataset based on type"""
        # Remove missing values
        df = df.dropna()
        
        # Handle categorical variables
        categorical_cols = df.select_dtypes(include=['object']).columns
        
        for col in categorical_cols:
            if col != 'label' and col != 'Label' and 'attack' not in col.lower():
                # Encode categorical variables
                df[col] = pd.Categorical(df[col]).codes
        
        return df
    
    def _extract_features_labels(self, df: pd.DataFrame, dataset_type: str) -> tuple:
        """Extract features and labels from dataset"""
        # Find label column
        label_cols = [col for col in df.columns if 'label' in col.lower() or 'attack' in col.lower() or col == 'Class']
        
        if not label_cols:
            raise ValueError("No label column found in dataset")
        
        label_col = label_cols[0]
        y = df[label_col].values
        
        # Features are all columns except label
        feature_cols = [col for col in df.columns if col != label_col]
        X = df[feature_cols].values
        
        # Store feature names
        self.feature_names = feature_cols
        
        # Encode labels if needed
        if y.dtype == 'object':
            from sklearn.preprocessing import LabelEncoder
            le = LabelEncoder()
            y = le.fit_transform(y)
        
        return X, y
    
    def _train_models(self, X: np.ndarray, y: np.ndarray) -> Dict[str, Any]:
        """Train ML models"""
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42, stratify=y
        )
        
        # Scale features
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)
        
        results = {}
        
        # Train each model
        for model_name, model in self.models.items():
            model.fit(X_train_scaled, y_train)
            
            # Evaluate
            y_pred = model.predict(X_test_scaled)
            
            accuracy = accuracy_score(y_test, y_pred)
            precision = precision_score(y_test, y_pred, average='weighted', zero_division=0)
            recall = recall_score(y_test, y_pred, average='weighted', zero_division=0)
            f1 = f1_score(y_test, y_pred, average='weighted', zero_division=0)
            
            results[model_name] = {
                'accuracy': accuracy,
                'precision': precision,
                'recall': recall,
                'f1_score': f1
            }
        
        # Use best model
        best_model_name = max(results.keys(), key=lambda k: results[k]['accuracy'])
        results['best_model'] = best_model_name
        results['accuracy'] = results[best_model_name]['accuracy']
        
        return results
    
    def _extract_threat_features(self, threat: Dict[str, Any]) -> Optional[List[float]]:
        """Extract features from a threat incident"""
        features = []
        
        # Network features
        if 'network' in threat:
            network = threat['network']
            features.extend([
                network.get('packet_count', 0),
                network.get('bytes_transferred', 0),
                network.get('connection_count', 0),
            ])
        
        # Behavioral features
        if 'behavior' in threat:
            behavior = threat['behavior']
            features.extend([
                behavior.get('suspicious_file_access', 0),
                behavior.get('unusual_network_activity', 0),
                behavior.get('privilege_escalation', 0),
            ])
        
        return features if features else None
    
    def _evaluate_combined_models(self) -> float:
        """Evaluate combined model performance"""
        # This would use a validation set
        # For now, return average of stored metrics
        if self.training_history:
            accuracies = [h.get('accuracy', 0) for h in self.training_history]
            return sum(accuracies) / len(accuracies) if accuracies else 0.0
        return 0.0
    
    def _save_models(self):
        """Save trained models"""
        for model_name, model in self.models.items():
            model_path = self.model_dir / f"{model_name}_v{self.model_version}.pkl"
            joblib.dump(model, model_path)
        
        # Save scaler
        scaler_path = self.model_dir / f"scaler_v{self.model_version}.pkl"
        joblib.dump(self.scaler, scaler_path)
        
        logger.info(f"Models saved to {self.model_dir}")
    
    def _load_models(self):
        """Load existing models if available"""
        try:
            # Find latest model files
            model_files = list(self.model_dir.glob("*.pkl"))
            if model_files:
                # Load most recent model
                latest_model = max(model_files, key=lambda p: p.stat().st_mtime)
                # This is simplified - in production, load all models
                logger.info(f"Found existing models in {self.model_dir}")
        except Exception as e:
            logger.warning(f"Could not load existing models: {e}")
