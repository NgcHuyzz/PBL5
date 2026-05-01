import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import '../services/system_service.dart';
import '../utils/theme.dart';

class DashboardScreen extends StatefulWidget {
  final String? systemId;
  const DashboardScreen({super.key, this.systemId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _timer;
  String? _systemId;

  bool _isLoading = true;
  Map<String, dynamic> _controlState = {};
  Map<String, dynamic> _latestDetection = {};
  String _errorMessage = '';
  String _currentSystemStatus = 'IDLE';

  @override
  void initState() {
    super.initState();
    _systemId = widget.systemId;
    if (_systemId == null || _systemId!.isEmpty) {
      _isLoading = false;
      _errorMessage = 'Chưa chọn hệ thống';
      return;
    }

    _loadDashboardData();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    if (_systemId == null || _systemId!.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Chưa chọn hệ thống';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    await Future.wait([_fetchControlState(), _fetchLatestDetection()]);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    await Future.wait([_fetchControlState(), _fetchLatestDetection()]);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _fetchControlState() async {
    final systemId = _systemId;
    if (systemId == null) return;

    final result = await SystemService.getControlState(systemId);
    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _controlState = result['data'] ?? {};
        _currentSystemStatus = _controlState['systemStatus'] ?? 'IDLE';
      });
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Lỗi không xác định';
      });
    }
  }

  Future<void> _fetchLatestDetection() async {
    final systemId = _systemId;
    if (systemId == null) return;

    final result = await SystemService.getLatestDetection(systemId);
    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _latestDetection = result['data'] ?? {};
      });
    }
  }

  Future<void> _handleControl(String action) async {
    final systemId = _systemId;
    if (systemId == null) return;

    final result = await SystemService.controlSystem(systemId, action);
    if (!mounted) return;

    if (result['success'] == true) {
      await _fetchControlState();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã ${action == 'START'
                ? 'khởi động'
                : action == 'PAUSE'
                ? 'tạm dừng'
                : 'dừng'} hệ thống',
          ),
          backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Điều khiển thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'RUNNING':
        return 'Đang chạy';
      case 'PAUSED':
        return 'Tạm dừng';
      case 'STOPPED':
        return 'Đã dừng';
      case 'ERROR':
        return 'Lỗi';
      default:
        return 'Chờ';
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
      case 'ERROR':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getFruitName(String fruitType) {
    switch (fruitType) {
      case 'apple':
        return '🍎 Táo';
      case 'banana':
        return '🍌 Chuối';
      case 'orange':
        return '🍊 Cam';
      case 'strawberry':
        return '🍓 Dâu tây';
      case 'mango':
        return '🥭 Xoài';
      default:
        return fruitType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadDashboardData,
            color: AppTheme.primaryGreen,
            child: _isLoading
                ? _buildShimmerLoading()
                : _errorMessage.isNotEmpty
                ? _buildMessageState(_errorMessage)
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        _buildHeader(),
                        const SizedBox(height: 24),

                        // Control State Card
                        _buildControlStateCard()
                            .animate()
                            .fadeIn(duration: 300.ms)
                            .slideY(begin: 0.1),
                        const SizedBox(height: 20),

                        // Control Buttons
                        _buildControlButtons()
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.1),
                        const SizedBox(height: 20),

                        // Latest Detection Card
                        _buildLatestDetectionCard()
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.1),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageState(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 120),
        Icon(Icons.info_outline, size: 56, color: Colors.grey.shade500),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center, style: AppTheme.bodyStyle),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.qr_code_scanner,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fruit Sorter', style: AppTheme.headingStyle),
            Text('Hệ thống phân loại thông minh', style: AppTheme.bodyStyle),
          ],
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlStateCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.toggle_on, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Trạng thái hệ thống',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Trạng thái:',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        _getStatusText(_currentSystemStatus),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(_currentSystemStatus),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.control_camera, color: AppTheme.primaryGreen),
                const SizedBox(width: 12),
                Text('Điều khiển hệ thống', style: AppTheme.subheadingStyle),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: Icons.play_arrow,
                  label: 'Start',
                  color: Colors.green,
                  onPressed: _currentSystemStatus == 'RUNNING'
                      ? null
                      : () => _handleControl('START'),
                ),
                _buildControlButton(
                  icon: Icons.pause,
                  label: 'Pause',
                  color: Colors.orange,
                  onPressed: _currentSystemStatus == 'PAUSED'
                      ? null
                      : () => _handleControl('PAUSE'),
                ),
                _buildControlButton(
                  icon: Icons.stop,
                  label: 'Stop',
                  color: Colors.red,
                  onPressed: _currentSystemStatus == 'STOPPED'
                      ? null
                      : () => _handleControl('STOP'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
              elevation: onPressed == null ? 0 : 4,
            ),
            child: Icon(icon, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildLatestDetectionCard() {
    if (_latestDetection.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.hourglass_empty,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'Chưa có dữ liệu phân loại',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange.shade50, Colors.white],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.qr_code_scanner, color: Colors.orange),
                  SizedBox(width: 12),
                  Text(
                    'Kết quả phân loại mới nhất',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Text(
                      _getFruitName(
                        _latestDetection['fruitType']?.toString() ?? '?',
                      ),
                      style: const TextStyle(fontSize: 56),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Độ tin cậy: ${(_asDouble(_latestDetection['confidence']) * 100).toInt()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ID:',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        Text(_latestDetection['id']?.toString() ?? '---'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Thời gian:',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        Text(
                          _latestDetection['classifiedAt']?.toString() ?? '---',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
