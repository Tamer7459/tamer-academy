import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/app_notification.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _timeAgo(DateTime dt, BuildContext context) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'homework_submitted':
        return Icons.assignment_rounded;
      case 'exercise_submitted':
        return Icons.edit_note_rounded;
      case 'homework_reviewed':
      case 'exercise_reviewed':
        return Icons.star_rounded;
      case 'request_created':
        return Icons.mark_email_read_rounded;
      case 'request_approved':
        return Icons.check_circle_rounded;
      case 'request_rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'homework_submitted':
        return AppColors.warning;
      case 'exercise_submitted':
        return AppColors.tealPrimary;
      case 'homework_reviewed':
      case 'exercise_reviewed':
        return AppColors.success;
      case 'request_created':
        return AppColors.goldPrimary;
      case 'request_approved':
        return AppColors.success;
      case 'request_rejected':
        return AppColors.danger;
      default:
        return AppColors.tealPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final db = context.read<DatabaseService>();
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('يجب تسجيل الدخول')));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          TextButton(
            onPressed: () => db.markAllNotificationsRead(uid),
            child: const Text('تعليم الكل كمقروء'),
          ),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: db.notificationsStream(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppColors.tealPrimary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
                    child: Icon(Icons.notifications_none_rounded, size: 48, color: AppColors.tealPrimary.withValues(alpha: 0.4)),
                  ),
                  const SizedBox(height: 16),
                  const Text('لا توجد إشعارات', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.grayMedium)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final n = list[i];
              final color = _colorFor(n.type);
              return InkWell(
                onTap: () {
                  if (!n.isRead) db.markNotificationRead(n.id);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: n.isRead ? Theme.of(context).colorScheme.surface : color.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: n.isRead ? Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3) : color.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                        child: Icon(_iconFor(n.type), size: 18, color: color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14))),
                                if (!n.isRead)
                                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(n.body, style: TextStyle(fontSize: 13, color: AppColors.grayMedium, height: 1.5)),
                            const SizedBox(height: 6),
                            Text(_timeAgo(n.createdAt, context), style: TextStyle(fontSize: 11, color: AppColors.grayLight)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
