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

  static const EdgeInsets _pagePadding = EdgeInsets.symmetric(horizontal: 20, vertical: 24);

  @override
  void initState() {
    super.initState();
    _viewedUser = widget.user;
    _selectedUid = widget.user.uid;
  }

  double _sumGrades(List<double?> grades) => grades.whereType<double>().fold(0, (a, b) => a + b);

  String _num(double v) => v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 1).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = context.watch<AppState>();
    final db = context.watch<DatabaseService>();
    final isAdmin = widget.user.isAdmin;
    final viewed = _viewedUser ?? widget.user;
    final isSelf = _selectedUid == widget.user.uid;

    return ColoredBox(
      color: isDark ? const Color(0xFF0B0B0D) : const Color(0xFFF4F1EA),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: ListView(
            padding: _pagePadding,
          children: [
            // ═══ Admin: اختيار أي حساب ═══
            if (isAdmin) ...[
              _Card(
                tint: AppColors.warning,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(Icons.manage_accounts_rounded, color: AppColors.goldPrimary, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text('عرض حساب آخر', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white, decoration: TextDecoration.none)),
                    const Spacer(),
                    if (!isSelf)
                      TextButton(
                        onPressed: () => setState(() { _viewedUser = widget.user; _selectedUid = widget.user.uid; }),
                        style: TextButton.styleFrom(foregroundColor: AppColors.goldPrimary),
                        child: const Text('العودة لحسابي'),
                      ),
                  ]),
                  const SizedBox(height: 12),
                  StreamBuilder<List<AppUser>>(
                    stream: db.allUsersStream(),
                    builder: (context, snap) {
                      final users = snap.data ?? [];
                      if (users.isEmpty) return const LinearProgressIndicator(minHeight: 2);
                      return DropdownButtonFormField<String>(
                        value: _selectedUid,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'اختر حساباً',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2D2C2E))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2D2C2E))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.goldPrimary, width: 1.5)),
                          filled: true,
                          fillColor: const Color(0xFF141416),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        items: users.map((u) => DropdownMenuItem(value: u.uid, child: Text('${u.name} — ${u.email} ${u.isAdmin ? "(أدمن)" : ""}', style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (uid) {
                          if (uid == null) return;
                          final found = users.firstWhere((x) => x.uid == uid, orElse: () => widget.user);
                          setState(() { _selectedUid = uid; _viewedUser = found; });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editUserDialog(viewed),
                        icon: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFFE5384A)),
                        label: const Text('تعديل هذا الحساب', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFE5384A))),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF17171A),
                          side: const BorderSide(color: Color(0xFF2D2C2E)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _previewAsUser(viewed),
                        icon: const Icon(Icons.visibility_rounded, size: 16, color: Colors.white),
                        label: const Text('الدخول كطالب', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFC1232C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                  ]),
                ]),
              ),
              const SizedBox(height: 14),
            ],

            // ═══ Profile Header ═══
            _Card(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFC1232C), width: 2.5),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFF17171A),
                      backgroundImage: viewed.photoUrl.isNotEmpty ? NetworkImage(viewed.photoUrl) : null,
                      child: viewed.photoUrl.isEmpty
                          ? Text(
                              viewed.name.trim().isEmpty ? '?' : viewed.name.trim()[0].toUpperCase(),
                              style: const TextStyle(color: Color(0xFFC1232C), fontSize: 26, fontWeight: FontWeight.w900),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        viewed.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, decoration: TextDecoration.none),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        viewed.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFF8A8578), fontSize: 13, decoration: TextDecoration.none),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: (viewed.isAdmin ? AppColors.goldPrimary : const Color(0xFFC1232C)).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: (viewed.isAdmin ? AppColors.goldPrimary : const Color(0xFFC1232C)).withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(
                            viewed.isAdmin ? Icons.military_tech_rounded : Icons.school_rounded,
                            size: 13,
                            color: viewed.isAdmin ? AppColors.goldPrimary : const Color(0xFFC1232C),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            viewed.isAdmin ? t('adminRole') : t('student'),
                            style: TextStyle(
                              color: viewed.isAdmin ? AppColors.goldPrimary : const Color(0xFFC1232C),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ]),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ═══ التقدم (مكتمل / تمارين محلولة) ═══
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
                return Row(
                  children: [
                    // Card 1 (Right in RTL): Completed (مكتمل)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF17171A),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF2D2C2E)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC1232C).withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFFC1232C)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '$totalCompleted',
                              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFFC1232C), decoration: TextDecoration.none),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t('completed'),
                              style: const TextStyle(fontSize: 12.5, color: Color(0xFF8A8578), fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Card 2 (Left in RTL): Solved Exercises (تمارين محلولة)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF17171A),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF2D2C2E)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.goldPrimary.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.quiz_rounded, size: 16, color: AppColors.goldPrimary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '$totalAnswered',
                              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.goldPrimary, decoration: TextDecoration.none),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t('exercisesSolved'),
                              style: const TextStyle(fontSize: 12.5, color: Color(0xFF8A8578), fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),

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
                    final avg = count == 0 ? null : total / count;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 20, color: AppColors.goldPrimary),
                            const SizedBox(width: 8),
                            const Text('مجموع النقاط', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: Colors.white, decoration: TextDecoration.none)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.goldPrimary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.45)),
                              ),
                              child: Text('${_num(total)} نقطة', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.goldPrimary, fontSize: 12, decoration: TextDecoration.none)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(child: _ScoreTile(label: 'واجبات مصححة', value: '${hwReviewed.length}', sub: '${_num(totalHw)} ن', color: const Color(0xFFC1232C), bgTint: const Color(0xFF201618))),
                          const SizedBox(width: 8),
                          Expanded(child: _ScoreTile(label: 'تمارين مصححة', value: '${exReviewed.length}', sub: '${_num(totalEx)} ن', color: const Color(0xFF2BB673), bgTint: const Color(0xFF14221D))),
                          const SizedBox(width: 8),
                          Expanded(child: _ScoreTile(label: 'المعدل', value: avg == null ? '-' : _num(avg), sub: '$count تقييم', color: AppColors.goldPrimary, bgTint: const Color(0xFF221E15))),
                        ]),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 14),

            // ═══ الدورات التي لديه ═══
            StreamBuilder<List<Course>>(
              stream: db.coursesStream(),
              builder: (context, snap) {
                final all = snap.data ?? [];
                final myCourses = all.where((c) => viewed.accessCourses.contains(c.id)).toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.menu_book_rounded, size: 18, color: Color(0xFFC1232C)),
                        const SizedBox(width: 8),
                        Text(
                          'الدورات (${myCourses.length})',
                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Colors.white, decoration: TextDecoration.none),
                        ),
                        const Spacer(),
                        if (isAdmin)
                          TextButton(
                            onPressed: () => _manageCoursesDialog(viewed),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFC1232C),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              minimumSize: const Size(0, 32),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('إدارة', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _Card(
                      padding: const EdgeInsets.all(16),
                      child: myCourses.isEmpty
                          ? SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text('لا يملك أي دورة', style: const TextStyle(color: Color(0xFF8A8578), fontSize: 13, decoration: TextDecoration.none)),
                              ),
                            )
                          : Column(
                              children: myCourses.map((c) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(border: Border.all(color: const Color(0xFF2D2C2E)), borderRadius: BorderRadius.circular(10)),
                                      child: Row(children: [
                                        Container(width: 34, height: 34, decoration: BoxDecoration(color: const Color(0xFFC1232C).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(c.track == 'web' ? Icons.language_rounded : Icons.smartphone_rounded, size: 17, color: const Color(0xFFC1232C))),
                                        const SizedBox(width: 10),
                                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          Text(c.title.getWithFallback(l10n.languageCode), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white)),
                                          Text(c.track, style: const TextStyle(fontSize: 11, color: Color(0xFF8A8578))),
                                        ])),
                                        if (c.isFree)
                                          Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(100)), child: const Text('مجاني', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w700))),
                                      ]),
                                    ),
                                  )).toList(),
                            ),
                    ),
                  ],
                );
              },
            ),

            // ═══ واجباتي ═══
            if (!viewed.isAdmin) ...[
              const SizedBox(height: 14),
              StreamBuilder<List<HomeworkSubmission>>(
                stream: db.userHomeworkStream(viewed.uid),
                builder: (context, snap) {
                  final subs = snap.data ?? [];
                  final pending = subs.where((s) => s.isPending).length;
                  final reviewed = subs.where((s) => s.isReviewed).length;
                  return _Section(
                    title: t('myHomeworks'),
                    icon: Icons.assignment_rounded,
                    iconColor: AppColors.tealPrimary,
                    trailing: Text('$reviewed/${subs.length}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.tealPrimary, fontSize: 12)),
                    child: Column(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: subs.isEmpty ? 0 : reviewed / subs.length,
                          minHeight: 6,
                          backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                          color: AppColors.tealPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: _ScoreTile(label: t('pendingHomeworks'), value: '$pending', sub: '', color: AppColors.warning)),
                        const SizedBox(width: 8),
                        Expanded(child: _ScoreTile(label: t('reviewedHomeworks'), value: '$reviewed', sub: '', color: AppColors.success)),
                      ]),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MyHomeworksScreen(user: viewed))),
                          icon: const Icon(Icons.arrow_outward_rounded, size: 16),
                          label: Text(t('myHomeworks'), style: const TextStyle(fontSize: 13)),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                        ),
                      ),
                    ]),
                  );
                },
              ),
            ],

            // ═══ الإعدادات ═══
            if (isSelf) ...[
              const SizedBox(height: 24),
              Text(
                t('settings'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, decoration: TextDecoration.none),
              ),
              const SizedBox(height: 12),
              _Card(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    // Language item
                    PopupMenuButton<String>(
                      tooltip: t('language'),
                      onSelected: (code) => context.read<AppState>().setLanguage(code),
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'ar', child: Text(t('arabic'))),
                        PopupMenuItem(value: 'en', child: Text(t('english'))),
                        PopupMenuItem(value: 'fr', child: Text(t('french'))),
                      ],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            _IconBadge(icon: Icons.language_rounded, color: const Color(0xFFC1232C)),
                            const SizedBox(width: 12),
                            Text(
                              t('language'),
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white, decoration: TextDecoration.none),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.arrow_drop_down_rounded, size: 20, color: Color(0xFF8A8578)),
                                const SizedBox(width: 4),
                                Text(
                                  state.locale.languageCode == 'ar'
                                      ? t('arabic')
                                      : state.locale.languageCode == 'fr'
                                          ? t('french')
                                          : t('english'),
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFE5384A), fontSize: 13, decoration: TextDecoration.none),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFF252426)),
                    // Dark Mode item
                    InkWell(
                      onTap: () => context.read<AppState>().toggleTheme(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            _IconBadge(icon: Icons.dark_mode_rounded, color: AppColors.goldPrimary),
                            const SizedBox(width: 12),
                            Text(
                              state.themeMode == ThemeMode.dark ? t('darkMode') : t('lightMode'),
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white, decoration: TextDecoration.none),
                            ),
                            const Spacer(),
                            Switch(
                              value: state.themeMode == ThemeMode.dark,
                              onChanged: (_) => context.read<AppState>().toggleTheme(),
                              activeTrackColor: const Color(0xFFC1232C),
                              activeThumbColor: const Color(0xFF0B0B0D),
                              inactiveThumbColor: const Color(0xFF6B6760),
                              inactiveTrackColor: const Color(0xFF1E1E22),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFF252426)),
                    // Logout item
                    InkWell(
                      onTap: () async => await context.read<AuthService>().logout(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            const Icon(Icons.logout_rounded, color: Color(0xFFE5384A), size: 20),
                            const SizedBox(width: 12),
                            Text(
                              t('logout'),
                              style: const TextStyle(color: Color(0xFFE5384A), fontWeight: FontWeight.w700, fontSize: 14, decoration: TextDecoration.none),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),
            Center(child: Text('© ${DateTime.now().year} ${t('appName')}', style: const TextStyle(color: AppColors.grayLight, fontSize: 12))),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ),
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
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حفظ')),
        ],
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
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
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
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حفظ')),
          ],
        ),
      ),
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

/// ═══ بطاقة قسم: عنوان في الأعلى + محتوى ═══
class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget? trailing;
  final Widget child;

  const _Section({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, decoration: TextDecoration.none),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// ═══ حاوية أساسية ═══
class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? tint;

  const _Card({required this.child, this.padding = const EdgeInsets.all(16), this.tint});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: tint == null
            ? (isDark ? const Color(0xFF17171A) : theme.colorScheme.surface)
            : tint!.withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: tint == null
              ? (isDark ? const Color(0xFF2D2C2E) : theme.colorScheme.outlineVariant)
              : tint!.withValues(alpha: 0.25),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// ═══ بطاقة رقم صغيرة ═══
class _ScoreTile extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  final Color? bgTint;

  const _ScoreTile({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    this.bgTint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: bgTint ?? color.withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8A8578), decoration: TextDecoration.none)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color, decoration: TextDecoration.none)),
          if (sub.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(fontSize: 11, color: Color(0xFF8A8578), decoration: TextDecoration.none)),
          ],
        ],
      ),
    );
  }
}

/// ═══ أيقونة داخل مربع ملوّن ═══
class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _IconBadge({required this.icon, required this.color, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
      child: Icon(icon, color: color, size: size),
    );
  }
}
