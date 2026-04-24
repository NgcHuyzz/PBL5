// lib/screens/statistics_screen.dart
import 'package:flutter/material.dart';
import '../services/system_service.dart';
import '../utils/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late String systemId;
  bool _isLoading = true;
  Map<String, dynamic> _summaryData = {};
  List<dynamic> _fruitData = [];
  List<dynamic> _dailyData = [];
  String _errorMessage = '';

  DateTime? _startDate;
  DateTime? _endDate;
  String _quickFilter = '7 ngày';

  // Fruit colors & names (class level)
  final Map<String, Color> _fruitColors = {
    'strawberry': AppTheme.primary,
    'raspberry': AppTheme.tertiaryContainer,
    'grape': AppTheme.secondary,
  };

  final Map<String, String> _fruitNames = {
    'strawberry': 'Strawberry',
    'raspberry': 'Raspberry',
    'grape': 'Grape',
  };

  @override
  void initState() {
    super.initState();
    systemId = '66efdf73-2aa6-4328-b0e1-b7377ad0f6e8'; // TODO: replace with real systemId
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

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchSummary(String? from, String? to) async {
    final result = await SystemService.getStatisticsSummary(systemId, from: from, to: to);
    if (result['success'] == true) {
      setState(() {
        _summaryData = result['data'] ?? {};
      });
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Lỗi tải thống kê';
      });
    }
  }

  Future<void> _fetchFruitStats(String? from, String? to) async {
    final result = await SystemService.getStatisticsByFruit(systemId, from: from, to: to);
    if (result['success'] == true) {
      setState(() {
        _fruitData = result['data'] ?? [];
      });
    }
  }

  Future<void> _fetchDailyStats(String? from, String? to) async {
    // TODO: call real API when available
    setState(() {
      _dailyData = [
        {'day': 'T2', 'count': 120},
        {'day': 'T3', 'count': 180},
        {'day': 'T4', 'count': 320},
        {'day': 'T5', 'count': 210},
        {'day': 'T6', 'count': 190},
        {'day': 'T7', 'count': 250},
        {'day': 'CN', 'count': 150},
      ];
    });
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

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    final totalReceived = _summaryData['totalClassified'] ?? 0;
    final totalProcessing = _summaryData['totalProcessing'] ?? 0;
    final totalCompleted = _summaryData['totalCompleted'] ?? 0;
    final totalFailed = _summaryData['totalFailed'] ?? 0;
    final avgTime = _summaryData['averageProcessingTimeMs'] ?? 0.0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Thống kê'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppTheme.primary,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(),
                  const SizedBox(height: 24),
                  _buildOverviewGrid(totalReceived, totalProcessing, totalCompleted, totalFailed, avgTime),
                  const SizedBox(height: 24),
                  _buildChartsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TỪ NGÀY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      _startDate != null
                          ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                          : 'Chọn ngày',
                      style: AppTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ĐẾN NGÀY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      _endDate != null
                          ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                          : 'Chọn ngày',
                      style: AppTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _loadStatistics,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Lọc'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['Hôm nay', '7 ngày', '30 ngày'].map((filter) {
              final isSelected = _quickFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) => _applyQuickFilter(filter),
                  backgroundColor: AppTheme.surface,
                  selectedColor: AppTheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewGrid(int totalReceived, int totalProcessing, int totalCompleted, int totalFailed, double avgTime) {
    final items = [
      {'icon': Icons.move_to_inbox, 'label': 'TỔNG TIẾP NHẬN', 'value': _formatNumber(totalReceived), 'color': AppTheme.primary},
      {'icon': Icons.hourglass_empty, 'label': 'ĐANG XỬ LÝ', 'value': _formatNumber(totalProcessing), 'color': AppTheme.warning},
      {'icon': Icons.check_circle, 'label': 'HOÀN THÀNH', 'value': _formatNumber(totalCompleted), 'color': AppTheme.success},
      {'icon': Icons.error, 'label': 'LỖI', 'value': _formatNumber(totalFailed), 'color': AppTheme.error},
      {'icon': Icons.timer, 'label': 'THỜI GIAN XỬ LÝ TB', 'value': '${avgTime.toStringAsFixed(1)}s', 'color': AppTheme.primary},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item['icon'] as IconData, size: 24, color: item['color'] as Color),
              const SizedBox(height: 8),
              Text(item['label'] as String, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textHint)),
              const SizedBox(height: 4),
              Text(item['value'] as String, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: item['color'] as Color)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChartsSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildBarChartCard()),
        const SizedBox(width: 16),
        Expanded(child: _buildFruitDistributionCard()),
      ],
    );
  }

  Widget _buildBarChartCard() {
    final maxCount = _dailyData.isEmpty ? 1 : (_dailyData.map<int>((e) => e['count'] as int).reduce((a, b) => a > b ? a : b));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Biểu đồ theo ngày', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Icon(Icons.bar_chart, color: AppTheme.textHint.withOpacity(0.4)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _dailyData.map((item) {
                final count = item['count'] as int;
                final height = (count / maxCount) * 120;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: height,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(item['day'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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

  Widget _buildFruitDistributionCard() {
    int total = _fruitData.fold<int>(0, (sum, item) => sum + (item['count'] as int? ?? 0));
    final displayData = _fruitData.isEmpty
        ? [
            {'fruitType': 'strawberry', 'count': 50},
            {'fruitType': 'raspberry', 'count': 30},
            {'fruitType': 'grape', 'count': 20},
          ]
        : _fruitData;

    // Recalculate total after possible mock
    total = displayData.fold<int>(0, (sum, item) => sum + (item['count'] as int));

    // Build SweepGradient stops
    List<double> stops = [];
    double cumulative = 0.0;
    for (var item in displayData) {
      final count = item['count'] as int;
      final proportion = count / total;
      cumulative += proportion;
      stops.add(cumulative);
    }

    // Build colors list
    List<Color> colors = displayData.map((item) {
      final fruitType = item['fruitType'] as String;
      return _fruitColors[fruitType] ?? Colors.grey;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Loại trái cây', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Icon(Icons.pie_chart, color: AppTheme.textHint.withOpacity(0.4)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: colors,
                          stops: stops,
                        ),
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$total',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: displayData.map<Widget>((item) {
                    final fruitType = item['fruitType'] as String;
                    final count = item['count'] as int;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _fruitColors[fruitType] ?? Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_fruitNames[fruitType] ?? fruitType, style: const TextStyle(fontSize: 12))),
                          Text('$count', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}