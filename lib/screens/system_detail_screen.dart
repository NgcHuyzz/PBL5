import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/system_service.dart';
import '../utils/app_sizes.dart';
import '../widgets/notification_bell_button.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'statistics_screen.dart';

const Color _primary = Color(0xFF8C0011);
const Color _primaryContainer = Color(0xFFB01E23);
const Color _secondary = Color(0xFF3B6934);
const Color _secondaryContainer = Color(0xFFB9EEAB);
const Color _onSecondaryContainer = Color(0xFF3F6D38);
const Color _error = Color(0xFFBA1A1A);
const Color _errorContainer = Color(0xFFFFDAD6);
const Color _onErrorContainer = Color(0xFF93000A);
const Color _surface = Color(0xFFFCF9F8);
const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
const Color _surfaceContainerLow = Color(0xFFF6F3F2);
const Color _surfaceVariant = Color(0xFFE5E2E1);
const Color _onSurface = Color(0xFF1B1C1C);
const Color _onSurfaceVariant = Color(0xFF5A403E);
const Color _outlineVariant = Color(0xFFE3BEBB);
const bool _showHardwareControls = false;

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
        _controlState = _asMap(result['data']);
        _currentStatus =
            _controlState['systemStatus']?.toString() ??
            _controlState['status']?.toString() ??
            'IDLE';
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

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  void _openStatistics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatisticsScreen(
          systemId: widget.systemId,
          systemName: widget.systemName,
        ),
      ),
    );
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(
          systemId: widget.systemId,
          systemName: widget.systemName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 70,
        leadingWidth: 52,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          color: _primaryContainer,
          tooltip: 'Quay lại',
        ),
        titleSpacing: 0,
        title: Text(
          widget.systemName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            color: _primaryContainer,
            fontSize: AppSizes.fontHeadlineMedium,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          NotificationBellButton(
            systemId: widget.systemId,
            color: _onSurfaceVariant,
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.spacingL),
            child: InkWell(
              onTap: _openProfile,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _surfaceContainerLow,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _outlineVariant.withValues(alpha: 0.45),
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: _primaryContainer,
                  size: AppSizes.iconMedium,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : _errorMessage != null
          ? _buildMessageState(_errorMessage!)
          : RefreshIndicator(
              onRefresh: _loadData,
              color: _primary,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(AppSizes.spacingXL, AppSizes.spacingXXL, AppSizes.spacingXL, AppSizes.spacingXXL),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildStatusCard(),
                            const SizedBox(height: AppSizes.spacingXXL),
                            // Hardware controls are hidden until firmware support is ready.
                            if (_showHardwareControls) ...[
                              _buildControls(),
                              const SizedBox(height: AppSizes.spacingXXL),
                            ],
                            _buildLatestDetection(constraints.maxWidth),
                            const SizedBox(height: AppSizes.spacingXXL),
                            _buildRecentClassifications(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: _SystemBottomNav(
        onHome: () {},
        onStatistics: _openStatistics,
        onHistory: _openHistory,
      ),
    );
  }

  Widget _buildMessageState(String message) {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.spacingXXL),
      children: [
        const SizedBox(height: 96),
        Icon(Icons.info_outline_rounded, size: AppSizes.iconXXLarge, color: _onSurfaceVariant),
        const SizedBox(height: AppSizes.spacingL),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: AppSizes.fontBody, color: _onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    final status = _statusStyle(_currentStatus);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingXXL),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: _softShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRẠNG THÁI HỆ THỐNG',
                  style: GoogleFonts.inter(
                    color: _onSurfaceVariant,
                    fontSize: AppSizes.fontBody,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingM),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: status.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingM),
                    Flexible(
                      child: Text(
                        status.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          color: status.color,
                          fontSize: AppSizes.fontDisplaySmall,
                          height: 1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.spacingL),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: status.containerColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Icon(
              Icons.precision_manufacturing_rounded,
              color: status.iconColor,
              size: AppSizes.iconLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      children: [
        _buildControlTile(
          label: 'START',
          icon: Icons.play_arrow_rounded,
          color: _secondary,
          isMuted: _currentStatus.toUpperCase() == 'RUNNING',
          onPressed: () => _handleControl('START'),
        ),
        const SizedBox(width: AppSizes.spacingM),
        _buildControlTile(
          label: 'PAUSE',
          icon: Icons.pause_rounded,
          color: _primary,
          onPressed: () => _handleControl('PAUSE'),
        ),
        const SizedBox(width: AppSizes.spacingM),
        _buildControlTile(
          label: 'STOP',
          icon: Icons.stop_rounded,
          color: _error,
          onPressed: () => _handleControl('STOP'),
        ),
      ],
    );
  }

  Widget _buildControlTile({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool isMuted = false,
  }) {
    return Expanded(
      child: SizedBox(
        height: 86,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isMuted ? _surfaceContainerLow : _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            boxShadow: isMuted ? null : _softShadow,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: AppSizes.iconLarge,
                    color: isMuted ? _onSurface.withValues(alpha: 0.28) : color,
                  ),
                  const SizedBox(height: AppSizes.spacingS),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: isMuted
                          ? _onSurface.withValues(alpha: 0.34)
                          : _onSurface,
                      fontSize: AppSizes.fontBody,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLatestDetection(double availableWidth) {
    final fruitType = _detectionFruit(_latestDetection);
    final confidence = _asDouble(_latestDetection['confidence']);
    final targetBin = _detectionBin(_latestDetection);
    final imageUrl = _latestDetection['imageUrl']?.toString();
    final isWide = availableWidth >= 760;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Kết quả mới nhất'),
        const SizedBox(height: AppSizes.spacingXL),
        Container(
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            boxShadow: _softShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: isWide
              ? Row(
                  children: [
                    Expanded(
                      child: _DetectionImage(imageUrl: imageUrl, token: _token),
                    ),
                    Expanded(
                      child: _LatestDetectionDetails(
                        fruitType: fruitType,
                        confidence: confidence,
                        targetBin: targetBin,
                        time: _formatTime(
                          _latestDetection['classifiedAt']?.toString(),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _DetectionImage(imageUrl: imageUrl, token: _token),
                    _LatestDetectionDetails(
                      fruitType: fruitType,
                      confidence: confidence,
                      targetBin: targetBin,
                      time: _formatTime(
                        _latestDetection['classifiedAt']?.toString(),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildRecentClassifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Phân loại gần đây'),
        const SizedBox(height: AppSizes.spacingXL),
        if (_recentDetections.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.spacingXL),
            decoration: BoxDecoration(
              color: _surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              boxShadow: _softShadow,
            ),
            child: Text(
              'Chưa có phân loại gần đây',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: AppSizes.fontBody, color: _onSurfaceVariant),
            ),
          )
        else
          ..._recentDetections.map(_buildRecentDetectionCard),
      ],
    );
  }

  Widget _buildRecentDetectionCard(Map<String, dynamic> item) {
    final confidence = _asDouble(item['confidence']);
    final fruit = _detectionFruit(item);
    final bin = _detectionBin(item);
    final imageUrl = item['imageUrl']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: _softShadow,
      ),
      child: Row(
        children: [
          _RecentThumb(imageUrl: imageUrl, token: _token),
          const SizedBox(width: AppSizes.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fruit,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: _onSurface,
                    fontSize: AppSizes.fontTitleLarge,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingXS),
                Text(
                  '${_formatTime(item['classifiedAt']?.toString())} • $bin',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: _onSurfaceVariant,
                    fontSize: AppSizes.fontBody,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.spacingM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatConfidence(confidence),
                style: GoogleFonts.inter(
                  color: _secondary,
                  fontSize: AppSizes.fontTitleLarge,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Confidence',
                style: GoogleFonts.inter(
                  color: _onSurfaceVariant,
                  fontSize: AppSizes.fontCaption,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SystemBottomNav extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onStatistics;
  final VoidCallback onHistory;

  const _SystemBottomNav({
    required this.onHome,
    required this.onStatistics,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingXL, vertical: AppSizes.spacingS),
        decoration: BoxDecoration(
          color: _surfaceContainerLowest,
          border: Border(
            top: BorderSide(color: _outlineVariant.withValues(alpha: 0.15)),
          ),
          boxShadow: [
            BoxShadow(
              color: _onSurfaceVariant.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SystemBottomNavItem(
              icon: Icons.home_rounded,
              label: 'Trang chủ',
              isSelected: true,
              onTap: onHome,
            ),
            _SystemBottomNavItem(
              icon: Icons.analytics_rounded,
              label: 'Thống kê',
              onTap: onStatistics,
            ),
            _SystemBottomNavItem(
              icon: Icons.history_rounded,
              label: 'Lịch sử',
              onTap: onHistory,
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemBottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SystemBottomNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? _primaryContainer : _onSurfaceVariant;

    return Expanded(
      child: Center(
        child: Material(
          color: isSelected
              ? const Color(0xFFFFDAD6).withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            child: Container(
              constraints: const BoxConstraints(minWidth: 78),
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingM, vertical: AppSizes.spacingXS),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: AppSizes.iconMedium),
                  const SizedBox(height: AppSizes.spacingXS),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: color,
                      fontSize: AppSizes.fontCaption,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingXS),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          color: _onSurface,
          fontSize: AppSizes.fontHeadlineLarge,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DetectionImage extends StatelessWidget {
  final String? imageUrl;
  final String? token;

  const _DetectionImage({required this.imageUrl, required this.token});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;

    return AspectRatio(
      aspectRatio: 1.15,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url != null && url.isNotEmpty)
            Image.network(
              url,
              fit: BoxFit.cover,
              headers: token != null
                  ? {'Authorization': 'Bearer $token'}
                  : null,
            )
          else
            Container(
              color: const Color(0xFF17272C),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Color(0xFFB9EEAB),
                size: 72,
              ),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingM, vertical: AppSizes.spacingS),
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Text(
                'LIVE ANALYSIS',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: AppSizes.fontBody,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LatestDetectionDetails extends StatelessWidget {
  final String fruitType;
  final double confidence;
  final String targetBin;
  final String time;

  const _LatestDetectionDetails({
    required this.fruitType,
    required this.confidence,
    required this.targetBin,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacingXXL),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: AppSizes.spacingL,
        mainAxisSpacing: AppSizes.spacingXL,
        childAspectRatio: 2.5,
        children: [
          _DetectionMetric(
            label: 'LOẠI QUẢ',
            value: fruitType,
            valueColor: _primary,
          ),
          _DetectionMetric(
            label: 'CONFIDENCE',
            value: _formatConfidence(confidence),
            valueColor: _secondary,
          ),
          _DetectionMetric(
            label: 'BIN TARGET',
            value: targetBin,
            icon: Icons.inventory_2_rounded,
          ),
          _DetectionMetric(label: 'THỜI GIAN', value: time),
        ],
      ),
    );
  }
}

class _DetectionMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;

  const _DetectionMetric({
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            color: _onSurfaceVariant,
            fontSize: AppSizes.fontCaption,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSizes.spacingS),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppSizes.iconSmall, color: _onSurfaceVariant),
              const SizedBox(width: AppSizes.spacingS),
            ],
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  color: valueColor ?? _onSurface,
                  fontSize: AppSizes.fontHeadlineMedium,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecentThumb extends StatelessWidget {
  final String? imageUrl;
  final String? token;

  const _RecentThumb({required this.imageUrl, required this.token});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        image: url != null && url.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(
                  url,
                  headers: token != null
                      ? {'Authorization': 'Bearer $token'}
                      : null,
                ),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: url == null || url.isEmpty
          ? const Icon(Icons.spa_rounded, color: _primary, size: AppSizes.iconLarge)
          : null,
    );
  }
}

class _StatusStyle {
  final String label;
  final Color color;
  final Color containerColor;
  final Color iconColor;

  const _StatusStyle({
    required this.label,
    required this.color,
    required this.containerColor,
    required this.iconColor,
  });
}

List<BoxShadow> get _softShadow => [
  BoxShadow(
    color: _onSurfaceVariant.withValues(alpha: 0.06),
    blurRadius: 10,
    offset: const Offset(0, 2),
  ),
];

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

String _formatConfidence(double confidence) {
  final percent = confidence > 1 ? confidence : confidence * 100;
  if (percent == 0) return '---';
  final hasDecimal = percent % 1 != 0;
  return '${hasDecimal ? percent.toStringAsFixed(1) : percent.toStringAsFixed(0)}%';
}

String _detectionFruit(Map<String, dynamic> item) {
  return item['fruitType']?.toString() ?? item['fruit']?.toString() ?? '---';
}

String _detectionBin(Map<String, dynamic> item) {
  return item['targetBin']?.toString() ?? item['bin']?.toString() ?? '---';
}

_StatusStyle _statusStyle(String status) {
  switch (status.toUpperCase()) {
    case 'RUNNING':
    case 'ACTIVE':
    case 'ONLINE':
      return const _StatusStyle(
        label: 'RUNNING',
        color: _secondary,
        containerColor: _secondaryContainer,
        iconColor: _onSecondaryContainer,
      );
    case 'PAUSED':
    case 'MAINTENANCE':
      return const _StatusStyle(
        label: 'PAUSED',
        color: Color(0xFF9C6500),
        containerColor: Color(0xFFFFE0B2),
        iconColor: Color(0xFF7A4B00),
      );
    case 'STOPPED':
    case 'OFFLINE':
    case 'ERROR':
      return const _StatusStyle(
        label: 'STOPPED',
        color: _error,
        containerColor: _errorContainer,
        iconColor: _onErrorContainer,
      );
    default:
      return const _StatusStyle(
        label: 'IDLE',
        color: _onSurfaceVariant,
        containerColor: _surfaceVariant,
        iconColor: _onSurfaceVariant,
      );
  }
}
