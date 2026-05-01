import 'package:flutter/material.dart';

import '../services/system_service.dart';
import '../utils/app_theme.dart';

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

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'ERROR':
        return Colors.red;
      case 'WARNING':
      case 'WARN':
        return Colors.orange;
      case 'INFO':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getTypeText(String type) {
    final value = type.toUpperCase();
    return value.isEmpty ? '' : '[$value]';
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !_isRead(n)).length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppTheme.primary,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Mark all as read'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildMessageState(_errorMessage!)
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              color: AppTheme.primary,
              child: Column(
                children: [
                  if (unreadCount > 0)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$unreadCount thông báo mới',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  Expanded(
                    child: _notifications.isEmpty
                        ? _buildMessageState('Chưa có thông báo')
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) {
                              final notification = _notifications[index];
                              return _buildNotificationTile(notification);
                            },
                          ),
                  ),
                ],
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
        Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center, style: AppTheme.bodyMedium),
      ],
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    final type = _notificationType(notification);
    final isRead = _isRead(notification);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ListTile(
        onTap: () => _markAsRead(notification),
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getTypeColor(type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            type == 'ERROR'
                ? Icons.error
                : type == 'WARNING' || type == 'WARN'
                ? Icons.warning
                : Icons.info,
            color: _getTypeColor(type),
            size: 24,
          ),
        ),
        title: Text(
          notification['title']?.toString() ?? 'Thông báo',
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['message']?.toString() ?? '',
              style: AppTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(_notificationTime(notification), style: AppTheme.caption),
                const SizedBox(width: 8),
                Text(
                  _getTypeText(type),
                  style: TextStyle(fontSize: 10, color: _getTypeColor(type)),
                ),
              ],
            ),
          ],
        ),
        trailing: isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }
}

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
