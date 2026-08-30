import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../models/app_user.dart';
import '../../models/course.dart';
import '../../services/database_service.dart';

class UsersScreen extends StatefulWidget {
  final AppUser user;
  const UsersScreen({super.key, required this.user});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  Future<void> _showEditUser(AppUser user, String Function(String) t) async {
    final db = context.read<DatabaseService>();
    final nameController = TextEditingController(text: user.name);
    String role = user.role;
    final isSelf = user.uid == widget.user.uid;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t('editUser')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(labelText: t('name')),
            ),
            if (!isSelf) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: role,
                decoration: InputDecoration(labelText: t('userRole')),
                items: [
                  DropdownMenuItem(value: 'student', child: Text(t('student'))),
                  DropdownMenuItem(value: 'admin', child: Text(t('adminRole'))),
                ],
                onChanged: (v) {
                  if (v != null) role = v;
                },
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(t('save')),
          ),
        ],
      ),
    );

    final name = nameController.text.trim();
    nameController.dispose();
    if (saved == true && name.isNotEmpty) {
      if (name != user.name) {
        await db.updateUserName(user.uid, name);
      }
      if (!isSelf && role != user.role) {
        await db.setUserRole(user.uid, role);
      }
    }
  }

  Future<void> _confirmDeleteUser(AppUser user, String Function(String) t) async {
    final db = context.read<DatabaseService>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t('deleteUser')),
        content: Text(t('deleteUserConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(t('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(t('delete')),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      try {
        await db.deleteUser(user.uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t('userDeleted')), behavior: SnackBarBehavior.floating),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${t('error')}: $e'), behavior: SnackBarBehavior.floating),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final theme = Theme.of(context);
    final db = context.watch<DatabaseService>();

    return StreamBuilder<List<AppUser>>(
      stream: db.allUsersStream(),
      builder: (context, usersSnap) {
        final users = usersSnap.data ?? [];

        if (usersSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_off_rounded, size: 56, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Text(t('members'), style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          );
        }

        return StreamBuilder<List<Course>>(
          stream: db.coursesStream(),
          builder: (context, coursesSnap) {
            final courses = coursesSnap.data ?? [];

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: users.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final user = users[i];
                final isSelf = user.uid == widget.user.uid;
                return Card(
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: (user.isAdmin
                              ? AppColors.warning
                              : AppColors.accent)
                          .withValues(alpha: 0.15),
                      backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
                      child: user.photoUrl.isEmpty
                          ? Icon(
                              user.isAdmin
                                  ? Icons.admin_panel_settings_rounded
                                  : Icons.person_rounded,
                              color: user.isAdmin
                                  ? AppColors.warning
                                  : AppColors.accent,
                            )
                          : null,
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(user.email,
                        style: const TextStyle(fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelf)
                          const Chip(
                            label: Text('أنت', style: TextStyle(fontSize: 11)),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.symmetric(horizontal: 6),
                          )
                        else
                          PopupMenuButton<String>(
                            tooltip: t('userRole'),
                            icon: Icon(
                              user.isAdmin
                                  ? Icons.admin_panel_settings_rounded
                                  : Icons.swap_horiz_rounded,
                              size: 20,
                              color: user.isAdmin
                                  ? AppColors.warning
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            onSelected: (role) async {
                              await db.setUserRole(user.uid, role);
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(value: 'student', child: Text(t('student'))),
                              PopupMenuItem(value: 'admin', child: Text(t('adminRole'))),
                            ],
                          ),
                        IconButton(
                          tooltip: t('edit'),
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => _showEditUser(user, t),
                        ),
                        if (!isSelf)
                          IconButton(
                            tooltip: t('deleteUser'),
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                              color: theme.colorScheme.error,
                            ),
                            onPressed: () => _confirmDeleteUser(user, t),
                          ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('accessCourses'),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (courses.isEmpty)
                              Text(t('noCourses'),
                                  style: TextStyle(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))
                            else
                              ...courses.map((course) {
                                final lang = l10n.languageCode;
                                final has = user.hasAccess(course.id);
                                return CheckboxListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  value: has,
                                  title: Text(course.title.get(lang),
                                      style: const TextStyle(fontSize: 14)),
                                  subtitle: Text(
                                    course.isFree ? t('free') : '${course.price} \$',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  onChanged: (v) {
                                    db.toggleUserCourseAccess(user.uid, course.id, v ?? false);
                                  },
                                );
                              }),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}