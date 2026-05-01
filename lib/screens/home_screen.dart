import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/system_service.dart';
import '../utils/app_theme.dart';
import 'create_system_screen.dart';
import 'profile_screen.dart';
import 'system_detail_screen.dart';

const Color _primary = Color(0xFF8C0011);
const Color _primaryContainer = Color(0xFFB01E23);
const Color _secondaryContainer = Color(0xFFB9EEAB);
const Color _onSecondaryContainer = Color(0xFF3F6D38);
const Color _errorContainer = Color(0xFFFFDAD6);
const Color _onErrorContainer = Color(0xFF93000A);
const Color _surface = Color(0xFFFCF9F8);
const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
const Color _surfaceVariant = Color(0xFFE5E2E1);
const Color _onSurface = Color(0xFF1B1C1C);
const Color _onSurfaceVariant = Color(0xFF5A403E);
const Color _outlineVariant = Color(0xFFE3BEBB);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  Future<void> _openCreateSystem() async {
    final message = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const CreateSystemScreen()),
    );

    if (!mounted || message == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
    await _loadSystems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: HomeContent(
        systems: _systems,
        selectedSystemId: _systemId(_selectedSystem),
        isLoading: _isLoadingSystems,
        errorMessage: _systemsError,
        onRefresh: _loadSystems,
        onOpenSystem: _openSystem,
        onCreateSystem: _openCreateSystem,
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
  final VoidCallback onCreateSystem;

  const HomeContent({
    super.key,
    required this.systems,
    required this.selectedSystemId,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    required this.onOpenSystem,
    required this.onCreateSystem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        toolbarHeight: 72,
        titleSpacing: 16,
        title: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.menu_rounded),
              color: _onSurfaceVariant,
              tooltip: 'Menu',
            ),
            const SizedBox(width: 12),
            Text(
              'Hệ thống của tôi',
              style: GoogleFonts.manrope(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _onSurface,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _onSurfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _outlineVariant.withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onCreateSystem,
        backgroundColor: _primaryContainer,
        foregroundColor: Colors.white,
        elevation: 14,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, size: 34),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        color: _primary,
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
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
              ),
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
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút + để tạo hệ thống mới hoặc kéo xuống để tải lại.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: _onSurfaceVariant),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 112),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 2 : 1,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            mainAxisExtent: 320,
          ),
          itemCount: systems.length,
          itemBuilder: (context, index) {
            final system = systems[index];
            return _buildSystemCard(context, system);
          },
        );
      },
    );
  }

  Widget _buildSystemCard(BuildContext context, Map<String, dynamic> system) {
    final systemId = _systemId(system);
    final isSelected = systemId != null && systemId == selectedSystemId;
    final status = _systemStatus(system);
    final statusStyle = _statusStyle(status);
    final isStopped = _isStoppedStatus(status);

    return Container(
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: _primary.withValues(alpha: 0.16), width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onOpenSystem(system),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusStyle.background,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      statusStyle.label,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: statusStyle.foreground,
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _systemIcon(system),
                      color: isStopped ? Colors.grey.shade400 : _primary,
                      size: 34,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _systemName(system),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _systemDescription(system),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        height: 1.35,
                        color: _onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      height: 1,
                      color: _surfaceVariant.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 18),
                    _buildMetaRow(
                      Icons.location_on_rounded,
                      _systemLocation(system),
                    ),
                    const SizedBox(height: 14),
                    _buildMetaRow(
                      Icons.calendar_today_rounded,
                      'Khởi tạo: ${_systemCreated(system)}',
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => onOpenSystem(system),
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Chi tiết'),
                        style: TextButton.styleFrom(
                          foregroundColor: _primary,
                          textStyle: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: _onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusStyle {
  final String label;
  final Color background;
  final Color foreground;

  const _StatusStyle({
    required this.label,
    required this.background,
    required this.foreground,
  });
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

  for (final key in ['systemId', 'id', 'uuid']) {
    final value = system[key];
    if (value != null && value.toString().isNotEmpty) {
      return value.toString();
    }
  }

  return null;
}

String _systemName(Map<String, dynamic> system) {
  return system['systemName']?.toString() ??
      system['name']?.toString() ??
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

IconData _systemIcon(Map<String, dynamic> system) {
  final name = _systemName(system).toLowerCase();
  if (name.contains('conveyor')) return Icons.conveyor_belt;
  if (name.contains('ai') || name.contains('sorter')) {
    return Icons.precision_manufacturing_rounded;
  }
  if (name.contains('environment') || name.contains('monitor')) {
    return Icons.sensors_rounded;
  }
  if (name.contains('pack')) return Icons.tune_rounded;

  return Icons.precision_manufacturing_rounded;
}

bool _isStoppedStatus(String status) {
  switch (status.toUpperCase()) {
    case 'STOPPED':
    case 'OFFLINE':
    case 'ERROR':
      return true;
    default:
      return false;
  }
}

_StatusStyle _statusStyle(String status) {
  switch (status.toUpperCase()) {
    case 'ACTIVE':
    case 'RUNNING':
    case 'ONLINE':
      return const _StatusStyle(
        label: 'ĐANG CHẠY',
        background: _secondaryContainer,
        foreground: _onSecondaryContainer,
      );
    case 'IDLE':
      return const _StatusStyle(
        label: 'SẴN SÀNG',
        background: Color(0xFFFFDAD7),
        foreground: _primary,
      );
    case 'PAUSED':
    case 'MAINTENANCE':
      return const _StatusStyle(
        label: 'TẠM DỪNG',
        background: Color(0xFFFFE0B2),
        foreground: Color(0xFF7A4B00),
      );
    case 'ERROR':
      return const _StatusStyle(
        label: 'LỖI',
        background: _errorContainer,
        foreground: _onErrorContainer,
      );
    case 'STOPPED':
    case 'OFFLINE':
      return const _StatusStyle(
        label: 'DỪNG',
        background: _errorContainer,
        foreground: _onErrorContainer,
      );
    default:
      return const _StatusStyle(
        label: 'UNKNOWN',
        background: _surfaceVariant,
        foreground: _onSurfaceVariant,
      );
  }
}
