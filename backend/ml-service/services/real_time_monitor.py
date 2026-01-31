"""
Real-Time Attack Detection & Auto-Response System
Continuously monitors for threats and automatically neutralizes + counter-attacks
"""

import logging
import time
import threading
from typing import Dict, List, Any, Callable
from datetime import datetime, timedelta
from queue import Queue
import psutil
import socket

logger = logging.getLogger(__name__)


class RealTimeMonitor:
    """
    Real-time monitoring system that:
    1. Monitors network traffic, USB connections, system behavior
    2. Detects attacks automatically
    3. Neutralizes threats
    4. Executes counter-offensive (simulated)
    """
    
    def __init__(self, threat_detector=None, counter_offensive_engine=None):
        self.threat_detector = threat_detector
        self.counter_offensive_engine = counter_offensive_engine
        
        self.is_monitoring = False
        self.monitor_thread = None
        self.event_queue = Queue()
        
        # Detection statistics
        self.stats = {
            'attacks_detected': 0,
            'attacks_neutralized': 0,
            'counter_offensives_executed': 0,
            'start_time': None,
            'last_detection': None
        }
        
        # Threat thresholds
        self.thresholds = {
            'connection_spike': 50,  # connections per minute
            'suspicious_ports': [4444, 4445, 5555, 31337, 8080, 1337],  # Common exploit ports
            'bandwidth_spike': 1000000,  # bytes per second
            'failed_auth_attempts': 5,
            'privilege_escalation_attempts': 1
        }
        
        # Whitelist (IPs to never counter-attack)
        self.whitelist = ['127.0.0.1', 'localhost', '::1']
        
        # Recent attacks (for deduplication)
        self.recent_attacks = {}
        
    def start_monitoring(self) -> Dict[str, Any]:
        """Start real-time monitoring"""
        if self.is_monitoring:
            return {'success': False, 'message': 'Already monitoring'}
        
        self.is_monitoring = True
        self.stats['start_time'] = datetime.utcnow().isoformat()
        
        # Start monitoring thread
        self.monitor_thread = threading.Thread(target=self._monitor_loop, daemon=True)
        self.monitor_thread.start()
        
        logger.info("Real-time monitoring started")
        
        return {
            'success': True,
            'message': 'Real-time monitoring started',
            'monitoring': True,
            'started_at': self.stats['start_time']
        }
    
    def stop_monitoring(self) -> Dict[str, Any]:
        """Stop real-time monitoring"""
        if not self.is_monitoring:
            return {'success': False, 'message': 'Not monitoring'}
        
        self.is_monitoring = False
        
        if self.monitor_thread:
            self.monitor_thread.join(timeout=5)
        
        logger.info("Real-time monitoring stopped")
        
        return {
            'success': True,
            'message': 'Real-time monitoring stopped',
            'monitoring': False,
            'stats': self.stats
        }
    
    def get_status(self) -> Dict[str, Any]:
        """Get monitoring status and statistics"""
        uptime = None
        if self.stats['start_time']:
            start = datetime.fromisoformat(self.stats['start_time'])
            uptime = str(datetime.utcnow() - start)
        
        return {
            'monitoring': self.is_monitoring,
            'stats': self.stats,
            'uptime': uptime,
            'thresholds': self.thresholds,
            'whitelist': self.whitelist
        }
    
    def _monitor_loop(self):
        """Main monitoring loop"""
        logger.info("Monitor loop started")
        
        while self.is_monitoring:
            try:
                # 1. Monitor Network Connections
                network_threats = self._monitor_network()
                if network_threats:
                    for threat in network_threats:
                        self._handle_threat(threat)
                
                # 2. Monitor USB Devices
                usb_threats = self._monitor_usb()
                if usb_threats:
                    for threat in usb_threats:
                        self._handle_threat(threat)
                
                # 3. Monitor System Behavior
                system_threats = self._monitor_system()
                if system_threats:
                    for threat in system_threats:
                        self._handle_threat(threat)
                
                # 4. Monitor Processes
                process_threats = self._monitor_processes()
                if process_threats:
                    for threat in process_threats:
                        self._handle_threat(threat)
                
                # Sleep before next cycle
                time.sleep(5)  # Check every 5 seconds
                
            except Exception as e:
                logger.error(f"Error in monitor loop: {e}")
                time.sleep(10)
    
    def _monitor_network(self) -> List[Dict[str, Any]]:
        """Monitor network connections for suspicious activity"""
        threats = []
        
        try:
            # Get all network connections
            connections = psutil.net_connections(kind='inet')
            
            # Count connections per IP
            connection_counts = {}
            suspicious_ports = []
            
            for conn in connections:
                if conn.status == 'ESTABLISHED' and conn.raddr:
                    remote_ip = conn.raddr.ip
                    remote_port = conn.raddr.port
                    
                    # Skip localhost and whitelist
                    if remote_ip in self.whitelist or remote_ip.startswith('127.'):
                        continue
                    
                    # Count connections
                    connection_counts[remote_ip] = connection_counts.get(remote_ip, 0) + 1
                    
                    # Check for suspicious ports
                    if remote_port in self.thresholds['suspicious_ports']:
                        suspicious_ports.append({
                            'ip': remote_ip,
                            'port': remote_port,
                            'local_port': conn.laddr.port if conn.laddr else 'unknown'
                        })
            
            # Detect connection spikes
            for ip, count in connection_counts.items():
                if count > self.thresholds['connection_spike']:
                    threats.append({
                        'type': 'network_attack',
                        'subtype': 'connection_spike',
                        'source_ip': ip,
                        'connection_count': count,
                        'severity': 'high',
                        'timestamp': datetime.utcnow().isoformat(),
                        'description': f'Suspicious connection spike from {ip}: {count} connections'
                    })
            
            # Detect suspicious port usage
            for port_info in suspicious_ports:
                threats.append({
                    'type': 'network_attack',
                    'subtype': 'suspicious_port',
                    'source_ip': port_info['ip'],
                    'port': port_info['port'],
                    'local_port': port_info['local_port'],
                    'severity': 'critical',
                    'timestamp': datetime.utcnow().isoformat(),
                    'description': f'Connection to suspicious port {port_info["port"]} from {port_info["ip"]}'
                })
        
        except Exception as e:
            logger.error(f"Error monitoring network: {e}")
        
        return threats
    
    def _monitor_usb(self) -> List[Dict[str, Any]]:
        """Monitor USB device connections"""
        threats = []
        
        try:
            # Get disk partitions
            partitions = psutil.disk_partitions()
            
            for partition in partitions:
                # Detect removable drives (potential USB attacks)
                if 'removable' in partition.opts.lower():
                    # Check if it's a new device
                    device_id = partition.device
                    
                    threats.append({
                        'type': 'usb_threat',
                        'subtype': 'unauthorized_usb',
                        'device': device_id,
                        'mountpoint': partition.mountpoint,
                        'severity': 'medium',
                        'timestamp': datetime.utcnow().isoformat(),
                        'description': f'USB device detected: {device_id} at {partition.mountpoint}'
                    })
        
        except Exception as e:
            logger.error(f"Error monitoring USB: {e}")
        
        return threats
    
    def _monitor_system(self) -> List[Dict[str, Any]]:
        """Monitor system behavior for anomalies"""
        threats = []
        
        try:
            # Monitor CPU usage spikes
            cpu_percent = psutil.cpu_percent(interval=1)
            if cpu_percent > 90:
                threats.append({
                    'type': 'system_anomaly',
                    'subtype': 'cpu_spike',
                    'cpu_usage': cpu_percent,
                    'severity': 'medium',
                    'timestamp': datetime.utcnow().isoformat(),
                    'description': f'CPU usage spike: {cpu_percent}%'
                })
            
            # Monitor memory usage
            memory = psutil.virtual_memory()
            if memory.percent > 90:
                threats.append({
                    'type': 'system_anomaly',
                    'subtype': 'memory_spike',
                    'memory_usage': memory.percent,
                    'severity': 'medium',
                    'timestamp': datetime.utcnow().isoformat(),
                    'description': f'Memory usage spike: {memory.percent}%'
                })
            
            # Monitor network bandwidth
            net_io = psutil.net_io_counters()
            bytes_sent = net_io.bytes_sent
            bytes_recv = net_io.bytes_recv
            
            # Store previous values for rate calculation
            if not hasattr(self, '_prev_net_io'):
                self._prev_net_io = net_io
            else:
                sent_rate = bytes_sent - self._prev_net_io.bytes_sent
                recv_rate = bytes_recv - self._prev_net_io.bytes_recv
                
                if sent_rate > self.thresholds['bandwidth_spike'] or recv_rate > self.thresholds['bandwidth_spike']:
                    threats.append({
                        'type': 'system_anomaly',
                        'subtype': 'bandwidth_spike',
                        'sent_rate': sent_rate,
                        'recv_rate': recv_rate,
                        'severity': 'high',
                        'timestamp': datetime.utcnow().isoformat(),
                        'description': f'Network bandwidth spike detected'
                    })
                
                self._prev_net_io = net_io
        
        except Exception as e:
            logger.error(f"Error monitoring system: {e}")
        
        return threats
    
    def _monitor_processes(self) -> List[Dict[str, Any]]:
        """Monitor running processes for suspicious activity"""
        threats = []
        
        try:
            # Get all running processes
            for proc in psutil.process_iter(['pid', 'name', 'username', 'connections']):
                try:
                    # Detect processes running as root/admin unexpectedly
                    if proc.info['username'] in ['root', 'SYSTEM']:
                        # Check for suspicious process names
                        suspicious_names = ['nc', 'ncat', 'metasploit', 'mimikatz', 'psexec']
                        proc_name = proc.info['name'].lower()
                        
                        for sus_name in suspicious_names:
                            if sus_name in proc_name:
                                threats.append({
                                    'type': 'process_threat',
                                    'subtype': 'suspicious_process',
                                    'process_name': proc.info['name'],
                                    'pid': proc.info['pid'],
                                    'username': proc.info['username'],
                                    'severity': 'critical',
                                    'timestamp': datetime.utcnow().isoformat(),
                                    'description': f'Suspicious process detected: {proc.info["name"]}'
                                })
                
                except (psutil.NoSuchProcess, psutil.AccessDenied):
                    pass
        
        except Exception as e:
            logger.error(f"Error monitoring processes: {e}")
        
        return threats
    
    def _handle_threat(self, threat: Dict[str, Any]):
        """Handle detected threat: neutralize and counter-attack"""
        try:
            # Check if this is a duplicate (within last 60 seconds)
            threat_key = f"{threat['type']}_{threat.get('source_ip', threat.get('device', 'unknown'))}"
            
            if threat_key in self.recent_attacks:
                last_seen = self.recent_attacks[threat_key]
                if (datetime.utcnow() - last_seen).total_seconds() < 60:
                    return  # Skip duplicate
            
            self.recent_attacks[threat_key] = datetime.utcnow()
            
            # Update stats
            self.stats['attacks_detected'] += 1
            self.stats['last_detection'] = datetime.utcnow().isoformat()
            
            logger.warning(f"THREAT DETECTED: {threat['description']}")
            
            # 1. NEUTRALIZE the threat
            neutralization_result = self._neutralize_threat(threat)
            
            if neutralization_result['success']:
                self.stats['attacks_neutralized'] += 1
                logger.info(f"THREAT NEUTRALIZED: {threat['description']}")
            
            # 2. COUNTER-ATTACK (if enabled and threat is critical)
            if threat['severity'] in ['high', 'critical'] and self.counter_offensive_engine:
                # Build attack data for counter-offensive
                attack_data = self._build_attack_data(threat)
                
                # Profile the attacker
                from services.attacker_profiler import AttackerProfiler
                profiler = AttackerProfiler()
                attacker_profile = profiler.profile_attacker(attack_data)
                
                # Validate target
                from services.target_validator import TargetValidator
                validator = TargetValidator()
                validation_result = validator.validate_target(attacker_profile, attack_data)
                
                # Execute counter-offensive if validated
                if validation_result['validated']:
                    counter_result = self.counter_offensive_engine.execute_counter_offensive(
                        attacker_profile,
                        validation_result
                    )
                    
                    if counter_result['success']:
                        self.stats['counter_offensives_executed'] += 1
                        logger.warning(f"COUNTER-OFFENSIVE EXECUTED: {threat['description']}")
                        logger.warning(f"Warning: {counter_result.get('warning', 'SIMULATION ONLY')}")
        
        except Exception as e:
            logger.error(f"Error handling threat: {e}")
    
    def _neutralize_threat(self, threat: Dict[str, Any]) -> Dict[str, Any]:
        """Neutralize the detected threat"""
        try:
            threat_type = threat['type']
            
            if threat_type == 'network_attack':
                # Block the malicious IP (simulated)
                source_ip = threat.get('source_ip')
                logger.warning(f"NEUTRALIZING: Blocking IP {source_ip} (SIMULATED)")
                return {
                    'success': True,
                    'action': 'ip_blocked',
                    'target': source_ip,
                    'note': 'SIMULATED - In production, would add firewall rule'
                }
            
            elif threat_type == 'usb_threat':
                # Disable USB device (simulated)
                device = threat.get('device')
                logger.warning(f"NEUTRALIZING: Disabling USB device {device} (SIMULATED)")
                return {
                    'success': True,
                    'action': 'usb_disabled',
                    'target': device,
                    'note': 'SIMULATED - In production, would unmount and block device'
                }
            
            elif threat_type == 'process_threat':
                # Kill suspicious process (simulated)
                pid = threat.get('pid')
                process_name = threat.get('process_name')
                logger.warning(f"NEUTRALIZING: Terminating process {process_name} (PID: {pid}) (SIMULATED)")
                return {
                    'success': True,
                    'action': 'process_killed',
                    'target': f"{process_name} (PID: {pid})",
                    'note': 'SIMULATED - In production, would kill process'
                }
            
            else:
                # Generic neutralization
                logger.warning(f"NEUTRALIZING: Generic response to {threat_type} (SIMULATED)")
                return {
                    'success': True,
                    'action': 'generic_neutralization',
                    'target': threat_type,
                    'note': 'SIMULATED'
                }
        
        except Exception as e:
            logger.error(f"Error neutralizing threat: {e}")
            return {'success': False, 'error': str(e)}
    
    def _build_attack_data(self, threat: Dict[str, Any]) -> Dict[str, Any]:
        """Build attack data structure for counter-offensive"""
        return {
            'network': {
                'source_ip': threat.get('source_ip', 'unknown'),
                'destination_ip': self._get_local_ip(),
                'connection_count': threat.get('connection_count', 1),
                'port': threat.get('port', 0),
                'is_proxy': False,
                'is_vpn': False
            },
            'behavior': {
                'privilege_escalation': 1 if threat['type'] == 'process_threat' else 0,
                'suspicious_file_access': 5 if threat['type'] == 'usb_threat' else 0,
                'unusual_network_activity': 10 if threat['type'] == 'network_attack' else 0,
                'persistence': True
            },
            'timestamp': threat['timestamp'],
            'is_active': True,
            'severity': threat['severity']
        }
    
    def _get_local_ip(self) -> str:
        """Get local IP address"""
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except:
            return '127.0.0.1'
