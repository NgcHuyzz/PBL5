import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/system_service.dart';
import '../utils/app_sizes.dart';

const Color _primary = Color(0xFF8C0011);
const Color _primaryContainer = Color(0xFFB01E23);
const Color _secondary = Color(0xFF3B6934);
const Color _secondaryContainer = Color(0xFFB9EEAB);
const Color _error = Color(0xFFBA1A1A);
const Color _errorContainer = Color(0xFFFFDAD6);
const Color _onErrorContainer = Color(0xFF93000A);
const Color _warning = Color(0xFFC56A21);
const Color _warningContainer = Color(0xFFFFE8CC);
const Color _surface = Color(0xFFFCF9F8);
const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
const Color _surfaceContainerLow = Color(0xFFF6F3F2);
const Color _surfaceContainer = Color(0xFFF0EDED);
const Color _onSurface = Color(0xFF1B1C1C);
const Color _onSurfaceVariant = Color(0xFF5A403E);

class NotificationsScreen extends StatefulWidget {
  final String? systemId;

  const NotificationsScreen({super.key, this.systemId});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
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
      _errorMessage = null;
    });

    final result = await SystemService.getNotifications(systemId);
    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _notifications = _extractNotifications(result['data']);
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Không thể tải thông báo';
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    final systemId = widget.systemId;
    if (systemId == null || systemId.isEmpty) return;

    final result = await SystemService.markAllNotificationsRead(systemId);
    if (!mounted) return;

    if (result['success'] == true) {
      await _loadNotifications();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đánh dấu tất cả là đã đọc')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Đánh dấu thất bại')),
      );
    }
  }

  Future<void> _markAsRead(Map<String, dynamic> notification) async {
    final systemId = widget.systemId;
    final notificationId = notification['id']?.toString();
    if (systemId == null ||
        systemId.isEmpty ||
        notificationId == null ||
        notificationId.isEmpty ||
        _isRead(notification)) {
      return;
    }

    final result = await SystemService.markNotificationRead(
      systemId,
      notificationId,
    );
    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _notifications = _notifications
            .map(
              (item) => item['id']?.toString() == notificationId
                  ? {...item, 'read': true, 'isRead': true}
                  : item,
            )
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !_isRead(n)).length;

    return Scaffold(
      backgroundColor: _surface,
      appBar: _buildTopBar(unreadCount),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : _errorMessage != null
          ? _buildMessageState(_errorMessage!)
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              color: _primary,
              child: _buildContent(),
            ),
    );
  }

  PreferredSizeWidget _buildTopBar(int unreadCount) {
    return AppBar(
      backgroundColor: _surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 62,
      leadingWidth: 58,
      leading: IconButton(
        onPressed: () => Navigator.maybePop(context),
        icon: const Icon(Icons.arrow_back_rounded),
        color: _primaryContainer,
        tooltip: 'Quay lại',
      ),
      titleSpacing: 0,
      title: Text(
        'Notifications',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.manrope(
          color: _onSurface,
          fontSize: AppSizes.fontDisplaySmall,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSizes.spacingL),
          child: TextButton(
            onPressed: unreadCount > 0 ? _markAllAsRead : null,
            style: TextButton.styleFrom(
              foregroundColor: _primaryContainer,
              disabledForegroundColor: _onSurfaceVariant.withValues(
                alpha: 0.34,
              ),
              textStyle: GoogleFonts.inter(
                fontSize: AppSizes.fontBody,
                fontWeight: FontWeight.w800,
              ),
            ),
            child: const Text('Mark all as read'),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, _) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSizes.spacingXXL,
            AppSizes.spacingM,
            AppSizes.spacingXXL,
            AppSizes.spacingXXL,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 880),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_notifications.isEmpty)
                      _buildEmptyState()
                    else
                      ..._notifications.map(_buildNotificationCard),
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
        Icon(
          Icons.notifications_none_rounded,
          size: 50,
          color: _onSurfaceVariant.withValues(alpha: 0.38),
        ),
        const SizedBox(height: AppSizes.spacingL),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: _onSurfaceVariant,
            fontSize: AppSizes.fontBody,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingXXL),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: _cardShadow,
      ),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 46,
            color: _onSurfaceVariant.withValues(alpha: 0.36),
          ),
          const SizedBox(height: AppSizes.spacingL),
          Text(
            'Chưa có thông báo',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: _onSurface,
              fontSize: AppSizes.fontHeadlineLarge,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSizes.spacingXS),
          Text(
            'Các cảnh báo và cập nhật hệ thống sẽ xuất hiện tại đây.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: _onSurfaceVariant,
              fontSize: AppSizes.fontCaption,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final type = _notificationType(notification);
    final isRead = _isRead(notification);
    final style = _styleForType(type);
    final title = notification['title']?.toString() ?? 'Thông báo';
    final message = notification['message']?.toString() ?? '';
    final relatedSystem =
        notification['systemName']?.toString() ??
        notification['systemId']?.toString() ??
        '';
    final time = _notificationTime(notification);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
      decoration: BoxDecoration(
        color: isRead
            ? _surfaceContainerLow.withValues(alpha: 0.5)
            : _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: isRead
            ? null
            : const Border(left: BorderSide(color: _primary, width: 5)),
        boxShadow: isRead ? null : _cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: InkWell(
          onTap: () => _markAsRead(notification),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          child: Opacity(
            opacity: isRead ? 0.78 : 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacingL,
                vertical: AppSizes.spacingM,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NotificationIcon(style: style),
                  const SizedBox(width: AppSizes.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: GoogleFonts.manrope(
                                  color: _onSurface,
                                  fontSize: AppSizes.fontTitleLarge,
                                  height: 1.15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (!isRead) ...[
                              const SizedBox(width: AppSizes.spacingS),
                              Container(
                                width: 7,
                                height: 7,
                                margin: const EdgeInsets.only(
                                  top: AppSizes.spacingXS,
                                ),
                                decoration: const BoxDecoration(
                                  color: _primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (message.isNotEmpty) ...[
                          const SizedBox(height: AppSizes.spacingXS),
                          Text(
                            message,
                            style: GoogleFonts.inter(
                              color: _onSurfaceVariant,
                              fontSize: AppSizes.fontBody,
                              height: 1.32,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (relatedSystem.isNotEmpty) ...[
                          const SizedBox(height: AppSizes.spacingXS),
                          Text(
                            relatedSystem,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: _onSurfaceVariant.withValues(alpha: 0.7),
                              fontSize: AppSizes.fontCaption - 1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSizes.spacingS),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                time,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  color: _onSurfaceVariant.withValues(
                                    alpha: 0.62,
                                  ),
                                  fontSize: AppSizes.fontCaption - 1,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSizes.spacingM),
                            _TypePill(style: style),
                          ],
                        ),
                      ],
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

class _NotificationStyle {
  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;
  final Color pillBackground;
  final Color pillForeground;

  const _NotificationStyle({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
    required this.pillBackground,
    required this.pillForeground,
  });
}

class _NotificationIcon extends StatelessWidget {
  final _NotificationStyle style;

  const _NotificationIcon({required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Icon(
        style.icon,
        color: style.foreground,
        size: AppSizes.iconMedium,
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final _NotificationStyle style;

  const _TypePill({required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingS,
        vertical: AppSizes.spacingXS,
      ),
      decoration: BoxDecoration(
        color: style.pillBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Text(
        style.label,
        style: GoogleFonts.inter(
          color: style.pillForeground,
          fontSize: AppSizes.fontCaption - 1,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

List<BoxShadow> get _cardShadow => [
  BoxShadow(
    color: _onSurfaceVariant.withValues(alpha: 0.025),
    blurRadius: 20,
    offset: const Offset(0, 4),
  ),
];

List<Map<String, dynamic>> _extractNotifications(Object? data) {
  final source = data is Map
      ? data['content'] ?? data['items'] ?? data['notifications']
      : data;

  if (source is! List) return [];

  return source
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

bool _isRead(Map<String, dynamic> notification) {
  return notification['read'] == true || notification['isRead'] == true;
}

String _notificationType(Map<String, dynamic> notification) {
  return (notification['type'] ?? notification['level'] ?? '')
      .toString()
      .toUpperCase();
}

_NotificationStyle _styleForType(String type) {
  switch (type.toUpperCase()) {
    case 'ERROR':
      return const _NotificationStyle(
        icon: Icons.error_rounded,
        label: 'ERROR',
        foreground: _error,
        background: _errorContainer,
        pillBackground: _errorContainer,
        pillForeground: _onErrorContainer,
      );
    case 'WARNING':
    case 'WARN':
      return const _NotificationStyle(
        icon: Icons.warning_rounded,
        label: 'WARNING',
        foreground: _warning,
        background: _warningContainer,
        pillBackground: _surfaceContainer,
        pillForeground: _onSurfaceVariant,
      );
    case 'SUCCESS':
      return const _NotificationStyle(
        icon: Icons.check_circle_rounded,
        label: 'SUCCESS',
        foreground: _secondary,
        background: _secondaryContainer,
        pillBackground: _surfaceContainer,
        pillForeground: _onSurfaceVariant,
      );
    case 'INFO':
    default:
      return const _NotificationStyle(
        icon: Icons.analytics_rounded,
        label: 'INFO',
        foreground: _secondary,
        background: _secondaryContainer,
        pillBackground: _surfaceContainer,
        pillForeground: _onSurfaceVariant,
      );
  }
}

String _notificationTime(Map<String, dynamic> notification) {
  final value =
      notification['time'] ??
      notification['createdAt'] ??
      notification['timestamp'] ??
      notification['sentAt'];
  if (value == null) return '';

  final parsed = DateTime.tryParse(value.toString());
  if (parsed == null) return value.toString();

  final time =
      '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
  return '$time - ${parsed.day}/${parsed.month}/${parsed.year}';
}
