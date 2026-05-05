import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/system_service.dart';
import '../utils/app_sizes.dart';
import '../widgets/notification_bell_button.dart';
import 'history_screen.dart';
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
    'blueberry': Color(0xFF1976D2),
    'cherry tomato': Color(0xFFFF6D1F),
    'strawberry': _primary,
    'raspberry': _tertiaryContainer,
    'grape': _secondary,
    'unknown': Color(0xFF9E9E9E),
    'BLUEBERRY': Color(0xFF1976D2),
    'CHERRY TOMATO': Color(0xFFFF6D1F),
    'STRAWBERRY': _primary,
    'RASPBERRY': _tertiaryContainer,
    'GRAPE': _secondary,
    'UNKNOWN': Color(0xFF9E9E9E),
  };

  final Map<String, String> _fruitNames = {
    'blueberry': 'BLUEBERRY',
    'cherry tomato': 'CHERRY TOMATO',
    'strawberry': 'Strawberry',
    'raspberry': 'Raspberry',
    'grape': 'Grape',
    'unknown': 'UNKNOWN',
    'BLUEBERRY': 'BLUEBERRY',
    'CHERRY TOMATO': 'CHERRY TOMATO',
    'STRAWBERRY': 'Strawberry',
    'RASPBERRY': 'Raspberry',
    'GRAPE': 'Grape',
    'UNKNOWN': 'UNKNOWN',
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
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.spacingL,
                      AppSizes.spacingL,
                      AppSizes.spacingL,
                      AppSizes.spacingXXL,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildFilterSection(constraints.maxWidth),
                            const SizedBox(height: AppSizes.spacingL),
                            _buildQuickChips(),
                            const SizedBox(height: AppSizes.spacingXXL),
                            _buildOverviewGrid(
                              totalReceived,
                              totalProcessing,
                              totalCompleted,
                              totalFailed,
                              avgTime,
                            ),
                            const SizedBox(height: AppSizes.spacingXXL),
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
          fontSize: AppSizes.fontHeadlineMedium,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        NotificationBellButton(
          systemId: widget.systemId,
          color: _primaryContainer,
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
                  color: _outlineVariant.withValues(alpha: 0.4),
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
    );
  }

  Widget _buildMessageState(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSizes.spacingXXL),
      children: [
        const SizedBox(height: 96),
        Icon(
          Icons.info_outline_rounded,
          size: AppSizes.iconXXLarge,
          color: _onSurfaceVariant,
        ),
        const SizedBox(height: AppSizes.spacingL),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontBody,
            color: _onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection(double maxWidth) {
    final isWide = maxWidth >= 760;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingL),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
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
                const SizedBox(width: AppSizes.spacingL),
                Expanded(
                  child: _DateBox(
                    label: 'ĐẾN NGÀY',
                    value: _endDate,
                    onTap: _selectDateRange,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingL),
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
                const SizedBox(height: AppSizes.spacingL),
                _DateBox(
                  label: 'ĐẾN NGÀY',
                  value: _endDate,
                  onTap: _selectDateRange,
                ),
                const SizedBox(height: AppSizes.spacingL),
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
            padding: const EdgeInsets.only(right: AppSizes.spacingS),
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
                fontSize: AppSizes.fontBody,
                fontWeight: FontWeight.w700,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacingM,
                vertical: AppSizes.spacingS,
              ),
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
          const SizedBox(width: AppSizes.spacingL),
          Expanded(child: charts[1]),
        ],
      );
    }

    return Column(
      children: [
        charts[0],
        const SizedBox(height: AppSizes.spacingXXL),
        charts[1],
      ],
    );
  }

  Widget _buildBarChartCard() {
    final points = _buildDailyLinePoints();

    if (points.isEmpty) {
      return _ChartShell(
        title: 'Biểu đồ theo ngày',
        icon: Icons.show_chart_rounded,
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

    return _ChartShell(
      title: 'Biểu đồ theo ngày',
      icon: Icons.show_chart_rounded,
      child: SizedBox(height: 260, child: _DailyLineChart(points: points)),
    );
  }

  List<_DailyChartPoint> _buildDailyLinePoints() {
    final countsByDate = <DateTime, int>{};

    for (final item in _dailyData) {
      final data = _asMap(item);
      final parsedDate = DateTime.tryParse(data['date']?.toString() ?? '');
      if (parsedDate == null) continue;

      final date = _dateOnly(parsedDate);
      final count = _asInt(data['totalClassified']);
      countsByDate[date] = (countsByDate[date] ?? 0) + count;
    }

    final start = _dateOnly(
      _startDate ??
          (countsByDate.isEmpty
              ? DateTime.now()
              : countsByDate.keys.reduce((a, b) => a.isBefore(b) ? a : b)),
    );
    final end = _dateOnly(
      _endDate ??
          (countsByDate.isEmpty
              ? start
              : countsByDate.keys.reduce((a, b) => a.isAfter(b) ? a : b)),
    );

    if (end.isBefore(start)) return [];

    final dayCount = end.difference(start).inDays + 1;
    return List.generate(dayCount, (index) {
      final date = start.add(Duration(days: index));
      return _DailyChartPoint(date: date, count: countsByDate[date] ?? 0);
    });
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

    final slices = displayData.map((item) {
      final fruitType = item['fruitType']?.toString() ?? '';
      return _FruitPieSlice(
        count: _asInt(item['count']),
        color: _colorForFruit(fruitType),
      );
    }).toList();

    return _ChartShell(
      title: 'Loại trái cây',
      icon: Icons.pie_chart_rounded,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 420;
          final chart = SizedBox(
            width: 132,
            height: 132,
            child: _FruitPieChart(slices: slices, total: total),
          );
          final legend = Column(
            children: displayData.map((item) {
              final fruitType = item['fruitType']?.toString() ?? '';
              final count = _asInt(item['count']);
              final percent = total == 0 ? 0.0 : count * 100 / total;
              final color = _colorForFruit(fruitType);

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.spacingS,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingS),
                    Expanded(
                      child: Text(
                        _nameForFruit(fruitType),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: _onSurface,
                          fontSize: AppSizes.fontBody,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingS),
                    Text(
                      '$count',
                      style: GoogleFonts.inter(
                        color: _onSurface,
                        fontSize: AppSizes.fontBody,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingS),
                    SizedBox(
                      width: 54,
                      child: Text(
                        _formatPercent(percent),
                        textAlign: TextAlign.right,
                        style: GoogleFonts.inter(
                          color: _onSurfaceVariant,
                          fontSize: AppSizes.fontCaption,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );

          if (!isWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                chart,
                const SizedBox(height: AppSizes.spacingL),
                legend,
              ],
            );
          }

          return Row(
            children: [
              chart,
              const SizedBox(width: AppSizes.spacingXL),
              Expanded(child: legend),
            ],
          );
        },
      ),
    );
  }

  Color _colorForFruit(String fruitType) {
    return _fruitColors[fruitType] ??
        _fruitColors[fruitType.toLowerCase()] ??
        Colors.grey;
  }

  String _nameForFruit(String fruitType) {
    return _fruitNames[fruitType] ??
        _fruitNames[fruitType.toLowerCase()] ??
        fruitType;
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
            fontSize: AppSizes.fontCaption,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSizes.spacingS),
        Material(
          color: _surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacingM,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value != null
                          ? '${value!.month.toString().padLeft(2, '0')}/${value!.day.toString().padLeft(2, '0')}/${value!.year}'
                          : 'Chọn ngày',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: _onSurface,
                        fontSize: AppSizes.fontBody,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: AppSizes.iconSmall,
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
      height: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_primary, _primaryContainer],
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingXXL,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
          ),
          child: Text(
            'Lọc',
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontTitleLarge,
              fontWeight: FontWeight.w800,
            ),
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
      height: 100,
      padding: const EdgeInsets.all(AppSizes.spacingL),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, size: AppSizes.iconMedium, color: data.color),
          const Spacer(),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: _onSurfaceVariant,
              fontSize: AppSizes.fontCaption,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: _onSurface,
              fontSize: AppSizes.fontHeadlineLarge,
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
      padding: const EdgeInsets.all(AppSizes.spacingXXL),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
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
                    fontSize: AppSizes.fontHeadlineMedium,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(icon, color: _onSurfaceVariant.withValues(alpha: 0.36)),
            ],
          ),
          const SizedBox(height: AppSizes.spacingXXL),
          child,
        ],
      ),
    );
  }
}

class _DailyChartPoint {
  final DateTime date;
  final int count;

  const _DailyChartPoint({required this.date, required this.count});
}

class _DailyLineChart extends StatelessWidget {
  final List<_DailyChartPoint> points;

  const _DailyLineChart({required this.points});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DailyLineChartPainter(points: points),
      child: const SizedBox.expand(),
    );
  }
}

class _DailyLineChartPainter extends CustomPainter {
  final List<_DailyChartPoint> points;

  const _DailyLineChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || size.width <= 0 || size.height <= 0) return;

    const leftPadding = 42.0;
    const rightPadding = 14.0;
    const topPadding = 14.0;
    const bottomPadding = 38.0;
    final chartRect = Rect.fromLTRB(
      leftPadding,
      topPadding,
      size.width - rightPadding,
      size.height - bottomPadding,
    );

    final maxCount = points.fold<int>(
      0,
      (max, point) => point.count > max ? point.count : max,
    );
    final maxY = _niceAxisMax(maxCount);
    final yTicks = _axisTicks(maxY);

    final axisPaint = Paint()
      ..color = _outlineVariant.withValues(alpha: 0.75)
      ..strokeWidth = 1.1;
    final gridPaint = Paint()
      ..color = _outlineVariant.withValues(alpha: 0.26)
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = _primary
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final tick in yTicks) {
      final y = _pointY(tick, maxY, chartRect);
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        tick == 0 ? axisPaint : gridPaint,
      );
      _drawLabel(
        canvas,
        text: _formatChartNumber(tick),
        offset: Offset(0, y - 8),
        width: leftPadding - 8,
        align: TextAlign.right,
      );
    }

    canvas.drawLine(
      Offset(chartRect.left, chartRect.top),
      Offset(chartRect.left, chartRect.bottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(chartRect.left, chartRect.bottom),
      Offset(chartRect.right, chartRect.bottom),
      axisPaint,
    );

    final offsets = <Offset>[
      for (var index = 0; index < points.length; index++)
        Offset(
          _pointX(index, points.length, chartRect),
          _pointY(points[index].count, maxY, chartRect),
        ),
    ];

    if (offsets.length > 1) {
      canvas.drawPath(_smoothPath(offsets, chartRect), linePaint);
    }

    final labelInterval = math.max(1, (points.length / 6).ceil());
    for (var index = 0; index < points.length; index++) {
      final isEdge = index == 0 || index == points.length - 1;
      if (!isEdge && index % labelInterval != 0) continue;

      final x = _pointX(index, points.length, chartRect);
      _drawLabel(
        canvas,
        text: _formatDay(points[index].date),
        offset: Offset(x - 22, chartRect.bottom + 10),
        width: 44,
        align: TextAlign.center,
      );
    }
  }

  double _pointX(int index, int total, Rect chartRect) {
    if (total == 1) return chartRect.center.dx;
    return chartRect.left + chartRect.width * index / (total - 1);
  }

  double _pointY(int value, int maxY, Rect chartRect) {
    return chartRect.bottom - chartRect.height * value / maxY;
  }

  Path _smoothPath(List<Offset> offsets, Rect chartRect) {
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    const tension = 0.2;

    for (var index = 0; index < offsets.length - 1; index++) {
      final current = offsets[index];
      final next = offsets[index + 1];
      final previous = index == 0 ? current : offsets[index - 1];
      final afterNext = index + 2 < offsets.length ? offsets[index + 2] : next;

      final controlPoint1 = current + (next - previous) * tension;
      final controlPoint2 = next - (afterNext - current) * tension;

      path.cubicTo(
        controlPoint1.dx.clamp(chartRect.left, chartRect.right),
        controlPoint1.dy.clamp(chartRect.top, chartRect.bottom),
        controlPoint2.dx.clamp(chartRect.left, chartRect.right),
        controlPoint2.dy.clamp(chartRect.top, chartRect.bottom),
        next.dx,
        next.dy,
      );
    }

    return path;
  }

  void _drawLabel(
    Canvas canvas, {
    required String text,
    required Offset offset,
    required double width,
    required TextAlign align,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.inter(
          color: _onSurfaceVariant,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: width);

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _DailyLineChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

class _FruitPieSlice {
  final int count;
  final Color color;

  const _FruitPieSlice({required this.count, required this.color});
}

class _FruitPieChart extends StatelessWidget {
  final List<_FruitPieSlice> slices;
  final int total;

  const _FruitPieChart({required this.slices, required this.total});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FruitPieChartPainter(slices: slices, total: total),
      child: const SizedBox.expand(),
    );
  }
}

class _FruitPieChartPainter extends CustomPainter {
  final List<_FruitPieSlice> slices;
  final int total;

  const _FruitPieChartPainter({required this.slices, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0 || slices.isEmpty || size.width <= 0 || size.height <= 0) {
      return;
    }

    final diameter = math.min(size.width, size.height);
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: diameter - 4,
      height: diameter - 4,
    );
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final separatorPaint = Paint()
      ..color = _surfaceContainerLowest
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeJoin = StrokeJoin.round;

    var startAngle = -math.pi / 2;
    for (final slice in slices) {
      if (slice.count <= 0) continue;

      final sweepAngle = slice.count / total * math.pi * 2;
      fillPaint.color = slice.color;
      canvas.drawArc(rect, startAngle, sweepAngle, true, fillPaint);
      canvas.drawArc(rect, startAngle, sweepAngle, true, separatorPaint);
      startAngle += sweepAngle;
    }

    canvas.drawCircle(rect.center, rect.width / 2, separatorPaint);
  }

  @override
  bool shouldRepaint(covariant _FruitPieChartPainter oldDelegate) {
    return oldDelegate.slices != slices || oldDelegate.total != total;
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

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

String _formatDay(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
}

String _formatChartNumber(int number) {
  if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(1)}K';
  }
  return number.toString();
}

String _formatPercent(double percent) {
  final rounded = percent.toStringAsFixed(1);
  if (rounded.endsWith('.0')) {
    return '${percent.toStringAsFixed(0)}%';
  }
  return '$rounded%';
}

int _niceAxisMax(int maxValue) {
  if (maxValue <= 0) return 1;

  final exponent = (math.log(maxValue) / math.ln10).floor();
  final magnitude = math.pow(10, exponent).toInt();
  final normalized = maxValue / magnitude;
  final niceNormalized = normalized <= 1
      ? 1
      : normalized <= 2
      ? 2
      : normalized <= 5
      ? 5
      : 10;

  return niceNormalized * magnitude;
}

List<int> _axisTicks(int maxY) {
  final middle = (maxY / 2).ceil();
  return {0, middle, maxY}.toList()..sort();
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
        height: 64,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingXL,
          vertical: AppSizes.spacingS,
        ),
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
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            child: Container(
              constraints: const BoxConstraints(minWidth: 78),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacingM,
                vertical: AppSizes.spacingXS,
              ),
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
