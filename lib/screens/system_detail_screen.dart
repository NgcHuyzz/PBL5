import 'package:flutter/material.dart';
import 'dart:async';
import '../services/system_service.dart';
import '../utils/app_theme.dart';

class SystemDetailScreen extends StatefulWidget {
  final String systemName;
  const SystemDetailScreen({super.key, required this.systemName});

  @override
  State<SystemDetailScreen> createState() => _SystemDetailScreenState();
}

class _SystemDetailScreenState extends State<SystemDetailScreen> {
  late Timer _timer;
    late String systemId;
  bool _isLoading = true;
  Map<String, dynamic> _controlState = {};
  Map<String, dynamic> _latestDetection = {};
  List<Map<String, dynamic>> _recentDetections = [];
  String _currentStatus = 'IDLE';

  @override
  void initState() {
    super.initState();
   systemId = 'c9fd27b7-a693-4a91-a144-2200c1dad56b';
    _loadData();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchControlState(),
      _fetchLatestDetection(),
      _fetchRecentDetections(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _fetchControlState(),
      _fetchLatestDetection(),
    ]);
    setState(() {});
  }

  Future<void> _fetchControlState() async {
    final result = await SystemService.getControlState(systemId);
    if (result['success'] == true) {
      setState(() {
        _controlState = result['data'] ?? {};
        _currentStatus = _controlState['systemStatus'] ?? 'IDLE';
      });
    }
  }

  Future<void> _fetchLatestDetection() async {
    final result = await SystemService.getLatestDetection(systemId);
    if (result['success'] == true) {
      setState(() {
        _latestDetection = result['data'] ?? {};
      });
    }
  }

  Future<void> _fetchRecentDetections() async {
    setState(() {
      _recentDetections = [
        {'fruit': 'Strawberry', 'confidence': 96, 'time': '10:44:12', 'bin': 'Bin 1', 'color': Colors.red},
        {'fruit': 'Raspberry', 'confidence': 92, 'time': '10:43:55', 'bin': 'Bin 2', 'color': Colors.pink},
        {'fruit': 'Strawberry', 'confidence': 99, 'time': '10:42:08', 'bin': 'Bin 1', 'color': Colors.red},
      ];
    });
  }

  Future<void> _handleControl(String action) async {
    await SystemService.controlSystem(systemId, action);
    await _fetchControlState();
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'RUNNING': return 'RUNNING';
      case 'PAUSED': return 'PAUSED';
      case 'STOPPED': return 'STOPPED';
      default: return 'IDLE';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'RUNNING': return Colors.green;
      case 'PAUSED': return Colors.orange;
      case 'STOPPED': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.systemName),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Status Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'TRẠNG THÁI HỆ THỐNG',
                          style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getStatusText(_currentStatus),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(_currentStatus),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Control Buttons
                  Row(
                    children: [
                      _buildControlButton('START', Icons.play_arrow, Colors.green, () => _handleControl('START')),
                      const SizedBox(width: 12),
                      _buildControlButton('PAUSE', Icons.pause, Colors.orange, () => _handleControl('PAUSE')),
                      const SizedBox(width: 12),
                      _buildControlButton('STOP', Icons.stop, Colors.red, () => _handleControl('STOP')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Live Analysis
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'LIVE ANALYSIS',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoColumn('LOẠI QUẢ', _latestDetection['fruitType'] ?? 'Strawberry', Icons.qr_code_scanner),
                            _buildInfoColumn('CONFIDENCE', '${((_latestDetection['confidence'] ?? 0.98) * 100).toInt()}%', Icons.trending_up),
                            _buildInfoColumn('BIN TARGET', _latestDetection['targetBin'] ?? 'BIN_1', Icons.inbox),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: AppTheme.textHint),
                            const SizedBox(width: 4),
                            Text(
                              _latestDetection['classifiedAt']?.toString().substring(11, 19) ?? '10:45:30',
                              style: AppTheme.caption,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Recent Classifications
                  const Text(
                    'PHÂN LOẠI GẦN ĐÂY',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 12),
                  ..._recentDetections.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: (item['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.qr_code_scanner, color: item['color'], size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['fruit'], style: AppTheme.titleMedium),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text('Confidence', style: AppTheme.caption),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item['confidence']}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: item['confidence'] > 95 ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(item['bin'], style: AppTheme.caption),
                                  const SizedBox(width: 12),
                                  Text(item['time'], style: AppTheme.caption),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppTheme.textHint),
                      ],
                    ),
                  )),
                ],
              ),
            ),
      );
  }

  Widget _buildControlButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(height: 8),
        Text(label, style: AppTheme.caption),
        const SizedBox(height: 4),
        Text(value, style: AppTheme.titleMedium),
      ],
    );
  }
}