"""
Google Drive Downloader
Downloads documents from Google Drive links and processes them
"""

import logging
import os
import requests
from pathlib import Path
from typing import Dict, Optional, List, Any
import re
from urllib.parse import urlparse, parse_qs
import zipfile
import tempfile

logger = logging.getLogger(__name__)


class DriveDownloader:
    """Download files from Google Drive links"""
    
    def __init__(self, download_dir: str = "downloads"):
        self.download_dir = Path(download_dir)
        self.download_dir.mkdir(parents=True, exist_ok=True)
        self.session = requests.Session()
    
    def download_from_drive_link(self, drive_link: str, filename: Optional[str] = None) -> Dict[str, Any]:
        """
        Download file from Google Drive link
        
        Supports:
        - Direct file links: https://drive.google.com/file/d/FILE_ID/view
        - Shareable links: https://drive.google.com/open?id=FILE_ID
        - Folder links: https://drive.google.com/drive/folders/FOLDER_ID
        
        Args:
            drive_link: Google Drive link
            filename: Optional custom filename
        
        Returns:
            Download result with file path
        """
        try:
            # Extract file/folder ID from link
            file_id = self._extract_file_id(drive_link)
            if not file_id:
                raise ValueError("Could not extract file ID from Drive link")
            
            # Check if it's a folder
            if '/folders/' in drive_link or 'folders?id=' in drive_link:
                return self._download_folder(file_id, filename)
            else:
                return self._download_file(file_id, filename)
                
        except Exception as e:
            logger.error(f"Error downloading from Drive: {str(e)}")
            raise
    
    def download_from_url(self, url: str, filename: Optional[str] = None) -> Dict[str, Any]:
        """
        Download file from any URL (Drive, Dropbox, direct link, etc.)
        
        Args:
            url: File URL
            filename: Optional custom filename
        
        Returns:
            Download result
        """
        try:
            # Check if it's a Google Drive link
            if 'drive.google.com' in url:
                return self.download_from_drive_link(url, filename)
            
            # Direct download
            return self._download_direct(url, filename)
            
        except Exception as e:
            logger.error(f"Error downloading from URL: {str(e)}")
            raise
    
    def _extract_file_id(self, drive_link: str) -> Optional[str]:
        """Extract file/folder ID from Google Drive link"""
        patterns = [
            r'/file/d/([a-zA-Z0-9_-]+)',
            r'/open\?id=([a-zA-Z0-9_-]+)',
            r'/folders/([a-zA-Z0-9_-]+)',
            r'folders\?id=([a-zA-Z0-9_-]+)',
            r'id=([a-zA-Z0-9_-]+)',
        ]
        
        for pattern in patterns:
            match = re.search(pattern, drive_link)
            if match:
                return match.group(1)
        
        return None
    
    def _download_file(self, file_id: str, filename: Optional[str] = None) -> Dict[str, Any]:
        """Download a single file from Google Drive"""
        # Google Drive direct download URL
        download_url = f"https://drive.google.com/uc?export=download&id={file_id}"
        
        # First request to get download confirmation
        response = self.session.get(download_url, stream=True)
        
        # Check for virus scan warning
        if 'virus scan warning' in response.text.lower():
            # Extract confirmation token
            confirm_token = re.search(r'confirm=([a-zA-Z0-9_-]+)', response.text)
            if confirm_token:
                download_url = f"https://drive.google.com/uc?export=download&id={file_id}&confirm={confirm_token.group(1)}"
                response = self.session.get(download_url, stream=True)
        
        # Get filename from Content-Disposition or use provided/default
        if not filename:
            content_disposition = response.headers.get('Content-Disposition', '')
            if 'filename=' in content_disposition:
                filename = re.search(r'filename="?([^"]+)"?', content_disposition).group(1)
            else:
                filename = f"drive_file_{file_id}"
        
        file_path = self.download_dir / filename
        
        # Download file
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
        
        logger.info(f"Downloaded file: {file_path}")
        
        return {
            'success': True,
            'file_path': str(file_path),
            'filename': filename,
            'size': file_path.stat().st_size,
            'file_id': file_id
        }
    
    def _download_folder(self, folder_id: str, base_filename: Optional[str] = None) -> Dict[str, Any]:
        """
        Download all files from a Google Drive folder
        
        Note: This requires Google Drive API for full functionality.
        For now, returns instructions for manual download or API setup.
        """
        logger.warning(f"Folder download not supported. Folder ID: {folder_id}. Use individual file links instead.")
        
        return {
            'success': False,
            'error': 'Folder links are not supported. Please use individual file links.',
            'message': 'Google Drive folder downloads require API setup. Use individual file links instead.',
            'help': {
                'what_to_do': 'Use individual file links instead of folder links',
                'how_to_get_file_link': [
                    '1. Open the folder in Google Drive',
                    '2. Right-click on each file you want to process',
                    '3. Click "Get link" or "Share"',
                    '4. Make sure the file is set to "Anyone with the link"',
                    '5. Copy the file link (should look like: https://drive.google.com/file/d/FILE_ID/view)',
                    '6. Use that file link in the system'
                ],
                'file_link_format': 'https://drive.google.com/file/d/FILE_ID/view',
                'folder_id': folder_id
            }
        }
    
    def _download_direct(self, url: str, filename: Optional[str] = None) -> Dict[str, Any]:
        """Download file from direct URL"""
        if not filename:
            parsed_url = urlparse(url)
            filename = os.path.basename(parsed_url.path) or f"downloaded_file_{hash(url)}"
        
        file_path = self.download_dir / filename
        
        response = requests.get(url, stream=True)
        response.raise_for_status()
        
        total_size = int(response.headers.get('content-length', 0))
        downloaded = 0
        
        with open(file_path, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)
                    downloaded += len(chunk)
        
        logger.info(f"Downloaded from URL: {file_path}")
        
        return {
            'success': True,
            'file_path': str(file_path),
            'filename': filename,
            'size': file_path.stat().st_size,
            'url': url
        }
    
    def download_multiple(self, links: List[str]) -> Dict[str, List[Dict[str, Any]]]:
        """Download multiple files from links"""
        results = {
            'successful': [],
            'failed': []
        }
        
        for link in links:
            try:
                result = self.download_from_url(link)
                results['successful'].append(result)
            except Exception as e:
                results['failed'].append({
                    'link': link,
                    'error': str(e)
                })
        
        return results
