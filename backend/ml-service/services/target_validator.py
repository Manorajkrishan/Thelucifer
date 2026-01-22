"""
Target Validation System
Validates attack sources before counter-offensive actions
"""

import logging
from typing import Dict, List, Any, Optional
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)


class TargetValidator:
    """Validate targets before counter-offensive actions"""
    
    def __init__(self):
        self.whitelist = set()  # IPs/domains to never attack
        self.blacklist = set()  # Confirmed malicious sources
        self.validation_history = []
    
    def validate_target(self, attacker_profile: Dict[str, Any], 
                       attack_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Validate if target is safe for counter-offensive
        
        Args:
            attacker_profile: Attacker profile from profiler
            attack_data: Original attack data
        
        Returns:
            Validation result with decision
        """
        try:
            validation_results = {
                'is_proxy': self._check_proxy(attacker_profile),
                'is_vpn': self._check_vpn(attacker_profile),
                'is_tor': self._check_tor(attacker_profile),
                'is_innocent': self._check_innocent_machine(attacker_profile, attack_data),
                'is_active_attack': self._check_active_attack(attack_data),
                'is_critical_threat': self._check_critical_threat(attacker_profile),
                'is_whitelisted': self._check_whitelist(attacker_profile),
                'is_blacklisted': self._check_blacklist(attacker_profile),
                'geolocation_risk': self._check_geolocation_risk(attacker_profile)
            }
            
            # Decision logic
            decision = self._make_decision(validation_results)
            
            validation_result = {
                'validated': decision['approved'],
                'decision': decision['action'],
                'reason': decision['reason'],
                'confidence': decision['confidence'],
                'validation_details': validation_results,
                'validated_at': datetime.utcnow().isoformat(),
                'attacker_id': attacker_profile.get('attacker_id', 'unknown')
            }
            
            # Store validation history
            self.validation_history.append(validation_result)
            
            logger.info(f"Target validation: {decision['action']} - {decision['reason']}")
            
            return validation_result
            
        except Exception as e:
            logger.error(f"Error validating target: {str(e)}")
            raise
    
    def _check_proxy(self, attacker_profile: Dict[str, Any]) -> Dict[str, Any]:
        """Check if source is a proxy"""
        network_intel = attacker_profile.get('network_intelligence', {})
        is_proxy = network_intel.get('has_proxy', False)
        
        return {
            'detected': is_proxy,
            'risk': 'high' if is_proxy else 'low',
            'reason': 'Proxy detected - may be innocent relay' if is_proxy else 'No proxy detected'
        }
    
    def _check_vpn(self, attacker_profile: Dict[str, Any]) -> Dict[str, Any]:
        """Check if source is using VPN"""
        network_intel = attacker_profile.get('network_intelligence', {})
        is_vpn = network_intel.get('has_vpn', False)
        
        return {
            'detected': is_vpn,
            'risk': 'medium' if is_vpn else 'low',
            'reason': 'VPN detected - may be legitimate user' if is_vpn else 'No VPN detected'
        }
    
    def _check_tor(self, attacker_profile: Dict[str, Any]) -> Dict[str, Any]:
        """Check if source is using Tor"""
        network_intel = attacker_profile.get('network_intelligence', {})
        is_tor = network_intel.get('has_tor', False)
        
        return {
            'detected': is_tor,
            'risk': 'medium' if is_tor else 'low',
            'reason': 'Tor detected - anonymous network' if is_tor else 'No Tor detected'
        }
    
    def _check_innocent_machine(self, attacker_profile: Dict[str, Any], 
                                attack_data: Dict[str, Any]) -> Dict[str, Any]:
        """Check if source might be an innocent compromised machine"""
        # Indicators of compromised innocent machine
        behavior = attack_data.get('behavior', {})
        
        indicators = {
            'low_privilege_escalation': behavior.get('privilege_escalation', 0) == 0,
            'minimal_persistence': not behavior.get('persistence', False),
            'single_session': behavior.get('session_count', 1) == 1,
            'no_data_exfiltration': behavior.get('data_exfiltration', 0) == 0
        }
        
        innocent_score = sum(1 for v in indicators.values() if v)
        is_innocent = innocent_score >= 3
        
        return {
            'detected': is_innocent,
            'score': innocent_score,
            'risk': 'high' if is_innocent else 'low',
            'reason': 'Possible innocent compromised machine' if is_innocent else 'Likely intentional attacker'
        }
    
    def _check_active_attack(self, attack_data: Dict[str, Any]) -> Dict[str, Any]:
        """Verify attack is active and ongoing"""
        timestamp = attack_data.get('timestamp', datetime.utcnow().isoformat())
        attack_time = datetime.fromisoformat(timestamp.replace('Z', '+00:00'))
        time_diff = datetime.utcnow() - attack_time.replace(tzinfo=None)
        
        is_recent = time_diff < timedelta(hours=1)
        is_active = attack_data.get('is_active', False)
        
        return {
            'detected': is_recent and is_active,
            'time_since_attack': str(time_diff),
            'risk': 'low' if is_recent and is_active else 'high',
            'reason': 'Active recent attack' if is_recent and is_active else 'Stale or inactive attack'
        }
    
    def _check_critical_threat(self, attacker_profile: Dict[str, Any]) -> Dict[str, Any]:
        """Check if threat level is critical"""
        threat_level = attacker_profile.get('threat_level', 'low')
        is_critical = threat_level == 'critical'
        
        return {
            'detected': is_critical,
            'threat_level': threat_level,
            'risk': 'low' if is_critical else 'high',
            'reason': f'Threat level: {threat_level}' + (' - Critical threat' if is_critical else ' - Non-critical')
        }
    
    def _check_whitelist(self, attacker_profile: Dict[str, Any]) -> Dict[str, Any]:
        """Check if source is whitelisted"""
        network_intel = attacker_profile.get('network_intelligence', {})
        source_ip = network_intel.get('routes', [{}])[0].get('source_ip', '')
        
        is_whitelisted = source_ip in self.whitelist
        
        return {
            'detected': is_whitelisted,
            'risk': 'high' if is_whitelisted else 'low',
            'reason': 'Source is whitelisted - DO NOT ATTACK' if is_whitelisted else 'Source not whitelisted'
        }
    
    def _check_blacklist(self, attacker_profile: Dict[str, Any]) -> Dict[str, Any]:
        """Check if source is blacklisted (confirmed malicious)"""
        network_intel = attacker_profile.get('network_intelligence', {})
        source_ip = network_intel.get('routes', [{}])[0].get('source_ip', '')
        
        is_blacklisted = source_ip in self.blacklist
        
        return {
            'detected': is_blacklisted,
            'risk': 'low' if is_blacklisted else 'medium',
            'reason': 'Source is blacklisted - confirmed malicious' if is_blacklisted else 'Source not in blacklist'
        }
    
    def _check_geolocation_risk(self, attacker_profile: Dict[str, Any]) -> Dict[str, Any]:
        """Check geolocation risk factors"""
        network_intel = attacker_profile.get('network_intelligence', {})
        geolocation = network_intel.get('routes', [{}])[0].get('geolocation', {})
        country = geolocation.get('country', 'unknown')
        
        # High-risk countries (example - fictional)
        high_risk_countries = ['unknown']  # Add actual high-risk countries if needed
        
        is_high_risk = country in high_risk_countries
        
        return {
            'country': country,
            'risk': 'high' if is_high_risk else 'medium',
            'reason': f'Geolocation: {country}'
        }
    
    def _make_decision(self, validation_results: Dict[str, Any]) -> Dict[str, Any]:
        """Make final decision based on validation results"""
        # Critical checks - if any fail, do not proceed
        if validation_results['is_whitelisted']['detected']:
            return {
                'approved': False,
                'action': 'block',
                'reason': 'Source is whitelisted - never attack',
                'confidence': 1.0
            }
        
        if validation_results['is_proxy']['detected']:
            return {
                'approved': False,
                'action': 'block',
                'reason': 'Source is proxy - may be innocent relay',
                'confidence': 0.8
            }
        
        if validation_results['is_innocent']['detected']:
            return {
                'approved': False,
                'action': 'block',
                'reason': 'Possible innocent compromised machine',
                'confidence': 0.7
            }
        
        # Positive indicators
        if not validation_results['is_active_attack']['detected']:
            return {
                'approved': False,
                'action': 'monitor',
                'reason': 'Attack is not active or recent',
                'confidence': 0.6
            }
        
        if not validation_results['is_critical_threat']['detected']:
            return {
                'approved': False,
                'action': 'block_only',
                'reason': 'Threat level not critical',
                'confidence': 0.7
            }
        
        # All checks passed - approve counter-offensive
        if validation_results['is_blacklisted']['detected']:
            confidence = 0.95
            reason = 'Confirmed malicious source - approved for counter-offensive'
        else:
            confidence = 0.85
            reason = 'Validated target - approved for counter-offensive'
        
        return {
            'approved': True,
            'action': 'counter_offensive',
            'reason': reason,
            'confidence': confidence
        }
    
    def add_to_whitelist(self, ip_or_domain: str):
        """Add IP/domain to whitelist"""
        self.whitelist.add(ip_or_domain)
        logger.info(f"Added to whitelist: {ip_or_domain}")
    
    def add_to_blacklist(self, ip_or_domain: str):
        """Add IP/domain to blacklist"""
        self.blacklist.add(ip_or_domain)
        logger.info(f"Added to blacklist: {ip_or_domain}")
