import 'package:flutter/material.dart';

import '../screens/notifications_screen.dart';
import '../services/system_service.dart';

class NotificationBellButton extends StatefulWidget {
  final String? systemId;
  final Color? color;

  const NotificationBellButton({super.key, required this.systemId, this.color});

  @override
  State<NotificationBellButton> createState() => _NotificationBellButtonState();
}

class _NotificationBellButtonState extends State<NotificationBellButton> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  @override
  void didUpdateWidget(covariant NotificationBellButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.systemId != widget.systemId) {
      _loadUnreadCount();
    }
  }

  Future<void> _loadUnreadCount() async {
    final systemId = widget.systemId;
    if (systemId == null || systemId.isEmpty) {
      if (mounted) {
        setState(() => _unreadCount = 0);
      }
      return;
    }

    final result = await SystemService.getUnreadCount(systemId);
    if (!mounted) return;

    setState(() {
      _unreadCount = result['success'] == true
          ? _extractUnreadCount(result['data'] ?? result)
          : 0;
    });
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsScreen(systemId: widget.systemId),
      ),
    );
    if (!mounted) return;
    await _loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _openNotifications,
      tooltip: 'Thông báo',
      color: widget.color,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_rounded),
          if (_unreadCount > 0)
            Positioned(
              right: -7,
              top: -7,
              child: _UnreadBadge(count: _unreadCount),
            ),
        ],
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;

  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : count.toString();

    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFBA1A1A),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          height: 1,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

int _extractUnreadCount(Object? data) {
  if (data is num) return data.toInt();
  if (data is String) return int.tryParse(data) ?? 0;
  if (data is Map) {
    for (final key in ['unreadCount', 'count', 'totalUnread', 'total']) {
      final value = data[key];
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
    }
  }

  return 0;
}
