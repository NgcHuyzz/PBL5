import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/system_service.dart';
import '../utils/app_theme.dart';
import 'history_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'statistics_screen.dart';
import 'system_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoadingSystems = true;
  String? _systemsError;
  List<Map<String, dynamic>> _systems = [];
  Map<String, dynamic>? _selectedSystem;

  @override
  void initState() {
    super.initState();
    _loadSystems();
  }

  Future<void> _loadSystems() async {
    setState(() {
      _isLoadingSystems = true;
      _systemsError = null;
    });

    final result = await SystemService.getSystems();
    if (!mounted) return;

    if (result['success'] == false) {
      setState(() {
        _systems = [];
        _selectedSystem = null;
        _systemsError = result['message'] ?? 'Không thể tải danh sách hệ thống';
        _isLoadingSystems = false;
      });
      return;
    }

    final systems = _extractSystems(result);
    setState(() {
      _systems = systems;
      _selectedSystem = _chooseSelectedSystem(systems);
      _isLoadingSystems = false;
    });
  }

  Map<String, dynamic>? _chooseSelectedSystem(
    List<Map<String, dynamic>> systems,
  ) {
    if (systems.isEmpty) return null;

    final currentId = _systemId(_selectedSystem);
    if (currentId != null) {
      for (final system in systems) {
        if (_systemId(system) == currentId) {
          return system;
        }
      }
    }

    return systems.first;
  }

  void _openSystem(Map<String, dynamic> system) {
    final systemId = _systemId(system);
    if (systemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hệ thống này chưa có systemId')),
      );
      return;
    }

    setState(() => _selectedSystem = system);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SystemDetailScreen(
          systemName: _systemName(system),
          systemId: systemId,
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    final selectedSystemId = _systemId(_selectedSystem);

    switch (_selectedIndex) {
      case 1:
        return StatisticsScreen(systemId: selectedSystemId);
      case 2:
        return HistoryScreen(systemId: selectedSystemId);
      case 3:
        return const ProfileScreen();
      default:
        return HomeContent(
          systems: _systems,
          selectedSystemId: selectedSystemId,
          isLoading: _isLoadingSystems,
          errorMessage: _systemsError,
          onRefresh: _loadSystems,
          onOpenSystem: _openSystem,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _buildCurrentScreen(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textHint,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'TRANG CHỦ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'THỐNG KÊ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'LỊCH SỬ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'CÁ NHÂN',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final List<Map<String, dynamic>> systems;
  final String? selectedSystemId;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRefresh;
  final ValueChanged<Map<String, dynamic>> onOpenSystem;

  const HomeContent({
    super.key,
    required this.systems,
    required this.selectedSystemId,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    required this.onOpenSystem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
            ),
            Text(
              'Hệ thống của tôi',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white),
              onPressed: () {
                if (selectedSystemId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chưa chọn hệ thống')),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NotificationsScreen(systemId: selectedSystemId),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        color: AppTheme.primary,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          Icon(Icons.cloud_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ),
        ],
      );
    }

    if (systems.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          Icon(
            Icons.precision_manufacturing,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có hệ thống nào',
            textAlign: TextAlign.center,
            style: AppTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Kéo xuống để tải lại danh sách hệ thống.',
            textAlign: TextAlign.center,
            style: AppTheme.bodySmall,
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: systems.length,
      itemBuilder: (context, index) {
        final system = systems[index];
        return _buildSystemCard(context, system);
      },
    );
  }

  Widget _buildSystemCard(BuildContext context, Map<String, dynamic> system) {
    final systemId = _systemId(system);
    final isSelected = systemId != null && systemId == selectedSystemId;
    final status = _systemStatus(system);
    final statusColor = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? Border.all(color: AppTheme.primary, width: 1.5)
            : null,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onOpenSystem(system),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primary,
                        AppTheme.primary.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _systemName(system),
                              style: AppTheme.titleLarge,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _systemDescription(system),
                        style: AppTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: AppTheme.textHint,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _systemLocation(system),
                              style: AppTheme.caption,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: AppTheme.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(_systemCreated(system), style: AppTheme.caption),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<Map<String, dynamic>> _extractSystems(Map<String, dynamic> response) {
  final data = response['data'];
  final source = data is Map<String, dynamic>
      ? data['content'] ?? data['systems'] ?? data['items']
      : data ?? response['content'] ?? response['systems'] ?? response['items'];

  if (source is! List) {
    return [];
  }

  return source
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

String? _systemId(Map<String, dynamic>? system) {
  if (system == null) return null;

  for (final key in ['id', 'systemId', 'uuid']) {
    final value = system[key];
    if (value != null && value.toString().isNotEmpty) {
      return value.toString();
    }
  }

  return null;
}

String _systemName(Map<String, dynamic> system) {
  return system['name']?.toString() ??
      system['systemName']?.toString() ??
      'Hệ thống chưa đặt tên';
}

String _systemDescription(Map<String, dynamic> system) {
  return system['description']?.toString() ?? 'Chưa có mô tả';
}

String _systemLocation(Map<String, dynamic> system) {
  return system['location']?.toString() ?? 'Chưa có vị trí';
}

String _systemCreated(Map<String, dynamic> system) {
  final value = system['created'] ?? system['createdAt'];
  if (value == null) return '--/--/----';

  final parsed = DateTime.tryParse(value.toString());
  if (parsed == null) {
    return value.toString();
  }

  return '${parsed.day}/${parsed.month}/${parsed.year}';
}

String _systemStatus(Map<String, dynamic> system) {
  return system['status']?.toString() ??
      system['systemStatus']?.toString() ??
      'UNKNOWN';
}

Color _statusColor(String status) {
  switch (status.toUpperCase()) {
    case 'ACTIVE':
    case 'RUNNING':
    case 'ONLINE':
      return Colors.green;
    case 'MAINTENANCE':
    case 'PAUSED':
      return Colors.orange;
    case 'ERROR':
    case 'STOPPED':
    case 'OFFLINE':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
