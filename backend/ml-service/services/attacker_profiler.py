"""
Attacker Profiling Engine
Creates threat fingerprints by analyzing attack patterns, network routes, and toolkits
"""

import logging
from typing import Dict, List, Any, Optional
import hashlib
from datetime import datetime
import re

logger = logging.getLogger(__name__)


class AttackerProfiler:
    """Profile attackers and create threat fingerprints"""
    
    def __init__(self):
        self.threat_actor_db = {}
        self.malware_families = {}
        self.toolkit_signatures = {}
        self._load_known_threats()
    
    def profile_attacker(self, attack_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Create comprehensive attacker profile
        
        Args:
            attack_data: Attack data containing network, behavior, and system info
        
        Returns:
            Attacker profile with fingerprint
        """
        try:
            # Extract network intelligence
            network_intel = self._analyze_network_routes(attack_data.get('network', {}))
            
            # Analyze packet signatures
            packet_analysis = self._analyze_packet_signatures(attack_data.get('packets', []))
            
            # Identify toolkits and malware families
            toolkit_identification = self._identify_toolkits(attack_data)
            malware_identification = self._identify_malware_family(attack_data)
            
            # Correlate with known threat actors
            threat_actor_match = self._correlate_threat_actors(
                network_intel, toolkit_identification, malware_identification
            )
            
            # Create threat fingerprint
            fingerprint = self._create_fingerprint(
                network_intel, packet_analysis, toolkit_identification,
                malware_identification, threat_actor_match
            )
            
            # Calculate threat level
            threat_level = self._calculate_threat_level(
                attack_data, toolkit_identification, malware_identification
            )
            
            profile = {
                'attacker_id': fingerprint['id'],
                'fingerprint': fingerprint,
                'network_intelligence': network_intel,
                'packet_analysis': packet_analysis,
                'toolkit_identification': toolkit_identification,
                'malware_family': malware_identification,
                'threat_actor_match': threat_actor_match,
                'threat_level': threat_level,
                'profiled_at': datetime.utcnow().isoformat(),
                'confidence': self._calculate_confidence(
                    toolkit_identification, malware_identification, threat_actor_match
                )
            }
            
            logger.info(f"Profiled attacker: {fingerprint['id']}")
            return profile
            
        except Exception as e:
            logger.error(f"Error profiling attacker: {str(e)}")
            raise
    
    def _analyze_network_routes(self, network_data: Dict[str, Any]) -> Dict[str, Any]:
        """Trace network routes and analyze routing patterns"""
        routes = []
        source_ip = network_data.get('source_ip', 'unknown')
        destination_ip = network_data.get('destination_ip', 'unknown')
        
        # Simulate route tracing
        if source_ip != 'unknown':
            # Extract IP information
            ip_info = {
                'source_ip': source_ip,
                'destination_ip': destination_ip,
                'hop_count': network_data.get('hop_count', 0),
                'routing_path': network_data.get('routing_path', []),
                'geolocation': self._get_geolocation(source_ip),
                'asn': network_data.get('asn', 'unknown'),
                'isp': network_data.get('isp', 'unknown')
            }
            
            routes.append(ip_info)
        
        return {
            'routes': routes,
            'route_count': len(routes),
            'has_proxy': self._detect_proxy(network_data),
            'has_vpn': self._detect_vpn(network_data),
            'has_tor': self._detect_tor(network_data)
        }
    
    def _analyze_packet_signatures(self, packets: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Analyze packet signatures and patterns"""
        signatures = []
        protocols = {}
        ports = {}
        
        for packet in packets:
            protocol = packet.get('protocol', 'unknown')
            port = packet.get('port', 0)
            payload = packet.get('payload', '')
            
            # Count protocols
            protocols[protocol] = protocols.get(protocol, 0) + 1
            
            # Count ports
            if port > 0:
                ports[port] = ports.get(port, 0) + 1
            
            # Extract signatures
            signature = self._extract_packet_signature(packet)
            if signature:
                signatures.append(signature)
        
        return {
            'signatures': signatures,
            'protocols': protocols,
            'ports': ports,
            'unique_signatures': len(set(signatures)),
            'suspicious_patterns': self._detect_suspicious_patterns(packets)
        }
    
    def _identify_toolkits(self, attack_data: Dict[str, Any]) -> Dict[str, Any]:
        """Identify attack toolkits and frameworks"""
        toolkits = []
        behavior = attack_data.get('behavior', {})
        network = attack_data.get('network', {})
        
        # Check for known toolkit signatures
        toolkit_patterns = {
            'metasploit': ['msf', 'meterpreter', 'payload'],
            'cobalt_strike': ['beacon', 'c2', 'stager'],
            'empire': ['empire', 'powershell', 'stager'],
            'mimikatz': ['sekurlsa', 'lsadump', 'kerberos'],
            'bloodhound': ['bloodhound', 'neo4j', 'cypher'],
            'nmap': ['nmap', 'scan', 'port'],
            'burp_suite': ['burp', 'proxy', 'intruder']
        }
        
        # Analyze behavior patterns
        for toolkit_name, patterns in toolkit_patterns.items():
            matches = sum(1 for pattern in patterns 
                         if any(pattern.lower() in str(v).lower() 
                               for v in behavior.values()))
            
            if matches > 0:
                toolkits.append({
                    'name': toolkit_name,
                    'confidence': min(0.9, matches / len(patterns)),
                    'indicators': matches
                })
        
        # Analyze network patterns
        connection_patterns = network.get('connection_patterns', [])
        for pattern in connection_patterns:
            if 'c2' in pattern.lower() or 'command' in pattern.lower():
                toolkits.append({
                    'name': 'c2_framework',
                    'confidence': 0.7,
                    'indicators': ['c2_communication']
                })
        
        return {
            'detected_toolkits': toolkits,
            'primary_toolkit': max(toolkits, key=lambda x: x['confidence'])['name'] if toolkits else None,
            'toolkit_count': len(toolkits)
        }
    
    def _identify_malware_family(self, attack_data: Dict[str, Any]) -> Dict[str, Any]:
        """Identify malware family and type"""
        behavior = attack_data.get('behavior', {})
        network = attack_data.get('network', {})
        
        # Malware family patterns
        malware_patterns = {
            'trojan': ['backdoor', 'remote_access', 'trojan'],
            'ransomware': ['encryption', 'ransom', 'file_lock'],
            'spyware': ['keylog', 'screen_capture', 'data_collection'],
            'rootkit': ['privilege_escalation', 'system_hook', 'hidden'],
            'botnet': ['c2_communication', 'distributed', 'command'],
            'apt': ['persistent', 'advanced', 'targeted', 'long_term']
        }
        
        matches = []
        for family, patterns in malware_patterns.items():
            score = sum(1 for pattern in patterns 
                       if any(pattern.lower() in str(v).lower() 
                             for v in behavior.values()))
            
            if score > 0:
                matches.append({
                    'family': family,
                    'confidence': min(0.95, score / len(patterns) * 0.8),
                    'indicators': score
                })
        
        return {
            'detected_families': matches,
            'primary_family': max(matches, key=lambda x: x['confidence'])['family'] if matches else 'unknown',
            'family_count': len(matches)
        }
    
    def _correlate_threat_actors(self, network_intel: Dict, toolkit: Dict, malware: Dict) -> Dict[str, Any]:
        """Correlate with known threat actor databases"""
        matches = []
        
        # Known threat actor patterns (fictional examples)
        threat_actors = {
            'apt28': {
                'toolkits': ['metasploit', 'cobalt_strike'],
                'malware': ['apt'],
                'regions': ['eastern_europe'],
                'tactics': ['spear_phishing', 'zero_day']
            },
            'lazarus': {
                'toolkits': ['custom'],
                'malware': ['trojan', 'ransomware'],
                'regions': ['asia'],
                'tactics': ['supply_chain', 'financial']
            },
            'fancy_bear': {
                'toolkits': ['metasploit'],
                'malware': ['apt', 'trojan'],
                'regions': ['eastern_europe'],
                'tactics': ['spear_phishing', 'social_engineering']
            }
        }
        
        primary_toolkit = toolkit.get('primary_toolkit', '')
        primary_malware = malware.get('primary_family', '')
        
        for actor_name, actor_data in threat_actors.items():
            score = 0
            
            # Match toolkits
            if primary_toolkit in actor_data['toolkits']:
                score += 0.3
            
            # Match malware
            if primary_malware in actor_data['malware']:
                score += 0.3
            
            # Match region (if available)
            region = network_intel.get('routes', [{}])[0].get('geolocation', {}).get('region', '')
            if region and region in str(actor_data.get('regions', [])):
                score += 0.2
            
            if score > 0.3:
                matches.append({
                    'threat_actor': actor_name,
                    'confidence': min(0.9, score),
                    'indicators': score
                })
        
        return {
            'potential_actors': matches,
            'primary_match': max(matches, key=lambda x: x['confidence'])['threat_actor'] if matches else None,
            'match_count': len(matches)
        }
    
    def _create_fingerprint(self, network: Dict, packets: Dict, toolkit: Dict, 
                           malware: Dict, threat_actor: Dict) -> Dict[str, Any]:
        """Create unique threat fingerprint"""
        # Combine all indicators
        indicators = []
        indicators.append(network.get('source_ip', 'unknown'))
        indicators.append(toolkit.get('primary_toolkit', 'unknown'))
        indicators.append(malware.get('primary_family', 'unknown'))
        indicators.append(threat_actor.get('primary_match', 'unknown'))
        
        # Create hash fingerprint
        fingerprint_string = '|'.join(str(i) for i in indicators)
        fingerprint_hash = hashlib.sha256(fingerprint_string.encode()).hexdigest()[:16]
        
        return {
            'id': f"attacker_{fingerprint_hash}",
            'hash': fingerprint_hash,
            'indicators': indicators,
            'created_at': datetime.utcnow().isoformat()
        }
    
    def _calculate_threat_level(self, attack_data: Dict, toolkit: Dict, malware: Dict) -> str:
        """Calculate threat level (low, medium, high, critical)"""
        score = 0
        
        # Toolkit sophistication
        if toolkit.get('toolkit_count', 0) > 2:
            score += 2
        elif toolkit.get('toolkit_count', 0) > 0:
            score += 1
        
        # Malware severity
        high_severity_families = ['apt', 'ransomware', 'rootkit']
        if malware.get('primary_family') in high_severity_families:
            score += 2
        elif malware.get('primary_family') != 'unknown':
            score += 1
        
        # Attack complexity
        behavior = attack_data.get('behavior', {})
        if behavior.get('privilege_escalation', 0) > 0:
            score += 1
        if behavior.get('persistence', False):
            score += 1
        
        # Determine level
        if score >= 5:
            return 'critical'
        elif score >= 3:
            return 'high'
        elif score >= 1:
            return 'medium'
        else:
            return 'low'
    
    def _calculate_confidence(self, toolkit: Dict, malware: Dict, threat_actor: Dict) -> float:
        """Calculate overall profiling confidence"""
        confidences = []
        
        if toolkit.get('primary_toolkit'):
            confidences.append(0.3)
        
        if malware.get('primary_family') != 'unknown':
            confidences.append(0.3)
        
        if threat_actor.get('primary_match'):
            confidences.append(0.4)
        
        return sum(confidences) if confidences else 0.0
    
    def _get_geolocation(self, ip: str) -> Dict[str, Any]:
        """Get geolocation for IP (simulated)"""
        # In production, use a geolocation API
        return {
            'country': 'unknown',
            'region': 'unknown',
            'city': 'unknown',
            'latitude': 0.0,
            'longitude': 0.0
        }
    
    def _detect_proxy(self, network_data: Dict[str, Any]) -> bool:
        """Detect if source is using proxy"""
        return network_data.get('is_proxy', False)
    
    def _detect_vpn(self, network_data: Dict[str, Any]) -> bool:
        """Detect if source is using VPN"""
        return network_data.get('is_vpn', False)
    
    def _detect_tor(self, network_data: Dict[str, Any]) -> bool:
        """Detect if source is using Tor"""
        return network_data.get('is_tor', False)
    
    def _extract_packet_signature(self, packet: Dict[str, Any]) -> Optional[str]:
        """Extract unique signature from packet"""
        payload = str(packet.get('payload', ''))
        if len(payload) > 10:
            return hashlib.md5(payload.encode()).hexdigest()[:8]
        return None
    
    def _detect_suspicious_patterns(self, packets: List[Dict[str, Any]]) -> List[str]:
        """Detect suspicious patterns in packets"""
        patterns = []
        
        suspicious_keywords = ['exploit', 'payload', 'shellcode', 'backdoor', 'trojan']
        
        for packet in packets:
            payload = str(packet.get('payload', '')).lower()
            for keyword in suspicious_keywords:
                if keyword in payload:
                    patterns.append(keyword)
        
        return list(set(patterns))
    
    def _load_known_threats(self):
        """Load known threat actor and malware databases"""
        # In production, load from external databases
        self.threat_actor_db = {}
        self.malware_families = {}
        self.toolkit_signatures = {}
