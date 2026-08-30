import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../models/access_request.dart';
import '../../services/database_service.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final db = context.watch<DatabaseService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<List<AccessRequest>>(
      stream: db.accessRequestsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('${t('error')}: ${snapshot.error}'));
        }
        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.tealPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.inbox_rounded, size: 48, color: AppColors.tealPrimary.withValues(alpha: 0.4)),
                ),
                const SizedBox(height: 16),
                Text(t('noRequests'), style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.grayMedium)),
              ],
            ),
          );
        }

        // Filter tabs
        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                labelColor: AppColors.tealPrimary,
                unselectedLabelColor: AppColors.grayMedium,
                indicatorColor: AppColors.tealPrimary,
                tabs: [
                  Tab(text: t('pending')),
                  Tab(text: t('approved')),
                  Tab(text: t('denied')),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _RequestList(requests: requests.where((r) => r.status == 'pending').toList(), isDark: isDark),
                    _RequestList(requests: requests.where((r) => r.status == 'approved').toList(), isDark: isDark),
                    _RequestList(requests: requests.where((r) => r.status == 'denied').toList(), isDark: isDark),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RequestList extends StatelessWidget {
  final List<AccessRequest> requests;
  final bool isDark;
  const _RequestList({required this.requests, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final theme = Theme.of(context);

    if (requests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(t('noRequests'), style: TextStyle(color: AppColors.grayMedium)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final req = requests[i];
        Color statusColor;
        IconData statusIcon;
        switch (req.status) {
          case 'approved':
            statusColor = AppColors.success;
            statusIcon = Icons.check_circle_rounded;
            break;
          case 'denied':
            statusColor = AppColors.danger;
            statusIcon = Icons.cancel_rounded;
            break;
          default:
            statusColor = AppColors.warning;
            statusIcon = Icons.hourglass_top_rounded;
        }

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(statusIcon, size: 18, color: statusColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(req.userName, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: isDark ? Colors.white : AppColors.navyText)),
                          Text(req.userEmail, style: TextStyle(fontSize: 12, color: AppColors.grayMedium)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(t(req.status), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.tealPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.menu_book_rounded, size: 14, color: AppColors.tealPrimary),
                      const SizedBox(width: 6),
                      Flexible(child: Text(req.courseTitle, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.tealPrimary))),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${req.createdAt.day}/${req.createdAt.month}/${req.createdAt.year} ${req.createdAt.hour}:${req.createdAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 11, color: AppColors.grayLight),
                ),
                if (req.status == 'pending') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            await context.read<DatabaseService>().updateRequestStatus(req.id, 'approved');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('approved')), behavior: SnackBarBehavior.floating));
                            }
                          },
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: Text(t('approve')),
                          style: FilledButton.styleFrom(backgroundColor: AppColors.success, padding: const EdgeInsets.symmetric(vertical: 10)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await context.read<DatabaseService>().updateRequestStatus(req.id, 'denied');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('denied')), behavior: SnackBarBehavior.floating));
                            }
                          },
                          icon: const Icon(Icons.close_rounded, size: 18),
                          label: Text(t('deny')),
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: BorderSide(color: AppColors.danger.withValues(alpha: 0.3))),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: IconButton(
                      tooltip: t('delete'),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(t('deleteConfirm')),
                            content: Text(t('deleteWarning')),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('cancel'))),
                              FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: AppColors.danger), child: Text(t('delete'))),
                            ],
                          ),
                        );
                        if (ok == true && context.mounted) {
                          await context.read<DatabaseService>().deleteRequest(req.id);
                        }
                      },
                      icon: Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.grayMedium),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
