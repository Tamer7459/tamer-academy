import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../models/app_user.dart';
import '../../models/homework_submission.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../state/app_state.dart';
import '../homeworks/my_homeworks_screen.dart';

class ProfileScreen extends StatefulWidget {
  final AppUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final db = context.watch<DatabaseService>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ═══ Profile Header ═══
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.tealPrimary, AppColors.tealLight],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.surface,
                  backgroundImage: widget.user.photoUrl.isNotEmpty ? NetworkImage(widget.user.photoUrl) : null,
                  child: widget.user.photoUrl.isEmpty
                      ? Text(
                          widget.user.name.trim().isEmpty ? '?' : widget.user.name.trim()[0].toUpperCase(),
                          style: TextStyle(color: AppColors.tealPrimary, fontSize: 24, fontWeight: FontWeight.w900),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.user.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(widget.user.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.grayMedium, fontSize: 13)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: (widget.user.isAdmin ? AppColors.warning : AppColors.tealLight).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.user.isAdmin ? Icons.admin_panel_settings_rounded : Icons.school_rounded,
                            size: 14,
                            color: widget.user.isAdmin ? AppColors.warning : AppColors.tealLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.user.isAdmin ? t('adminRole') : t('student'),
                            style: TextStyle(
                              color: widget.user.isAdmin ? AppColors.warning : AppColors.tealLight,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ═══ Stats ═══
        StreamBuilder<Map<String, dynamic>>(
          stream: db.progressStream(widget.user.uid),
          builder: (context, snap) {
            final data = snap.data ?? {};
            final courses = Map<String, dynamic>.from(data['courses'] as Map? ?? {});
            var totalCompleted = 0;
            var totalAnswered = 0;
            courses.forEach((_, v) {
              final m = Map<String, dynamic>.from(v as Map? ?? {});
              totalCompleted += ((m['completed'] as List?)?.length ?? 0);
              totalAnswered += ((m['answered'] as List?)?.length ?? 0);
            });
            return Row(
              children: [
                Expanded(child: _StatCard(icon: Icons.check_circle_rounded, value: '$totalCompleted', label: t('completed'), color: AppColors.tealPrimary)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(icon: Icons.quiz_rounded, value: '$totalAnswered', label: t('exercisesSolved'), color: AppColors.peachStart)),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        if (!widget.user.isAdmin)
          StreamBuilder<List<HomeworkSubmission>>(
            stream: db.userHomeworkStream(widget.user.uid),
            builder: (context, snap) {
              final subs = snap.data ?? [];
              final pending = subs.where((s) => s.isPending).length;
              final reviewed = subs.where((s) => s.isReviewed).length;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [Icon(Icons.assignment_rounded, color: AppColors.tealPrimary, size: 20), const SizedBox(width: 8), Text(t('myHomeworks'), style: const TextStyle(fontWeight: FontWeight.w800)), const Spacer(), Text('$reviewed/${subs.length}', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.tealPrimary))]),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(value: subs.isEmpty ? 0 : reviewed / subs.length, minHeight: 6, backgroundColor: AppColors.grayLight.withValues(alpha: 0.3), color: AppColors.tealPrimary),
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(child: _StatCard(icon: Icons.hourglass_top_rounded, value: '$pending', label: t('pendingHomeworks'), color: AppColors.warning)),
                      const SizedBox(width: 8),
                      Expanded(child: _StatCard(icon: Icons.check_circle_rounded, value: '$reviewed', label: t('reviewedHomeworks'), color: AppColors.success)),
                    ]),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MyHomeworksScreen(user: widget.user))),
                        icon: const Icon(Icons.assignment_rounded, size: 18),
                        label: Text(t('myHomeworks')),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        if (!widget.user.isAdmin) const SizedBox(height: 24),

        // ═══ Settings ═══
        Text(t('settings'), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.tealPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.language_rounded, color: AppColors.tealPrimary, size: 22),
                ),
                title: Text(t('language'), style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: PopupMenuButton<String>(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.locale.languageCode == 'ar' ? t('arabic') : state.locale.languageCode == 'fr' ? t('french') : t('english'),
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.tealPrimary),
                      ),
                      const Icon(Icons.arrow_drop_down_rounded),
                    ],
                  ),
                  onSelected: (code) => context.read<AppState>().setLanguage(code),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'ar', child: Text(t('arabic'))),
                    PopupMenuItem(value: 'en', child: Text(t('english'))),
                    PopupMenuItem(value: 'fr', child: Text(t('french'))),
                  ],
                ),
              ),
              Divider(height: 1, indent: 16, endIndent: 16, color: theme.colorScheme.outlineVariant),
              SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.peachStart.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    state.themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: AppColors.peachStart,
                    size: 22,
                  ),
                ),
                title: Text(state.themeMode == ThemeMode.dark ? t('darkMode') : t('lightMode'), style: const TextStyle(fontWeight: FontWeight.w600)),
                value: state.themeMode == ThemeMode.dark,
                onChanged: (_) => context.read<AppState>().toggleTheme(),
              ),
              Divider(height: 1, indent: 16, endIndent: 16, color: theme.colorScheme.outlineVariant),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 22),
                ),
                title: Text(t('logout'), style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
                onTap: () async => await context.read<AuthService>().logout(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ═══ Footer ═══
        Center(
          child: Text(
            '© ${DateTime.now().year} ${t('appName')}',
            style: TextStyle(color: AppColors.grayLight, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.grayMedium)),
        ],
      ),
    );
  }
}