// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import '../services/system_service.dart';
import '../utils/app_theme.dart';
import 'notifications_screen.dart';

class HistoryScreen extends StatefulWidget {
  final String? systemId;

  const HistoryScreen({super.key, this.systemId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = false;
  bool _isLoadingMore = false;
  List<Map<String, dynamic>> _detections = [];
  int _currentPage = 0;
  int _totalPages = 1;

  // Filter values
  String? _selectedFruitType;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  final Map<String, String> _fruitTypes = {
    'all': 'Tất cả',
    'apple': '🍎 Táo',
    'banana': '🍌 Chuối',
    'orange': '🍊 Cam',
    'strawberry': '🍓 Dâu tây',
    'raspberry': '🍓 Mâm xôi',
  };

  final Map<String, String> _statuses = {
    'all': 'Tất cả',
    'COMPLETED': '✅ Hoàn thành',
    'FAILED': '❌ Lỗi',
    'REJECTED': '⚠️ Từ chối',
  };

  final Map<String, Color> _statusColors = {
    'COMPLETED': AppTheme.success,
    'FAILED': AppTheme.error,
    'REJECTED': AppTheme.warning,
  };

  @override
  void initState() {
    super.initState();
    if (widget.systemId != null && widget.systemId!.isNotEmpty) {
      _loadHistory();
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
      // Hiển thị lỗi nếu cần
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Lỗi tải lịch sử'),
            backgroundColor: AppTheme.error,
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Lịch sử phân loại'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppTheme.primary,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              if (widget.systemId == null || widget.systemId!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chưa chọn hệ thống')),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NotificationsScreen(systemId: widget.systemId),
                ),
              );
            },
          ),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryLight,
            child: const Icon(Icons.person, size: 18, color: AppTheme.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter section
          _buildFilterSection(),
          const SizedBox(height: 8),
          // History list
          Expanded(
            child: widget.systemId == null || widget.systemId!.isEmpty
                ? _buildMessageState('Chưa chọn hệ thống')
                : _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _detections.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _detections.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _detections.length) {
                        if (_currentPage + 1 < _totalPages) {
                          return _buildLoadMoreButton();
                        } else {
                          return const SizedBox.shrink();
                        }
                      }
                      return _buildHistoryCard(_detections[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, size: 18, color: AppTheme.textHint),
              const SizedBox(width: 8),
              Text(
                'Bộ lọc tìm kiếm',
                style: AppTheme.titleMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Dropdown loại quả
          DropdownButtonFormField<String>(
            initialValue: _selectedFruitType,
            decoration: InputDecoration(
              labelText: 'Chọn loại quả',
              labelStyle: AppTheme.caption,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: _fruitTypes.entries.map((e) {
              return DropdownMenuItem(
                value: e.key == 'all' ? null : e.key,
                child: Text(e.value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedFruitType = value;
              });
            },
          ),
          const SizedBox(height: 12),
          // Dropdown trạng thái
          DropdownButtonFormField<String>(
            initialValue: _selectedStatus,
            decoration: InputDecoration(
              labelText: 'Chọn trạng thái',
              labelStyle: AppTheme.caption,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: _statuses.entries.map((e) {
              return DropdownMenuItem(
                value: e.key == 'all' ? null : e.key,
                child: Text(e.value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
          ),
          const SizedBox(height: 12),
          // Date range
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _startDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.textHint.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppTheme.textHint,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _startDate != null
                              ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                              : 'Ngày bắt đầu',
                          style: AppTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _endDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.textHint.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppTheme.textHint,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _endDate != null
                              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : 'Ngày kết thúc',
                          style: AppTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: _resetFilters,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.outlineVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Xóa lọc'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Lọc kết quả'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> detection) {
    final fruitType = detection['fruitType']?.toString() ?? 'unknown';
    final confidence = _asDouble(detection['confidence']);
    final targetBin = detection['targetBin']?.toString() ?? '---';
    final classifiedAt = detection['classifiedAt']?.toString();
    final status = detection['status']?.toString() ?? 'COMPLETED';
    final isError = status == 'FAILED' || status == 'REJECTED';
    final fruitName = _fruitTypes[fruitType] ?? fruitType;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to detail screen
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image placeholder
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  image: detection['imageUrl'] != null
                      ? DecorationImage(
                          image: NetworkImage(detection['imageUrl']),
                          fit: BoxFit.cover,
                          colorFilter: isError
                              ? const ColorFilter.mode(
                                  Colors.grey,
                                  BlendMode.saturation,
                                )
                              : null,
                        )
                      : null,
                ),
                child: detection['imageUrl'] == null
                    ? Icon(
                        Icons.qr_code_scanner,
                        size: 30,
                        color: AppTheme.primary.withValues(alpha: 0.5),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          fruitName,
                          style: AppTheme.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (status != 'COMPLETED')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColors[status]?.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _statuses[status] ?? status,
                              style: TextStyle(
                                fontSize: 10,
                                color: _statusColors[status],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ĐỘ TIN CẬY',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AppTheme.textHint,
                                ),
                              ),
                              Text(
                                '${(confidence * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isError
                                      ? AppTheme.error
                                      : AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'THÙNG CHỨA',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AppTheme.textHint,
                                ),
                              ),
                              Text(
                                targetBin,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppTheme.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(classifiedAt),
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
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: _isLoadingMore
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: _loadMore,
                icon: const Icon(Icons.expand_more),
                label: const Text('Tải thêm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primary,
                  side: BorderSide(color: AppTheme.outlineVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Chưa có lịch sử phân loại',
            style: AppTheme.titleMedium.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy bắt đầu phân loại trái cây đầu tiên',
            style: AppTheme.bodySmall,
          ),
        ],
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
