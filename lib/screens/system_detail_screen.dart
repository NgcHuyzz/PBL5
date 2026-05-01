import 'dart:async';

import 'package:flutter/material.dart';

import '../services/system_service.dart';
import '../utils/app_theme.dart';

class SystemDetailScreen extends StatefulWidget {
  final String systemName;
  final String? systemId;

  const SystemDetailScreen({
    super.key,
    required this.systemName,
    this.systemId,
  });

  @override
  State<SystemDetailScreen> createState() => _SystemDetailScreenState();
}

class _SystemDetailScreenState extends State<SystemDetailScreen> {
  Timer? _timer;
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _controlState = {};
  Map<String, dynamic> _latestDetection = {};
  List<Map<String, dynamic>> _recentDetections = [];
  String _currentStatus = 'IDLE';
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();

    if (widget.systemId == null || widget.systemId!.isEmpty) {
      _isLoading = false;
      _errorMessage = 'Chưa chọn hệ thống';
      return;
    }

    _loadData();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadToken() async {
    final token = await SystemService.getToken();
    if (mounted) {
      setState(() {
        _token = token;
      });
    }
  }

  Future<void> _loadData() async {
    if (widget.systemId == null || widget.systemId!.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Chưa chọn hệ thống';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.wait([
      _fetchControlState(),
      _fetchLatestDetection(),
      _fetchRecentDetections(),
    ]);

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _fetchControlState(),
      _fetchLatestDetection(),
      _fetchRecentDetections(),
    ]);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _fetchControlState() async {
    final systemId = widget.systemId;
    if (systemId == null) return;

    final result = await SystemService.getControlState(systemId);
    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _controlState = result['data'] ?? {};
        _currentStatus = _controlState['systemStatus'] ?? 'IDLE';
      });
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Không thể tải trạng thái';
      });
    }
  }

  Future<void> _fetchLatestDetection() async {
    final systemId = widget.systemId;
    if (systemId == null) return;

    final result = await SystemService.getLatestDetection(systemId);
    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _latestDetection = _asMap(result['data']);
      });
    }
  }

  Future<void> _fetchRecentDetections() async {
    final systemId = widget.systemId;
    if (systemId == null) return;

    final result = await SystemService.getRecentDetections(systemId);
    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _recentDetections = _extractList(result['data']);
      });
    }
  }

  Future<void> _handleControl(String action) async {
    final systemId = widget.systemId;
    if (systemId == null) return;

    final result = await SystemService.controlSystem(systemId, action);
    if (!mounted) return;

    if (result['success'] == true) {
      await _fetchControlState();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Điều khiển thất bại')),
      );
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'RUNNING':
        return 'RUNNING';
      case 'PAUSED':
        return 'PAUSED';
      case 'STOPPED':
        return 'STOPPED';
      default:
        return 'IDLE';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'RUNNING':
        return Colors.green;
      case 'PAUSED':
        return Colors.orange;
      case 'STOPPED':
        return Colors.red;
      default:
        return Colors.grey;
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
          : _errorMessage != null
          ? _buildMessageState(_errorMessage!)
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppTheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 20),
                    _buildControls(),
                    const SizedBox(height: 24),
                    _buildLiveAnalysis(),
                    const SizedBox(height: 24),
                    _buildRecentClassifications(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMessageState(String message) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 120),
        Icon(Icons.info_outline, size: 56, color: Colors.grey.shade500),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center, style: AppTheme.bodyMedium),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'TRẠNG THÁI HỆ THỐNG',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1,
            ),
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
    );
  }

  Widget _buildControls() {
    return Row(
      children: [
        _buildControlButton(
          'START',
          Icons.play_arrow,
          Colors.green,
          () => _handleControl('START'),
        ),
        const SizedBox(width: 12),
        _buildControlButton(
          'PAUSE',
          Icons.pause,
          Colors.orange,
          () => _handleControl('PAUSE'),
        ),
        const SizedBox(width: 12),
        _buildControlButton(
          'STOP',
          Icons.stop,
          Colors.red,
          () => _handleControl('STOP'),
        ),
      ],
    );
  }

  Widget _buildLiveAnalysis() {
    final fruitType = _latestDetection['fruitType']?.toString() ?? '---';
    final confidence = _asDouble(_latestDetection['confidence']);

    return Container(
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
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn('LOẠI QUẢ', fruitType, Icons.qr_code_scanner),
              _buildInfoColumn(
                'CONFIDENCE',
                '${(confidence * 100).toInt()}%',
                Icons.trending_up,
              ),
              _buildInfoColumn(
                'BIN TARGET',
                _latestDetection['targetBin']?.toString() ?? '---',
                Icons.inbox,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: AppTheme.textHint),
              const SizedBox(width: 4),
              Text(
                _formatTime(_latestDetection['classifiedAt']?.toString()),
                style: AppTheme.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentClassifications() {
    return Column(
      children: [
        const Text(
          'PHÂN LOẠI GẦN ĐÂY',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        if (_recentDetections.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Text(
              'Chưa có phân loại gần đây',
              textAlign: TextAlign.center,
              style: AppTheme.bodySmall,
            ),
          )
        else
          ..._recentDetections.map(_buildRecentDetectionCard),
      ],
    );
  }

  Widget _buildRecentDetectionCard(Map<String, dynamic> item) {
    final confidence = _asDouble(item['confidence']);
    final fruit =
        item['fruitType']?.toString() ?? item['fruit']?.toString() ?? '---';
    final bin =
        item['targetBin']?.toString() ?? item['bin']?.toString() ?? '---';
    final color = confidence >= 0.95 ? Colors.green : Colors.orange;
    final imageUrl = item['imageUrl']?.toString();

    return Container(
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
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              image: imageUrl != null && imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(
                        imageUrl,
                        headers: _token != null ? {'Authorization': 'Bearer $_token'} : null,
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null || imageUrl.isEmpty
                ? Icon(Icons.qr_code_scanner, color: color, size: 28)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fruit, style: AppTheme.titleMedium),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Confidence', style: AppTheme.caption),
                    const SizedBox(width: 4),
                    Text(
                      '${(confidence * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(bin, style: AppTheme.caption),
                    const SizedBox(width: 12),
                    Text(
                      _formatTime(item['classifiedAt']?.toString()),
                      style: AppTheme.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.textHint),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}

List<Map<String, dynamic>> _extractList(Object? value) {
  final source = value is Map
      ? value['content'] ?? value['items'] ?? value['detections']
      : value;

  if (source is! List) return [];

  return source
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _formatTime(String? isoString) {
  if (isoString == null || isoString.isEmpty) return '---';
  final parsed = DateTime.tryParse(isoString);
  if (parsed == null) return isoString;
  return '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}:${parsed.second.toString().padLeft(2, '0')}';
}
