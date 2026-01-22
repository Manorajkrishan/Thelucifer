"""
Continuous War Loop
Monitors for retaliation and evolves counter-offensive strategies
"""

import logging
from typing import Dict, List, Any, Optional
from datetime import datetime, timedelta
import threading
import time

logger = logging.getLogger(__name__)


class ContinuousWarLoop:
    """Continuous monitoring and evolution of counter-offensive strategies"""
    
    def __init__(self):
        self.monitoring_active = False
        self.retaliation_events = []
        self.evolution_history = []
        self.strategy_adaptations = {}
        self.monitor_thread = None
    
    def start_monitoring(self, attacker_id: str, attack_profile: Dict[str, Any]):
        """Start continuous monitoring for retaliation"""
        self.monitoring_active = True
        
        if not self.monitor_thread or not self.monitor_thread.is_alive():
            self.monitor_thread = threading.Thread(
                target=self._monitoring_loop,
                daemon=True
            )
            self.monitor_thread.start()
        
        logger.info(f"Started monitoring for retaliation from {attacker_id}")
    
    def stop_monitoring(self):
        """Stop continuous monitoring"""
        self.monitoring_active = False
        logger.info("Stopped monitoring")
    
    def detect_retaliation(self, network_data: Dict[str, Any]) -> Dict[str, Any]:
        """Detect if attacker is retaliating"""
        try:
            source_ip = network_data.get('source_ip', '')
            attack_patterns = network_data.get('attack_patterns', [])
            
            # Check for retaliation indicators
            retaliation_indicators = {
                'increased_activity': network_data.get('connection_count', 0) > 100,
                'new_attack_vectors': len(attack_patterns) > 5,
                'escalated_aggression': network_data.get('threat_level', 'low') == 'critical',
                'targeted_response': 'counter' in str(attack_patterns).lower()
            }
            
            is_retaliation = sum(retaliation_indicators.values()) >= 2
            
            if is_retaliation:
                retaliation_event = {
                    'detected_at': datetime.utcnow().isoformat(),
                    'source_ip': source_ip,
                    'indicators': retaliation_indicators,
                    'severity': 'high' if sum(retaliation_indicators.values()) >= 3 else 'medium'
                }
                
                self.retaliation_events.append(retaliation_event)
                logger.warning(f"Retaliation detected from {source_ip}")
                
                return {
                    'detected': True,
                    'event': retaliation_event,
                    'recommended_action': 'escalate_defense'
                }
            
            return {
                'detected': False,
                'indicators': retaliation_indicators
            }
            
        except Exception as e:
            logger.error(f"Error detecting retaliation: {str(e)}")
            return {'detected': False, 'error': str(e)}
    
    def evolve_strategy(self, attack_history: List[Dict[str, Any]], 
                       success_rates: Dict[str, float]) -> Dict[str, Any]:
        """Evolve counter-offensive strategies based on results"""
        try:
            # Analyze successful strategies
            successful_strategies = []
            for attack in attack_history:
                if attack.get('success', False):
                    strategy = attack.get('strategy', {})
                    successful_strategies.append(strategy)
            
            # Identify most effective strategies
            strategy_effectiveness = {}
            for strategy_dict in successful_strategies:
                for strategy_type, used in strategy_dict.items():
                    if used:
                        strategy_effectiveness[strategy_type] = strategy_effectiveness.get(strategy_type, 0) + 1
            
            # Evolve payloads
            evolved_payloads = self._evolve_payloads(attack_history)
            
            # Adapt tactics
            adapted_tactics = self._adapt_tactics(success_rates)
            
            evolution = {
                'evolved_at': datetime.utcnow().isoformat(),
                'strategy_effectiveness': strategy_effectiveness,
                'evolved_payloads': evolved_payloads,
                'adapted_tactics': adapted_tactics,
                'recommendations': self._generate_recommendations(strategy_effectiveness)
            }
            
            self.evolution_history.append(evolution)
            self.strategy_adaptations[datetime.utcnow().isoformat()] = evolution
            
            logger.info("Strategy evolution completed")
            
            return evolution
            
        except Exception as e:
            logger.error(f"Error evolving strategy: {str(e)}")
            raise
    
    def _monitoring_loop(self):
        """Continuous monitoring loop"""
        while self.monitoring_active:
            try:
                # Check for recent retaliation events
                recent_events = [
                    e for e in self.retaliation_events
                    if datetime.fromisoformat(e['detected_at'].replace('Z', '+00:00')) > 
                       datetime.utcnow() - timedelta(hours=1)
                ]
                
                if recent_events:
                    logger.warning(f"Active retaliation detected: {len(recent_events)} events")
                
                time.sleep(60)  # Check every minute
                
            except Exception as e:
                logger.error(f"Error in monitoring loop: {str(e)}")
                time.sleep(60)
    
    def _evolve_payloads(self, attack_history: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Evolve counter-offensive payloads"""
        # Analyze which payloads were most effective
        payload_usage = {}
        
        for attack in attack_history:
            actions = attack.get('actions', [])
            for action in actions:
                payload_type = action.get('payload_type', 'unknown')
                payload_usage[payload_type] = payload_usage.get(payload_type, 0) + 1
        
        # Generate evolved payload variants
        evolved = {
            'network_saturation_v2': {
                'improvements': ['increased_bandwidth', 'multi_vector'],
                'effectiveness': 'high'
            },
            'malware_v2': {
                'improvements': ['stealth_mode', 'persistence'],
                'effectiveness': 'high'
            }
        }
        
        return evolved
    
    def _adapt_tactics(self, success_rates: Dict[str, float]) -> Dict[str, Any]:
        """Adapt tactics based on success rates"""
        adaptations = {}
        
        for tactic, rate in success_rates.items():
            if rate > 0.8:
                adaptations[tactic] = {
                    'action': 'maintain',
                    'reason': 'High success rate'
                }
            elif rate < 0.5:
                adaptations[tactic] = {
                    'action': 'modify',
                    'reason': 'Low success rate',
                    'suggestions': ['increase_intensity', 'change_approach']
                }
            else:
                adaptations[tactic] = {
                    'action': 'optimize',
                    'reason': 'Moderate success rate'
                }
        
        return adaptations
    
    def _generate_recommendations(self, strategy_effectiveness: Dict[str, int]) -> List[str]:
        """Generate recommendations based on strategy effectiveness"""
        recommendations = []
        
        if not strategy_effectiveness:
            recommendations.append("Insufficient data - continue monitoring")
            return recommendations
        
        # Find most effective strategy
        most_effective = max(strategy_effectiveness.items(), key=lambda x: x[1])
        recommendations.append(f"Continue using {most_effective[0]} - most effective strategy")
        
        # Find least effective
        if len(strategy_effectiveness) > 1:
            least_effective = min(strategy_effectiveness.items(), key=lambda x: x[1])
            recommendations.append(f"Review {least_effective[0]} - lower effectiveness")
        
        recommendations.append("Monitor for new attack patterns")
        recommendations.append("Update payloads based on attacker responses")
        
        return recommendations
    
    def get_war_status(self) -> Dict[str, Any]:
        """Get current war loop status"""
        return {
            'monitoring_active': self.monitoring_active,
            'retaliation_events_count': len(self.retaliation_events),
            'recent_retaliations': len([
                e for e in self.retaliation_events
                if datetime.fromisoformat(e['detected_at'].replace('Z', '+00:00')) > 
                   datetime.utcnow() - timedelta(hours=24)
            ]),
            'evolution_count': len(self.evolution_history),
            'last_evolution': self.evolution_history[-1]['evolved_at'] if self.evolution_history else None
        }
