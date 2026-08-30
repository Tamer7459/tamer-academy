import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../screens/notifications/notifications_screen.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final db = context.watch<DatabaseService>();
    final uid = auth.currentUser?.uid;
    if (uid == null) return const Icon(Icons.notifications_none_rounded);

    return StreamBuilder<int>(
      stream: db.unreadCountStream(uid),
      builder: (context, snap) {
        final count = snap.data ?? 0;
        return Badge(
          isLabelVisible: count > 0,
          label: Text(count > 99 ? '99+' : '$count', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
          backgroundColor: Colors.redAccent,
          child: IconButton(
            tooltip: 'الإشعارات',
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
            },
          ),
        );
      },
    );
  }
}
