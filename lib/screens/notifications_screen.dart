import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Lỗi cảm biến',
      'message': 'Cảm biến tại Conveyor 01 không phản hồi.',
      'time': '10:30 - 24/05/2026',
      'type': 'ERROR',
      'read': false,
    },
    {
      'title': 'Tốc độ băng chuyền cao',
      'message': 'Băng chuyền đang chạy vượt mức khuyến nghị.',
      'time': '09:15 - 24/05/2026',
      'type': 'WARNING',
      'read': false,
    },
    {
      'title': 'Báo cáo hàng ngày',
      'message': 'Báo cáo thống kê ngày 23/05 đã sẵn sàng.',
      'time': '08:00 - 24/05/2026',
      'type': 'INFO',
      'read': true,
    },
    {
      'title': 'Hệ thống đã khởi động',
      'message': 'Berry Conveyor 01 đã bắt đầu hoạt động.',
      'time': '07:30 - 24/05/2026',
      'type': 'INFO',
      'read': true,
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['read'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã đánh dấu tất cả là đã đọc')),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'ERROR': return Colors.red;
      case 'WARNING': return Colors.orange;
      case 'INFO': return Colors.blue;
      default: return Colors.grey;
    }
  }

  String _getTypeText(String type) {
    switch (type) {
      case 'ERROR': return '[ERROR]';
      case 'WARNING': return '[WARNING]';
      case 'INFO': return '[INFO]';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    int unreadCount = _notifications.where((n) => !n['read']).length;

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
      body: Column(
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
                'TRANG THÁI HỆ THỐNG  # Thông báo mới',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getTypeColor(notification['type']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        notification['type'] == 'ERROR'
                            ? Icons.error
                            : notification['type'] == 'WARNING'
                                ? Icons.warning
                                : Icons.info,
                        color: _getTypeColor(notification['type']),
                        size: 24,
                      ),
                    ),
                    title: Text(
                      notification['title'],
                      style: TextStyle(
                        fontWeight: notification['read'] ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification['message'], style: AppTheme.bodySmall),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(notification['time'], style: AppTheme.caption),
                            const SizedBox(width: 8),
                            Text(
                              _getTypeText(notification['type']),
                              style: TextStyle(
                                fontSize: 10,
                                color: _getTypeColor(notification['type']),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: notification['read']
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
              },
            ),
          ),
        ],
      ),
    );
  }
}