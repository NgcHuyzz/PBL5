import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/system_service.dart';
import '../utils/app_sizes.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'statistics_screen.dart';

const Color _primary = Color(0xFF8C0011);
const Color _primaryContainer = Color(0xFFB01E23);
const Color _secondary = Color(0xFF3B6934);
const Color _error = Color(0xFFBA1A1A);
const Color _warning = Color(0xFFFFA000);
const Color _surface = Color(0xFFFCF9F8);
const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
const Color _surfaceContainerLow = Color(0xFFF6F3F2);
const Color _surfaceContainerHighest = Color(0xFFE5E2E1);
const Color _onSurface = Color(0xFF1B1C1C);
const Color _onSurfaceVariant = Color(0xFF5A403E);
const Color _outlineVariant = Color(0xFFE3BEBB);

class HistoryScreen extends StatefulWidget {
  final String? systemId;
  final String systemName;

  const HistoryScreen({super.key, this.systemId, this.systemName = ''});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = false;
  bool _isLoadingMore = false;
  List<Map<String, dynamic>> _detections = [];
  int _currentPage = 0;
  int _totalPages = 1;
  String? _token;

  String? _selectedFruitType;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  final Map<String, String> _fruitTypes = {
    'all': 'Tất cả',
    'CHERRY TOMATO': 'Cà chua bi',
    'STRAWBERRY': 'Dâu tây',
    'GRAPE': 'Nho',
    'BLUEBERRY': 'Việt quất',
  };

  final Map<String, String> _statuses = {
    'all': 'Tất cả',
    'COMPLETED': 'Hoàn thành',
    'FAILED': 'Lỗi',
    'REJECTED': 'Từ chối',
  };

  @override
  void initState() {
    super.initState();
    _loadToken();
    if (widget.systemId != null && widget.systemId!.isNotEmpty) {
      _loadHistory();
    }
  }

  Future<void> _loadToken() async {
    final token = await SystemService.getToken();
    if (mounted) {
      setState(() {
        _token = token;
      });
    }
  }

  Future<void> _loadHistory({bool reset = true}) async {
    final systemId = widget.systemId;
    if (systemId == null || systemId.isEmpty) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      return;
    }

    if (reset) {
      setState(() {
        _currentPage = 0;
        _detections = [];
        _isLoading = true;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    final result = await SystemService.getDetectionHistory(
      systemId,
      page: _currentPage,
      size: 10,
      fruitType: _selectedFruitType == 'all' ? null : _selectedFruitType,
      status: _selectedStatus == 'all' ? null : _selectedStatus,
      from: _startDate?.toIso8601String(),
      to: _endDate?.toIso8601String(),
    );

    if (!mounted) return;

    if (reset) {
      setState(() => _isLoading = false);
    } else {
      setState(() => _isLoadingMore = false);
    }

    if (result['success'] == true) {
      final data = _asMap(result['data']);
      setState(() {
        if (reset) {
          _detections = _extractDetectionList(data);
        } else {
          _detections = [..._detections, ..._extractDetectionList(data)];
        }
        _totalPages = data['totalPages'] ?? 1;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Lỗi tải lịch sử'),
            backgroundColor: _error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _applyFilters() async {
    setState(() {
      _currentPage = 0;
    });
    await _loadHistory();
  }

  Future<void> _resetFilters() async {
    setState(() {
      _selectedFruitType = null;
      _selectedStatus = null;
      _startDate = null;
      _endDate = null;
      _currentPage = 0;
    });
    await _loadHistory();
  }

  Future<void> _loadMore() async {
    if (_currentPage + 1 < _totalPages && !_isLoadingMore) {
      setState(() {
        _currentPage++;
      });
      await _loadHistory(reset: false);
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

  void _openStatistics() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => StatisticsScreen(
          systemId: widget.systemId,
          systemName: widget.systemName,
        ),
      ),
    );
  }

  String _formatDateTime(String? isoString) {
    if (isoString == null) return '---';
    try {
      final date = DateTime.parse(isoString);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')} - ${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: _buildTopBar(),
      bottomNavigationBar: _HistoryBottomNav(
        onHome: _openHome,
        onStatistics: _openStatistics,
        onHistory: () {},
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadHistory(),
              color: _primary,
              child: widget.systemId == null || widget.systemId!.isEmpty
                  ? _buildMessageState('Chưa chọn hệ thống')
                  : _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: _primary),
                    )
                  : _buildHistoryContent(),
            ),
          ),
        ],
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
          nav.pop(); // exit History
          if (nav.canPop()) nav.pop(); // exit SystemDetailScreen → HomeScreen
        },
        icon: const Icon(Icons.arrow_back_rounded),
        color: _primaryContainer,
        tooltip: 'Quay lại',
      ),
      titleSpacing: 0,
      title: Text(
        'Lịch sử phân loại',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.manrope(
          color: _primaryContainer,
          fontSize: AppSizes.fontHeadlineMedium,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_rounded),
          color: _primaryContainer,
          tooltip: 'Thông báo',
          onPressed: _openNotifications,
        ),
        Padding(
          padding: const EdgeInsets.only(right: AppSizes.spacingL),
          child: InkWell(
            onTap: _openProfile,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: _surfaceContainerHighest,
                shape: BoxShape.circle,
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

  Widget _buildHistoryContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(AppSizes.spacingL, AppSizes.spacingXL, AppSizes.spacingL, AppSizes.spacingXXL),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFilterSection(constraints.maxWidth),
                    const SizedBox(height: 30),
                    _SectionTitle('Lịch sử phân loại'),
                    const SizedBox(height: AppSizes.spacingXL),
                    if (_detections.isEmpty)
                      _buildEmptyState()
                    else ...[
                      ..._detections.map(_buildHistoryCard),
                      if (_currentPage + 1 < _totalPages)
                        _buildLoadMoreButton(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageState(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
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

  Widget _buildFilterSection(double maxWidth) {
    final isWide = maxWidth >= 760;
    final fields = [
      _FilterSelect(
        label: 'CHỌN LOẠI QUẢ',
        value: _selectedFruitType,
        items: _fruitTypes,
        onChanged: (value) {
          setState(() => _selectedFruitType = value);
        },
      ),
      _FilterSelect(
        label: 'CHỌN TRẠNG THÁI',
        value: _selectedStatus,
        items: _statuses,
        onChanged: (value) {
          setState(() => _selectedStatus = value);
        },
      ),
      _DateField(
        label: 'NGÀY BẮT ĐẦU',
        value: _startDate,
        onTap: () => _pickDate(isStart: true),
      ),
      _DateField(
        label: 'NGÀY KẾT THÚC',
        value: _endDate,
        onTap: () => _pickDate(isStart: false),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingXXL),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.filter_list_rounded,
                size: AppSizes.iconSmall,
                color: _onSurfaceVariant,
              ),
              const SizedBox(width: AppSizes.spacingS),
              Text(
                'BỘ LỌC TÌM KIẾM',
                style: GoogleFonts.inter(
                  color: _onSurfaceVariant,
                  fontSize: AppSizes.fontTitleMedium,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingXL),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final field in fields) ...[
                  Expanded(child: field),
                  if (field != fields.last) const SizedBox(width: AppSizes.spacingL),
                ],
              ],
            )
          else
            Column(
              children: [
                for (final field in fields) ...[
                  field,
                  if (field != fields.last) const SizedBox(height: AppSizes.spacingXL),
                ],
              ],
            ),
          const SizedBox(height: AppSizes.spacingXXL),
          isWide
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _FilterActionButton(
                      label: 'Xóa lọc',
                      onPressed: _resetFilters,
                      isPrimary: false,
                    ),
                    const SizedBox(width: AppSizes.spacingM),
                    _FilterActionButton(
                      label: 'Lọc kết quả',
                      onPressed: _applyFilters,
                      isPrimary: true,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FilterActionButton(
                      label: 'Xóa lọc',
                      onPressed: _resetFilters,
                      isPrimary: false,
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    _FilterActionButton(
                      label: 'Lọc kết quả',
                      onPressed: _applyFilters,
                      isPrimary: true,
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final current = isStart ? _startDate : _endDate;
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  Widget _buildHistoryCard(Map<String, dynamic> detection) {
    final fruitType = detection['fruitType']?.toString() ?? 'unknown';
    final confidence = _asDouble(detection['confidence']);
    final targetBin = detection['targetBin']?.toString() ?? '---';
    final classifiedAt = detection['classifiedAt']?.toString();
    final status = detection['status']?.toString() ?? 'COMPLETED';
    final isError = status == 'FAILED' || status == 'REJECTED';
    final fruitName = _fruitName(fruitType);
    final imageUrl = detection['imageUrl']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingL),
      padding: const EdgeInsets.all(AppSizes.spacingL),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          _HistoryThumb(imageUrl: imageUrl, token: _token, isMuted: isError),
          const SizedBox(width: AppSizes.spacingXL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        fruitName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          color: _onSurface,
                          fontSize: AppSizes.fontHeadlineMedium,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (status != 'COMPLETED') _StatusChip(status: status),
                  ],
                ),
                const SizedBox(height: AppSizes.spacingM),
                Wrap(
                  spacing: AppSizes.spacingXXL,
                  runSpacing: AppSizes.spacingS,
                  children: [
                    _HistoryMetric(
                      label: 'ĐỘ TIN CẬY',
                      value: _formatConfidence(confidence),
                      valueColor: isError ? _error : _onSurface,
                    ),
                    _HistoryMetric(label: 'THÙNG CHỨA', value: targetBin),
                    _HistoryMetric(
                      label: 'THỜI GIAN',
                      value: _formatDateTime(classifiedAt),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Icon(
            Icons.chevron_right_rounded,
            color: _onSurfaceVariant.withValues(alpha: 0.45),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, AppSizes.spacingXXL, 0, AppSizes.spacingM),
        child: _isLoadingMore
            ? const CircularProgressIndicator(color: _primary)
            : InkWell(
                onTap: _loadMore,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        border: Border.all(color: _outlineVariant, width: 2),
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _onSurfaceVariant,
                        size: AppSizes.iconLarge,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    Text(
                      'TẢI THÊM',
                      style: GoogleFonts.inter(
                        color: _onSurfaceVariant,
                        fontSize: AppSizes.fontBody,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingXXL),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_rounded,
            size: AppSizes.iconXXLarge,
            color: _onSurfaceVariant.withValues(alpha: 0.35),
          ),
          const SizedBox(height: AppSizes.spacingL),
          Text(
            'Chưa có lịch sử phân loại',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: _onSurface,
              fontSize: AppSizes.fontHeadlineMedium,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text(
            'Hãy bắt đầu phân loại trái cây đầu tiên',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: _onSurfaceVariant, fontSize: AppSizes.fontBody),
          ),
        ],
      ),
    );
  }

  String _fruitName(String fruitType) {
    return _fruitTypes[fruitType] ??
        _fruitTypes[fruitType.toUpperCase()] ??
        fruitType;
  }
}

class _FilterSelect extends StatelessWidget {
  final String label;
  final String? value;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;

  const _FilterSelect({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _FilterFieldFrame(
      label: label,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: GoogleFonts.inter(color: _onSurface, fontSize: AppSizes.fontTitleMedium),
          items: items.entries.map((entry) {
            return DropdownMenuItem<String?>(
              value: entry.key == 'all' ? null : entry.key,
              child: Text(entry.value, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _FilterFieldFrame(
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Text(
                value != null
                    ? '${value!.month.toString().padLeft(2, '0')}/${value!.day.toString().padLeft(2, '0')}/${value!.year}'
                    : 'mm/dd/yyyy',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(color: _onSurface, fontSize: AppSizes.fontTitleMedium),
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
    );
  }
}

class _FilterFieldFrame extends StatelessWidget {
  final String label;
  final Widget child;

  const _FilterFieldFrame({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSizes.spacingXS, bottom: AppSizes.spacingS),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: _onSurfaceVariant,
              fontSize: AppSizes.fontBody,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Center(child: child),
        ),
      ],
    );
  }
}

class _FilterActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _FilterActionButton({
    required this.label,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_primary, _primaryContainer],
                )
              : null,
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          border: isPrimary ? null : Border.all(color: _outlineVariant),
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: isPrimary ? Colors.white : _onSurfaceVariant,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingXXL),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(fontSize: AppSizes.fontTitleMedium, fontWeight: FontWeight.w800),
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
    return Text(
      text,
      style: GoogleFonts.manrope(
        color: _onSurface,
        fontSize: AppSizes.fontHeadlineLarge,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _HistoryThumb extends StatelessWidget {
  final String? imageUrl;
  final String? token;
  final bool isMuted;

  const _HistoryThumb({
    required this.imageUrl,
    required this.token,
    required this.isMuted,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;

    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        image: url != null && url.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(
                  url,
                  headers: token != null
                      ? {'Authorization': 'Bearer $token'}
                      : null,
                ),
                fit: BoxFit.cover,
                colorFilter: isMuted
                    ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                    : null,
              )
            : null,
      ),
      child: url == null || url.isEmpty
          ? const Icon(Icons.qr_code_scanner_rounded, color: _primary, size: AppSizes.iconLarge)
          : null,
    );
  }
}

class _HistoryMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _HistoryMetric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: _onSurfaceVariant.withValues(alpha: 0.58),
              fontSize: AppSizes.fontCaption,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSizes.spacingXS),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: valueColor ?? _onSurface,
              fontSize: AppSizes.fontBody,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'FAILED' => _error,
      'REJECTED' => _warning,
      _ => _secondary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingS, vertical: AppSizes.spacingXS),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          color: color,
          fontSize: AppSizes.fontCaption,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

Map<String, dynamic> _asMap(Object? data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return {};
}

List<Map<String, dynamic>> _extractDetectionList(Object? data) {
  final source = data is Map
      ? data['content'] ?? data['items'] ?? data['detections']
      : data;

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

String _formatConfidence(double confidence) {
  final percent = confidence > 1 ? confidence : confidence * 100;
  if (percent == 0) return '---';
  final hasDecimal = percent % 1 != 0;
  return '${hasDecimal ? percent.toStringAsFixed(1) : percent.toStringAsFixed(0)}%';
}

// ── Bottom Navigation ────────────────────────────────────────────────────────

class _HistoryBottomNav extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onStatistics;
  final VoidCallback onHistory;

  const _HistoryBottomNav({
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
            _HistBottomNavItem(
              icon: Icons.home_rounded,
              label: 'Trang chủ',
              isSelected: false,
              onTap: onHome,
            ),
            _HistBottomNavItem(
              icon: Icons.analytics_rounded,
              label: 'Thống kê',
              isSelected: false,
              onTap: onStatistics,
            ),
            _HistBottomNavItem(
              icon: Icons.history_rounded,
              label: 'Lịch sử',
              isSelected: true,
              onTap: onHistory,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistBottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _HistBottomNavItem({
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
