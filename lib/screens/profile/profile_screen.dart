import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../models/app_user.dart';
import '../../models/course.dart';
import '../../models/exercise_submission.dart';
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
  AppUser? _viewedUser;
  String? _selectedUid;

  @override
  void initState() {
    super.initState();
    _viewedUser = widget.user;
    _selectedUid = widget.user.uid;
  }

  double _sumGrades(List<double?> grades) => grades.whereType<double>().fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final db = context.watch<DatabaseService>();
    final isAdmin = widget.user.isAdmin;
    final viewed = _viewedUser ?? widget.user;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ═══ Admin: اختيار أي حساب ═══
        if (isAdmin) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.admin_panel_settings_rounded, size: 18, color: AppColors.warning)),
                const SizedBox(width: 8),
                const Text('عرض حساب آخر', style: TextStyle(fontWeight: FontWeight.w800)),
                const Spacer(),
                if (_selectedUid != widget.user.uid)
                  TextButton(onPressed: () => setState(() { _viewedUser = widget.user; _selectedUid = widget.user.uid; }), child: const Text('العودة لحسابي')),
              ]),
              const SizedBox(height: 12),
              StreamBuilder<List<AppUser>>(
                stream: db.allUsersStream(),
                builder: (context, snap) {
                  final users = snap.data ?? [];
                  if (users.isEmpty) return const LinearProgressIndicator();
                  return DropdownButtonFormField<String>(
                    value: _selectedUid,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'اختر حساباً',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    items: users.map((u) => DropdownMenuItem(value: u.uid, child: Text('${u.name} — ${u.email} ${u.isAdmin ? "(أدمن)" : ""}', overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (uid) {
                      if (uid == null) return;
                      final found = users.firstWhere((x) => x.uid == uid, orElse: () => widget.user);
                      setState(() { _selectedUid = uid; _viewedUser = found; });
                    },
                  );
                },
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editUserDialog(viewed),
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('تعديل هذا الحساب'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _previewAsUser(viewed),
                    icon: const Icon(Icons.visibility_rounded, size: 18),
                    label: const Text('الدخول كطالب'),
                  ),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
        ],

        // ═══ Profile Header ═══
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outlineVariant),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.tealPrimary, AppColors.tealLight]), borderRadius: BorderRadius.circular(20)),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.surface,
                  backgroundImage: viewed.photoUrl.isNotEmpty ? NetworkImage(viewed.photoUrl) : null,
                  child: viewed.photoUrl.isEmpty ? Text(viewed.name.trim().isEmpty ? '?' : viewed.name.trim()[0].toUpperCase(), style: TextStyle(color: AppColors.tealPrimary, fontSize: 24, fontWeight: FontWeight.w900)) : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(viewed.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(viewed.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.grayMedium, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: (viewed.isAdmin ? AppColors.warning : AppColors.tealLight).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(100)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(viewed.isAdmin ? Icons.admin_panel_settings_rounded : Icons.school_rounded, size: 14, color: viewed.isAdmin ? AppColors.warning : AppColors.tealLight),
                      const SizedBox(width: 4),
                      Text(viewed.isAdmin ? t('adminRole') : t('student'), style: TextStyle(color: viewed.isAdmin ? AppColors.warning : AppColors.tealLight, fontWeight: FontWeight.w700, fontSize: 12)),
                    ]),
                  ),
                ]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ═══ Stats ═══
        StreamBuilder<Map<String, dynamic>>(
          stream: db.progressStream(viewed.uid),
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
            return Row(children: [
              Expanded(child: _StatCard(icon: Icons.check_circle_rounded, value: '$totalCompleted', label: t('completed'), color: AppColors.tealPrimary)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(icon: Icons.quiz_rounded, value: '$totalAnswered', label: t('exercisesSolved'), color: AppColors.peachStart)),
            ]);
          },
        ),
        const SizedBox(height: 16),

        // ═══ مجموع النقاط ═══
        StreamBuilder<List<HomeworkSubmission>>(
          stream: db.userHomeworkStream(viewed.uid),
          builder: (context, hwSnap) {
            return StreamBuilder<List<ExerciseSubmission>>(
              stream: db.userExerciseStream(viewed.uid),
              builder: (context, exSnap) {
                final hw = hwSnap.data ?? [];
                final ex = exSnap.data ?? [];
                final hwReviewed = hw.where((s) => s.isReviewed).toList();
                final exReviewed = ex.where((s) => s.isReviewed).toList();
                final totalHw = _sumGrades(hwReviewed.map((s) => s.grade).toList());
                final totalEx = _sumGrades(exReviewed.map((s) => s.grade).toList());
                final total = totalHw + totalEx;
                final count = hwReviewed.length + exReviewed.length;
                final avg = count == 0 ? 0 : total / count;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.outlineVariant)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Icon(Icons.star_rounded, color: AppColors.goldPrimary), const SizedBox(width: 8), const Text('مجموع النقاط', style: TextStyle(fontWeight: FontWeight.w800)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.goldPrimary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(100)), child: Text('${total.toStringAsFixed(total.truncateToDouble() == total ? 0 : 1).replaceAll('.', ',')} نقطة', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.goldPrimary)))]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _MiniStat(label: 'واجبات مصححة', value: '${hwReviewed.length}', sub: '${totalHw.toStringAsFixed(1).replaceAll('.', ',')} ن', color: AppColors.tealPrimary)),
                      const SizedBox(width: 8),
                      Expanded(child: _MiniStat(label: 'تمارين مصححة', value: '${exReviewed.length}', sub: '${totalEx.toStringAsFixed(1).replaceAll('.', ',')} ن', color: AppColors.success)),
                      const SizedBox(width: 8),
                      Expanded(child: _MiniStat(label: 'المعدل', value: count == 0 ? '-' : '${avg.toStringAsFixed(1).replaceAll('.', ',')}/10', sub: '$count تقييم', color: AppColors.warning)),
                    ]),
                  ]),
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),

        // ═══ الدورات التي لديه ═══
        StreamBuilder<List<Course>>(
          stream: db.coursesStream(),
          builder: (context, snap) {
            final all = snap.data ?? [];
            final myCourses = all.where((c) => viewed.accessCourses.contains(c.id)).toList();
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.outlineVariant)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Icon(Icons.menu_book_rounded, color: AppColors.tealPrimary, size: 20), const SizedBox(width: 8), Text('الدورات (${myCourses.length})', style: const TextStyle(fontWeight: FontWeight.w800)), const Spacer(), if (isAdmin) TextButton(onPressed: () => _manageCoursesDialog(viewed), child: const Text('إدارة'))]),
                const SizedBox(height: 12),
                if (myCourses.isEmpty)
                  Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.grayLight.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)), child: Text('لا يملك أي دورة', style: TextStyle(color: AppColors.grayMedium))),
                ...myCourses.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(12)),
                        child: Row(children: [
                          Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.tealPrimary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(c.track == 'web' ? Icons.language_rounded : Icons.smartphone_rounded, size: 18, color: AppColors.tealPrimary)),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(c.title.getWithFallback(l10n.languageCode), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), Text(c.track, style: TextStyle(fontSize: 11, color: AppColors.grayMedium)) ])),
                          if (c.isFree) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(100)), child: const Text('مجاني', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w700))),
                        ]),
                      ),
                    )),
              ]),
            );
          },
        ),
        const SizedBox(height: 16),
        if (!viewed.isAdmin)
          StreamBuilder<List<HomeworkSubmission>>(
            stream: db.userHomeworkStream(viewed.uid),
            builder: (context, snap) {
              final subs = snap.data ?? [];
              final pending = subs.where((s) => s.isPending).length;
              final reviewed = subs.where((s) => s.isReviewed).length;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.outlineVariant)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Icon(Icons.assignment_rounded, color: AppColors.tealPrimary, size: 20), const SizedBox(width: 8), Text(t('myHomeworks'), style: const TextStyle(fontWeight: FontWeight.w800)), const Spacer(), Text('$reviewed/${subs.length}', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.tealPrimary))]),
                  const SizedBox(height: 10),
                  ClipRRect(borderRadius: BorderRadius.circular(100), child: LinearProgressIndicator(value: subs.isEmpty ? 0 : reviewed / subs.length, minHeight: 6, backgroundColor: AppColors.grayLight.withValues(alpha: 0.3), color: AppColors.tealPrimary)),
                  const SizedBox(height: 10),
                  Row(children: [Expanded(child: _StatCard(icon: Icons.hourglass_top_rounded, value: '$pending', label: t('pendingHomeworks'), color: AppColors.warning)), const SizedBox(width: 8), Expanded(child: _StatCard(icon: Icons.check_circle_rounded, value: '$reviewed', label: t('reviewedHomeworks'), color: AppColors.success))]),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MyHomeworksScreen(user: viewed))), icon: const Icon(Icons.assignment_rounded, size: 18), label: Text(t('myHomeworks')))),
                ]),
              );
            },
          ),
        if (!viewed.isAdmin) const SizedBox(height: 24),

        // ═══ Settings (only for own account) ═══
        if (_selectedUid == widget.user.uid) ...[
          Text(t('settings'), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.outlineVariant)),
            child: Column(children: [
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.tealPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.language_rounded, color: AppColors.tealPrimary, size: 22)),
                title: Text(t('language'), style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: PopupMenuButton<String>(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [Text(state.locale.languageCode == 'ar' ? t('arabic') : state.locale.languageCode == 'fr' ? t('french') : t('english'), style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.tealPrimary)), const Icon(Icons.arrow_drop_down_rounded)]),
                  onSelected: (code) => context.read<AppState>().setLanguage(code),
                  itemBuilder: (_) => [PopupMenuItem(value: 'ar', child: Text(t('arabic'))), PopupMenuItem(value: 'en', child: Text(t('english'))), PopupMenuItem(value: 'fr', child: Text(t('french')))],
                ),
              ),
              Divider(height: 1, indent: 16, endIndent: 16, color: theme.colorScheme.outlineVariant),
              SwitchListTile(
                secondary: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.peachStart.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(state.themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: AppColors.peachStart, size: 22)),
                title: Text(state.themeMode == ThemeMode.dark ? t('darkMode') : t('lightMode'), style: const TextStyle(fontWeight: FontWeight.w600)),
                value: state.themeMode == ThemeMode.dark,
                onChanged: (_) => context.read<AppState>().toggleTheme(),
              ),
              Divider(height: 1, indent: 16, endIndent: 16, color: theme.colorScheme.outlineVariant),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 22)),
                title: Text(t('logout'), style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
                onTap: () async => await context.read<AuthService>().logout(),
              ),
            ]),
          ),
          const SizedBox(height: 24),
        ],

        Center(child: Text('© ${DateTime.now().year} ${t('appName')}', style: TextStyle(color: AppColors.grayLight, fontSize: 13))),
      ],
    );
  }

  Future<void> _editUserDialog(AppUser target) async {
    final db = context.read<DatabaseService>();
    final nameCtrl = TextEditingController(text: target.name);
    String role = target.role;
    final isSelf = target.uid == widget.user.uid;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تعديل ${target.name}'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'الاسم')),
          if (!isSelf) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: role,
              decoration: const InputDecoration(labelText: 'الدور'),
              items: const [DropdownMenuItem(value: 'student', child: Text('طالب')), DropdownMenuItem(value: 'admin', child: Text('أدمن'))],
              onChanged: (v) => role = v ?? role,
            ),
          ],
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حفظ'))],
      ),
    );
    if (ok == true) {
      if (nameCtrl.text.trim().isNotEmpty && nameCtrl.text.trim() != target.name) {
        await db.updateUserName(target.uid, nameCtrl.text.trim());
      }
      if (!isSelf && role != target.role) {
        await db.setUserRole(target.uid, role);
      }
      final updated = await db.getUser(target.uid);
      if (updated != null && mounted) setState(() => _viewedUser = updated);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم التحديث')));
    }
  }

  Future<void> _manageCoursesDialog(AppUser target) async {
    final db = context.read<DatabaseService>();
    final courses = await db.coursesStream().first;
    final selected = Set<String>.from(target.accessCourses);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) => AlertDialog(
            title: Text('دورات ${target.name}'),
            content: SizedBox(
              width: 400,
              height: 350,
              child: ListView(
                children: courses.map((c) => CheckboxListTile(
                      title: Text(c.title.getWithFallback('ar')),
                      subtitle: Text(c.track),
                      value: selected.contains(c.id),
                      onChanged: (v) => setSt(() => v == true ? selected.add(c.id) : selected.remove(c.id)),
                    )).toList(),
              ),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حفظ'))],
          )),
    );
    if (ok == true) {
      for (final c in courses) {
        final has = selected.contains(c.id);
        final had = target.accessCourses.contains(c.id);
        if (has != had) await db.toggleUserCourseAccess(target.uid, c.id, has);
      }
      final updated = await db.getUser(target.uid);
      if (updated != null && mounted) setState(() => _viewedUser = updated);
    }
  }

  void _previewAsUser(AppUser target) {
    // عرض مبسط: يفتح HomeScreen كأنك هذا المستخدم (للاطلاع فقط)
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('معاينة حساب ${target.name}'),
        content: Text('سترى دوراته ونقاطه كما يراها هو. هذه معاينة فقط وليست تسجيل دخول فعلي.'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق'))],
      ),
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
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
        const SizedBox(height: 10),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.grayMedium)),
      ]),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.sub, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.15))),
      child: Column(children: [Text(label, style: TextStyle(fontSize: 11, color: AppColors.grayMedium, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(value, style: TextStyle(fontWeight: FontWeight.w900, color: color)), Text(sub, style: TextStyle(fontSize: 11, color: AppColors.grayMedium))]),
    );
  }
}
