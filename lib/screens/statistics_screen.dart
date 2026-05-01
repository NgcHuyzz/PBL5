import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/system_service.dart';
import 'history_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

const Color _primary = Color(0xFF8C0011);
const Color _primaryContainer = Color(0xFFB01E23);
const Color _secondary = Color(0xFF3B6934);
const Color _tertiaryContainer = Color(0xFFB40B3C);
const Color _error = Color(0xFFBA1A1A);
const Color _surface = Color(0xFFFCF9F8);
const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
const Color _surfaceContainerLow = Color(0xFFF6F3F2);
const Color _onSurface = Color(0xFF1B1C1C);
const Color _onSurfaceVariant = Color(0xFF5A403E);
const Color _outlineVariant = Color(0xFFE3BEBB);

class StatisticsScreen extends StatefulWidget {
  final String? systemId;
  final String systemName;

  const StatisticsScreen({super.key, this.systemId, this.systemName = ''});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _summaryData = {};
  List<dynamic> _fruitData = [];
  List<dynamic> _dailyData = [];
  String _errorMessage = '';

  DateTime? _startDate;
  DateTime? _endDate;
  String _quickFilter = '7 ngày';

  final Map<String, Color> _fruitColors = {
    'strawberry': _primary,
    'raspberry': _tertiaryContainer,
    'grape': _secondary,
    'STRAWBERRY': _primary,
    'RASPBERRY': _tertiaryContainer,
    'GRAPE': _secondary,
  };

  final Map<String, String> _fruitNames = {
    'strawberry': 'Strawberry',
    'raspberry': 'Raspberry',
    'grape': 'Grape',
    'STRAWBERRY': 'Strawberry',
    'RASPBERRY': 'Raspberry',
    'GRAPE': 'Grape',
  };

  @override
  void initState() {
    super.initState();
    if (widget.systemId == null || widget.systemId!.isEmpty) {
      _isLoading = false;
      _errorMessage = 'Chưa chọn hệ thống';
      return;
    }

    _applyQuickFilter(_quickFilter);
  }

  void _applyQuickFilter(String filter) {
    setState(() {
      _quickFilter = filter;
      final now = DateTime.now();
      switch (filter) {
        case 'Hôm nay':
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case '7 ngày':
          _startDate = now.subtract(const Duration(days: 7));
          _endDate = now;
          break;
        case '30 ngày':
          _startDate = now.subtract(const Duration(days: 30));
          _endDate = now;
          break;
        default:
          _startDate = null;
          _endDate = null;
      }
      _loadStatistics();
    });
  }

  Future<void> _loadStatistics() async {
    final systemId = widget.systemId;
    if (systemId == null || systemId.isEmpty) {
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

    final from = _startDate?.toIso8601String();
    final to = _endDate?.toIso8601String();

    await Future.wait([
      _fetchSummary(from, to),
      _fetchFruitStats(from, to),
      _fetchDailyStats(from, to),
    ]);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchSummary(String? from, String? to) async {
    final systemId = widget.systemId;
    if (systemId == null) return;

    final result = await SystemService.getStatisticsSummary(
      systemId,
      from: from,
      to: to,
    );
    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _summaryData = _asMap(result['data']);
      });
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Lỗi tải thống kê';
      });
    }
  }

  Future<void> _fetchFruitStats(String? from, String? to) async {
    final systemId = widget.systemId;
    if (systemId == null) return;

    final result = await SystemService.getStatisticsByFruit(
      systemId,
      from: from,
      to: to,
    );
    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _fruitData = result['data'] is List ? result['data'] as List : [];
      });
    }
  }

  Future<void> _fetchDailyStats(String? from, String? to) async {
    final systemId = widget.systemId;
    if (systemId == null) return;

    final result = await SystemService.getStatisticsDaily(
      systemId,
      from: from,
      to: to,
    );
    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _dailyData = result['data'] is List ? result['data'] as List : [];
      });
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: (_startDate != null && _endDate != null)
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _quickFilter = 'custom';
      });
      _loadStatistics();
    }
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsScreen(systemId: widget.systemId),
      ),
    );
  }

  void _openHome() {
    Navigator.pop(context);
  }

  void _openHistory() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(
          systemId: widget.systemId,
          systemName: widget.systemName,
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    final totalReceived = _asInt(_summaryData['totalReceived']);
    final totalProcessing = _asInt(_summaryData['totalProcessing']);
    final totalCompleted = _asInt(_summaryData['totalCompleted']);
    final totalFailed = _asInt(_summaryData['totalFailed']);
    final avgTime = _asDouble(_summaryData['averageProcessingTimeMs']);

    return Scaffold(
      backgroundColor: _surface,
      appBar: _buildTopBar(),
      bottomNavigationBar: _StatsBottomNav(
        onHome: _openHome,
        onStatistics: () {},
        onHistory: _openHistory,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : _errorMessage.isNotEmpty
          ? _buildMessageState(_errorMessage)
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              color: _primary,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildFilterSection(constraints.maxWidth),
                            const SizedBox(height: 18),
                            _buildQuickChips(),
                            const SizedBox(height: 30),
                            _buildOverviewGrid(
                              totalReceived,
                              totalProcessing,
                              totalCompleted,
                              totalFailed,
                              avgTime,
                            ),
                            const SizedBox(height: 26),
                            _buildChartsSection(constraints.maxWidth),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  PreferredSizeWidget _buildTopBar() {
    return AppBar(
      backgroundColor: _surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 70,
      leadingWidth: 52,
      leading: IconButton(
        onPressed: () {
          final nav = Navigator.of(context);
          nav.pop(); // exit Statistics
          if (nav.canPop()) nav.pop(); // exit SystemDetailScreen → HomeScreen
        },
        icon: const Icon(Icons.arrow_back_rounded),
        color: _primaryContainer,
        tooltip: 'Quay lại',
      ),
      titleSpacing: 0,
      title: Text(
        'Thống kê',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.manrope(
          color: _primaryContainer,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _openNotifications,
          icon: const Icon(Icons.notifications_rounded),
          color: _primaryContainer,
          tooltip: 'Thông báo',
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
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
                  color: _outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: _primaryContainer,
                size: 21,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageState(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 120),
        Icon(Icons.info_outline_rounded, size: 56, color: _onSurfaceVariant),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 14, color: _onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildFilterSection(double maxWidth) {
    final isWide = maxWidth >= 760;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _DateBox(
                    label: 'TỪ NGÀY',
                    value: _startDate,
                    onTap: _selectDateRange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DateBox(
                    label: 'ĐẾN NGÀY',
                    value: _endDate,
                    onTap: _selectDateRange,
                  ),
                ),
                const SizedBox(width: 16),
                _FilterButton(onPressed: _loadStatistics),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DateBox(
                  label: 'TỪ NGÀY',
                  value: _startDate,
                  onTap: _selectDateRange,
                ),
                const SizedBox(height: 18),
                _DateBox(
                  label: 'ĐẾN NGÀY',
                  value: _endDate,
                  onTap: _selectDateRange,
                ),
                const SizedBox(height: 18),
                _FilterButton(onPressed: _loadStatistics),
              ],
            ),
    );
  }

  Widget _buildQuickChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['Hôm nay', '7 ngày', '30 ngày'].map((filter) {
          final isSelected = _quickFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (_) => _applyQuickFilter(filter),
              backgroundColor: _surfaceContainerLowest,
              selectedColor: _primary,
              side: BorderSide(color: _outlineVariant.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              labelStyle: GoogleFonts.inter(
                color: isSelected ? Colors.white : _onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOverviewGrid(
    int totalReceived,
    int totalProcessing,
    int totalCompleted,
    int totalFailed,
    double avgTime,
  ) {
    final items = [
      _StatCardData(
        icon: Icons.move_to_inbox_rounded,
        label: 'TỔNG TIẾP NHẬN',
        value: _formatNumber(totalReceived),
        color: _primary,
      ),
      _StatCardData(
        icon: Icons.hourglass_empty_rounded,
        label: 'ĐANG XỬ LÝ',
        value: _formatNumber(totalProcessing),
        color: _secondary,
      ),
      _StatCardData(
        icon: Icons.check_circle_rounded,
        label: 'HOÀN THÀNH',
        value: _formatNumber(totalCompleted),
        color: _secondary,
      ),
      _StatCardData(
        icon: Icons.error_rounded,
        label: 'LỖI',
        value: _formatNumber(totalFailed),
        color: _error,
      ),
      _StatCardData(
        icon: Icons.timer_rounded,
        label: 'THỜI GIAN XỬ LÝ TB',
        value: '${avgTime.toStringAsFixed(1)}ms',
        color: _primaryContainer,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;
        final columns = isWide ? 3 : 2;
        final gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var index = 0; index < items.length; index++)
              SizedBox(
                width: !isWide && index == items.length - 1
                    ? constraints.maxWidth
                    : width,
                child: _StatCard(data: items[index]),
              ),
          ],
        );
      },
    );
  }

  Widget _buildChartsSection(double maxWidth) {
    final isWide = maxWidth >= 760;
    final charts = [_buildBarChartCard(), _buildFruitDistributionCard()];

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: charts[0]),
          const SizedBox(width: 18),
          Expanded(child: charts[1]),
        ],
      );
    }

    return Column(children: [charts[0], const SizedBox(height: 24), charts[1]]);
  }

  Widget _buildBarChartCard() {
    if (_dailyData.isEmpty) {
      return _ChartShell(
        title: 'Biểu đồ theo ngày',
        icon: Icons.bar_chart_rounded,
        child: SizedBox(
          height: 180,
          child: Center(
            child: Text(
              'Chưa có dữ liệu theo ngày',
              style: GoogleFonts.inter(color: _onSurfaceVariant, fontSize: 13),
            ),
          ),
        ),
      );
    }

    final maxCount = _dailyData
        .map<int>((e) => _asInt(_asMap(e)['totalClassified']))
        .fold<int>(1, (max, count) => count > max ? count : max);

    return _ChartShell(
      title: 'Biểu đồ theo ngày',
      icon: Icons.bar_chart_rounded,
      child: Column(
        children: [
          SizedBox(
            height: 190,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _dailyData.map((item) {
                final data = _asMap(item);
                final count = _asInt(data['totalClassified']);
                final height = (count / maxCount) * 150;
                final isPeak = count == maxCount;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: height.clamp(8, 150).toDouble(),
                          decoration: BoxDecoration(
                            color: isPeak ? _primary : _surfaceContainerLow,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _dailyData.map((item) {
              final fullDate = _asMap(item)['date']?.toString() ?? '';
              String day = '';
              if (fullDate.isNotEmpty) {
                try {
                  final parsedDate = DateTime.parse(fullDate);
                  day =
                      '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}';
                } catch (_) {
                  day = fullDate;
                }
              }

              return Text(
                day,
                style: GoogleFonts.inter(
                  color: _onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFruitDistributionCard() {
    var total = _fruitData.fold<int>(
      0,
      (sum, item) => sum + _asInt(_asMap(item)['count']),
    );
    if (_fruitData.isEmpty || total == 0) {
      return _ChartShell(
        title: 'Loại trái cây',
        icon: Icons.pie_chart_rounded,
        child: SizedBox(
          height: 180,
          child: Center(
            child: Text(
              'Chưa có thống kê theo loại trái cây',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: _onSurfaceVariant, fontSize: 13),
            ),
          ),
        ),
      );
    }

    final displayData = _fruitData.map(_asMap).toList();
    total = displayData.fold<int>(
      0,
      (sum, item) => sum + _asInt(item['count']),
    );

    final colors = displayData.map((item) {
      final fruitType = item['fruitType']?.toString() ?? '';
      return _fruitColors[fruitType] ??
          _fruitColors[fruitType.toLowerCase()] ??
          Colors.grey;
    }).toList();

    final stops = <double>[];
    var cumulative = 0.0;
    for (final item in displayData) {
      final count = _asInt(item['count']);
      cumulative += count / total;
      stops.add(cumulative.clamp(0.0, 1.0));
    }

    return _ChartShell(
      title: 'Loại trái cây',
      icon: Icons.pie_chart_rounded,
      child: Row(
        children: [
          Container(
            width: 138,
            height: 138,
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 106,
                    height: 106,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(colors: colors, stops: stops),
                    ),
                  ),
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: _surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        '100%',
                        style: GoogleFonts.inter(
                          color: _onSurface,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              children: displayData.map((item) {
                final fruitType = item['fruitType']?.toString() ?? '';
                final count = _asInt(item['count']);
                final color =
                    _fruitColors[fruitType] ??
                    _fruitColors[fruitType.toLowerCase()] ??
                    Colors.grey;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _fruitNames[fruitType] ??
                              _fruitNames[fruitType.toLowerCase()] ??
                              fruitType,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: _onSurface,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '$count',
                        style: GoogleFonts.inter(
                          color: _onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateBox({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: _onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: _surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value != null
                          ? '${value!.month.toString().padLeft(2, '0')}/${value!.day.toString().padLeft(2, '0')}/${value!.year}'
                          : 'Chọn ngày',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(color: _onSurface, fontSize: 14),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: _onSurface,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _FilterButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_primary, _primaryContainer],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 38),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Lọc',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

class _StatCardData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCardData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _StatCard extends StatelessWidget {
  final _StatCardData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 126,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, size: 22, color: data.color),
          const Spacer(),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: _onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: _onSurface,
              fontSize: 28,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartShell extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _ChartShell({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.manrope(
                    color: _onSurface,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(icon, color: _onSurfaceVariant.withValues(alpha: 0.36)),
            ],
          ),
          const SizedBox(height: 28),
          child,
        ],
      ),
    );
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

// ── Bottom Navigation ────────────────────────────────────────────────────────

class _StatsBottomNav extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onStatistics;
  final VoidCallback onHistory;

  const _StatsBottomNav({
    required this.onHome,
    required this.onStatistics,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
            _BottomNavItem(
              icon: Icons.home_rounded,
              label: 'Trang chủ',
              isSelected: false,
              onTap: onHome,
            ),
            _BottomNavItem(
              icon: Icons.analytics_rounded,
              label: 'Thống kê',
              isSelected: true,
              onTap: onStatistics,
            ),
            _BottomNavItem(
              icon: Icons.history_rounded,
              label: 'Lịch sử',
              isSelected: false,
              onTap: onHistory,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFFB01E23);
    final color = isSelected ? activeColor : _onSurfaceVariant;

    return Expanded(
      child: Center(
        child: Material(
          color: isSelected
              ? const Color(0xFFFFDAD6).withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(minWidth: 78),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: color,
                      fontSize: 10,
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
