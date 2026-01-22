"""
Dataset Manager
Downloads, manages, and preprocesses cybersecurity datasets
"""

import logging
import os
import requests
import zipfile
import tarfile
from pathlib import Path
from typing import Dict, List, Optional, Any
import pandas as pd
from urllib.parse import urlparse
import hashlib

logger = logging.getLogger(__name__)


class DatasetManager:
    """Manage cybersecurity datasets for training"""
    
    # Popular cybersecurity datasets
    DATASETS = {
        'cicids2017': {
            'name': 'CICIDS2017',
            'url': 'https://www.unb.ca/cic/datasets/ids-2017.html',
            'download_url': None,  # Requires manual download
            'description': 'Network intrusion detection dataset',
            'size': '2.8 GB',
            'format': 'csv',
            'features': ['network_traffic', 'attack_types', 'benign_traffic']
        },
        'unsw-nb15': {
            'name': 'UNSW-NB15',
            'url': 'https://www.unsw.adfa.edu.au/unsw-canberra-cyber/cybersecurity/ADFA-NB15-Datasets/',
            'download_url': None,  # Requires manual download
            'description': 'Network traffic dataset with 9 attack categories',
            'size': '1.5 GB',
            'format': 'csv',
            'features': ['network_features', 'attack_categories']
        },
        'nsl-kdd': {
            'name': 'NSL-KDD',
            'url': 'https://www.kaggle.com/datasets/hassan06/nslkdd',
            'download_url': None,  # Requires Kaggle API
            'description': 'Improved version of KDD Cup 1999',
            'size': '100 MB',
            'format': 'csv',
            'features': ['network_features', 'attack_types']
        },
        'ember': {
            'name': 'EMBER',
            'url': 'https://github.com/elastic/ember',
            'download_url': 'https://github.com/elastic/ember/releases',
            'description': 'Malware benchmark dataset',
            'size': '1 GB',
            'format': 'json',
            'features': ['static_features', 'malware_labels']
        }
    }
    
    def __init__(self, datasets_dir: str = "datasets"):
        self.datasets_dir = Path(datasets_dir)
        self.datasets_dir.mkdir(parents=True, exist_ok=True)
    
    def list_available_datasets(self) -> Dict[str, Dict]:
        """List all available datasets"""
        return self.DATASETS
    
    def download_dataset(self, dataset_id: str, url: Optional[str] = None) -> Dict[str, Any]:
        """
        Download a dataset
        
        Args:
            dataset_id: ID of dataset to download
            url: Optional direct download URL
        
        Returns:
            Download status and file path
        """
        if dataset_id not in self.DATASETS:
            raise ValueError(f"Unknown dataset: {dataset_id}")
        
        dataset_info = self.DATASETS[dataset_id]
        dataset_path = self.datasets_dir / dataset_id
        
        try:
            # If URL provided, download directly
            if url:
                return self._download_from_url(url, dataset_path, dataset_id)
            
            # Otherwise, provide instructions
            return {
                'success': False,
                'message': f"Manual download required. Visit: {dataset_info['url']}",
                'instructions': self._get_download_instructions(dataset_id)
            }
            
        except Exception as e:
            logger.error(f"Error downloading dataset {dataset_id}: {str(e)}")
            raise
    
    def add_custom_dataset(self, file_path: str, dataset_id: str, metadata: Dict) -> Dict[str, Any]:
        """
        Add a custom dataset
        
        Args:
            file_path: Path to dataset file
            metadata: Dataset metadata
        
        Returns:
            Status of dataset addition
        """
        try:
            dataset_path = self.datasets_dir / dataset_id
            dataset_path.mkdir(parents=True, exist_ok=True)
            
            # Copy file to datasets directory
            import shutil
            dest_path = dataset_path / Path(file_path).name
            shutil.copy2(file_path, dest_path)
            
            # Save metadata
            metadata_path = dataset_path / "metadata.json"
            import json
            with open(metadata_path, 'w') as f:
                json.dump(metadata, f, indent=2)
            
            logger.info(f"Added custom dataset {dataset_id}")
            
            return {
                'success': True,
                'dataset_id': dataset_id,
                'path': str(dest_path),
                'metadata': metadata
            }
            
        except Exception as e:
            logger.error(f"Error adding custom dataset: {str(e)}")
            raise
    
    def get_dataset_info(self, dataset_id: str) -> Dict[str, Any]:
        """Get information about a dataset"""
        if dataset_id not in self.DATASETS:
            # Check if it's a custom dataset
            dataset_path = self.datasets_dir / dataset_id
            if dataset_path.exists():
                metadata_path = dataset_path / "metadata.json"
                if metadata_path.exists():
                    import json
                    with open(metadata_path, 'r') as f:
                        return json.load(f)
            
            raise ValueError(f"Unknown dataset: {dataset_id}")
        
        return self.DATASETS[dataset_id]
    
    def list_downloaded_datasets(self) -> List[Dict[str, Any]]:
        """List all downloaded datasets"""
        datasets = []
        
        for dataset_id in self.DATASETS.keys():
            dataset_path = self.datasets_dir / dataset_id
            if dataset_path.exists():
                datasets.append({
                    'id': dataset_id,
                    'name': self.DATASETS[dataset_id]['name'],
                    'path': str(dataset_path),
                    'status': 'downloaded'
                })
        
        # Check for custom datasets
        for custom_dir in self.datasets_dir.iterdir():
            if custom_dir.is_dir() and custom_dir.name not in self.DATASETS:
                metadata_path = custom_dir / "metadata.json"
                if metadata_path.exists():
                    import json
                    with open(metadata_path, 'r') as f:
                        metadata = json.load(f)
                    datasets.append({
                        'id': custom_dir.name,
                        'name': metadata.get('name', custom_dir.name),
                        'path': str(custom_dir),
                        'status': 'custom'
                    })
        
        return datasets
    
    def _download_from_url(self, url: str, dest_path: Path, dataset_id: str) -> Dict[str, Any]:
        """Download dataset from URL"""
        dest_path.mkdir(parents=True, exist_ok=True)
        
        logger.info(f"Downloading {url} to {dest_path}")
        
        # Download file
        response = requests.get(url, stream=True)
        response.raise_for_status()
        
        filename = urlparse(url).path.split('/')[-1]
        file_path = dest_path / filename
        
        # Download with progress
        total_size = int(response.headers.get('content-length', 0))
        downloaded = 0
        
        with open(file_path, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)
                    downloaded += len(chunk)
                    if total_size > 0:
                        progress = (downloaded / total_size) * 100
                        logger.info(f"Download progress: {progress:.1f}%")
        
        # Extract if archive
        if filename.endswith('.zip'):
            self._extract_zip(file_path, dest_path)
        elif filename.endswith('.tar.gz') or filename.endswith('.tgz'):
            self._extract_tar(file_path, dest_path)
        
        return {
            'success': True,
            'dataset_id': dataset_id,
            'path': str(dest_path),
            'file': str(file_path)
        }
    
    def _extract_zip(self, zip_path: Path, dest_path: Path):
        """Extract ZIP archive"""
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(dest_path)
        logger.info(f"Extracted {zip_path} to {dest_path}")
    
    def _extract_tar(self, tar_path: Path, dest_path: Path):
        """Extract TAR archive"""
        with tarfile.open(tar_path, 'r:gz') as tar_ref:
            tar_ref.extractall(dest_path)
        logger.info(f"Extracted {tar_path} to {dest_path}")
    
    def _get_download_instructions(self, dataset_id: str) -> str:
        """Get download instructions for a dataset"""
        dataset_info = self.DATASETS[dataset_id]
        
        instructions = f"""
        To download {dataset_info['name']}:
        
        1. Visit: {dataset_info['url']}
        2. Download the dataset files
        3. Extract to: {self.datasets_dir / dataset_id}
        4. Or use: dataset_manager.add_custom_dataset(file_path, '{dataset_id}', metadata)
        
        Dataset Info:
        - Size: {dataset_info['size']}
        - Format: {dataset_info['format']}
        - Description: {dataset_info['description']}
        """
        
        return instructions
