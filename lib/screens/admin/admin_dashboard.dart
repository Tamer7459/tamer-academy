import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../core/breakpoints.dart';
import '../../models/app_user.dart';
import '../../models/course.dart';
import '../../models/track.dart';
import '../../services/database_service.dart';
import 'course_edit_screen.dart';
import 'exercise_submissions_screen.dart';
import 'homework_submissions_screen.dart';
import 'lessons_manage_screen.dart';
import 'requests_screen.dart';
import 'track_edit_screen.dart';
import 'users_screen.dart';

class AdminDashboard extends StatelessWidget {
  final AppUser user;
  const AdminDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final db = context.watch<DatabaseService>();

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.0,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFF17171A),
                border: Border(
                  bottom: BorderSide(color: Color(0xFF252426)),
                  left: BorderSide(color: Color(0xFFC1232C), width: 3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.grid_view_rounded,
                      size: 20,
                      color: AppColors.goldPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('admin'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Text(
                        l10n.isRtl
                            ? 'لوحة تحكم شاملة — كل شيء في صفحة واحدة'
                            : 'Full-screen dashboard — all in one page',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8A8578),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CourseEditScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(
                      t('addCourse'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFC1232C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(child: _StatsGrid(db: db)),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: LayoutBuilder(
                builder: (context, c) {
                  final wide = c.maxWidth >= Breakpoints.medium;
                  final hw = _PendingHomeworkPreview();
                  final ex = _PendingExercisePreview();
                  if (wide)
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: hw),
                        const SizedBox(width: 16),
                        Expanded(child: ex),
                      ],
                    );
                  return Column(children: [hw, const SizedBox(height: 16), ex]);
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: _RequestsPreview()),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: _UsersPreview(user: user)),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: _CoursesPreview(user: user)),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: _TracksPreview(user: user)),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final DatabaseService db;
  const _StatsGrid({required this.db});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final count = c.maxWidth >= 900
            ? 6
            : c.maxWidth > 600
            ? 3
            : 2;
        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: c.maxWidth >= 900 ? 2.3 : 2.7,
          children: [
            _StatStreamCard(
              icon: Icons.menu_book_rounded,
              color: const Color(0xFFC1232C),
              label: 'الكورسات',
              stream: db.coursesStream().map((l) => l.length),
            ),
            _StatStreamCard(
              icon: Icons.category_rounded,
              color: AppColors.goldPrimary,
              label: 'المسارات',
              stream: db.tracksStream().map((l) => l.length),
            ),
            _StatStreamCard(
              icon: Icons.group_rounded,
              color: Colors.white70,
              label: 'المستخدمون',
              stream: db.allUsersStream().map((l) => l.length),
            ),
            _StatStreamCard(
              icon: Icons.assignment_rounded,
              color: AppColors.goldPrimary,
              label: 'واجبات معلقة',
              stream: db
                  .homeworkSubmissionsStream(status: 'pending')
                  .map((l) => l.length),
            ),
            _StatStreamCard(
              icon: Icons.edit_note_rounded,
              color: const Color(0xFF2BB673),
              label: 'تمارين معلقة',
              stream: db
                  .exerciseSubmissionsStream(status: 'pending')
                  .map((l) => l.length),
            ),
            _StatStreamCard(
              icon: Icons.mark_email_unread_rounded,
              color: const Color(0xFFFF6A3D),
              label: 'طلبات معلقة',
              stream: db.accessRequestsStream().map(
                (l) => l.where((r) => r.status == 'pending').length,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatStreamCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final Stream<int> stream;
  const _StatStreamCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.stream,
  });
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snap) {
        final count = snap.data ?? 0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF17171A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF252426)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$count',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8A8578),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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

class _PendingHomeworkPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.goldPrimary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.assignment_rounded,
                size: 16,
                color: AppColors.goldPrimary,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'واجبات بانتظار التصحيح',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const HomeworkSubmissionsScreen(),
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE5384A),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'عرض الكل',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF17171A),
            borderRadius: BorderRadius.circular(14),
            border: const Border(
              top: BorderSide(color: Color(0xFF252426)),
              right: BorderSide(color: Color(0xFF252426)),
              bottom: BorderSide(color: Color(0xFF252426)),
              left: BorderSide(color: Color(0xFFC1232C), width: 3),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: const SizedBox(
            height: 480,
            child: HomeworkSubmissionsScreen(),
          ),
        ),
      ],
    );
  }
}

class _PendingExercisePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2BB673).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit_note_rounded,
                size: 16,
                color: Color(0xFF2BB673),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'تمارين بانتظار التصحيح',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ExerciseSubmissionsScreen(),
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE5384A),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'عرض الكل',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF17171A),
            borderRadius: BorderRadius.circular(14),
            border: const Border(
              top: BorderSide(color: Color(0xFF252426)),
              right: BorderSide(color: Color(0xFF252426)),
              bottom: BorderSide(color: Color(0xFF252426)),
              left: BorderSide(color: Color(0xFFC1232C), width: 3),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: const SizedBox(
            height: 480,
            child: ExerciseSubmissionsScreen(),
          ),
        ),
      ],
    );
  }
}

class _RequestsPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF17171A),
        borderRadius: BorderRadius.circular(14),
        border: const Border(
          top: BorderSide(color: Color(0xFF252426)),
          right: BorderSide(color: Color(0xFF252426)),
          bottom: BorderSide(color: Color(0xFF252426)),
          left: BorderSide(color: Color(0xFFC1232C), width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.mark_email_read_rounded,
                    size: 16,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'طلبات الوصول',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RequestsScreen()),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFE5384A),
                  ),
                  child: const Text(
                    'إدارة',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF252426)),
          const SizedBox(height: 250, child: RequestsScreen()),
        ],
      ),
    );
  }
}

class _UsersPreview extends StatelessWidget {
  final AppUser user;
  const _UsersPreview({required this.user});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF17171A),
        borderRadius: BorderRadius.circular(14),
        border: const Border(
          top: BorderSide(color: Color(0xFF252426)),
          right: BorderSide(color: Color(0xFF252426)),
          bottom: BorderSide(color: Color(0xFF252426)),
          left: BorderSide(color: Color(0xFFC1232C), width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.group_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'المستخدمون',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => UsersScreen(user: user)),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFE5384A),
                  ),
                  child: const Text(
                    'إدارة',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF252426)),
          SizedBox(height: 280, child: UsersScreen(user: user)),
        ],
      ),
    );
  }
}

class _CoursesPreview extends StatelessWidget {
  final AppUser user;
  const _CoursesPreview({required this.user});
  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF17171A),
        borderRadius: BorderRadius.circular(14),
        border: const Border(
          top: BorderSide(color: Color(0xFF252426)),
          right: BorderSide(color: Color(0xFF252426)),
          bottom: BorderSide(color: Color(0xFF252426)),
          left: BorderSide(color: Color(0xFFC1232C), width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC1232C).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 16,
                    color: Color(0xFFC1232C),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'الكورسات',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CourseEditScreen()),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text(
                    'إضافة',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFC1232C),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF252426)),
          StreamBuilder<List<Course>>(
            stream: db.coursesStream(),
            builder: (context, snap) {
              final courses = snap.data ?? [];
              if (snap.hasError) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'تعذر تحميل الكورسات',
                    style: TextStyle(
                      color: Color(0xFFE5384A),
                      fontSize: 13,
                      decoration: TextDecoration.none,
                    ),
                  ),
                );
              }
              if (courses.isEmpty)
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'لا توجد كورسات',
                    style: TextStyle(
                      color: Color(0xFF8A8578),
                      fontSize: 13,
                      decoration: TextDecoration.none,
                    ),
                  ),
                );
              return SizedBox(
                height: 280,
                child: ListView.separated(
                  padding: const EdgeInsets.all(10),
                  itemCount: courses.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 4),
                  itemBuilder: (context, i) {
                    final c = courses[i];
                    final loc = Localizations.of<AppLocalizations>(
                      context,
                      AppLocalizations,
                    )!;
                    final lang = loc.languageCode;
                    final tr = loc.t;
                    final priceLabel = c.isFree ? tr('free') : '${c.price}';
                    final trackLabel =
                        (c.track == 'mobile' || c.track == '1787327901334000')
                        ? tr('mobileDevelopment')
                        : (c.track == 'web' || c.track == '1787326651194000')
                        ? tr('webDevelopment')
                        : (c.track == 'ai_automation' ||
                              c.track == '1794165775204000')
                        ? tr('aiAutomation')
                        : c.track;
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      title: Text(
                        c.title.getWithFallback(lang),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _CourseChip(label: trackLabel),
                            _CourseChip(label: tr(c.level)),
                            _CourseChip(label: priceLabel),
                            _CourseChip(
                              label: c.published
                                  ? tr('published')
                                  : tr('draft'),
                              color: c.published
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              c.published
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              size: 18,
                              color: c.published
                                  ? AppColors.success
                                  : AppColors.grayMedium,
                            ),
                            tooltip: c.published
                                ? tr('published')
                                : tr('draft'),
                            onPressed: () => db.saveCourse(
                              c.copyWith(published: !c.published),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.playlist_play_rounded,
                              size: 18,
                            ),
                            tooltip: 'إدارة الدروس',
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    LessonsManageScreen(user: user, course: c),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CourseEditScreen(course: c),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_rounded,
                              size: 18,
                              color: AppColors.danger,
                            ),
                            onPressed: () =>
                                _confirmDeleteCourse(context, db, c),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CourseChip extends StatelessWidget {
  final String label;
  final Color? color;
  const _CourseChip({required this.label, this.color});
  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF8A8578);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c),
      ),
    );
  }
}

class _TracksPreview extends StatelessWidget {
  final AppUser user;
  const _TracksPreview({required this.user});
  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF17171A),
        borderRadius: BorderRadius.circular(14),
        border: const Border(
          top: BorderSide(color: Color(0xFF252426)),
          right: BorderSide(color: Color(0xFF252426)),
          bottom: BorderSide(color: Color(0xFF252426)),
          left: BorderSide(color: Color(0xFFC1232C), width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.category_rounded,
                    size: 16,
                    color: AppColors.goldPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  t('tracks'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TrackEditScreen()),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: Text(
                    t('addTrack'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFC1232C),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF252426)),
          StreamBuilder<List<Track>>(
            stream: db.tracksStream(),
            builder: (context, snap) {
              if (snap.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'تعذر تحميل التخصصات',
                    style: TextStyle(
                      color: AppColors.danger,
                      decoration: TextDecoration.none,
                    ),
                  ),
                );
              }
              final tracks = snap.data ?? [];
              if (tracks.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    t('noTracks'),
                    style: const TextStyle(
                      color: Color(0xFF8A8578),
                      decoration: TextDecoration.none,
                    ),
                  ),
                );
              }
              return SizedBox(
                height: 260,
                child: ListView.separated(
                  padding: const EdgeInsets.all(10),
                  itemCount: tracks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final tr = tracks[i];
                    final color = Color(tr.color);
                    final name = tr.name.getWithFallback(l10n.languageCode);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF2D2C2E)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.category_rounded,
                              size: 18,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.isNotEmpty ? name : tr.id,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tr.published ? t('published') : t('draft'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: tr.published
                                        ? AppColors.success
                                        : AppColors.warning,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            tooltip: t('editTrack'),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TrackEditScreen(track: tr),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_rounded,
                              size: 18,
                              color: AppColors.danger,
                            ),
                            onPressed: () =>
                                _confirmDeleteTrack(context, db, tr),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

Future<void> _confirmDeleteCourse(
  BuildContext context,
  DatabaseService db,
  Course course,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('حذف الكورس'),
      content: Text(
        'هل تريد حذف "${course.title.getWithFallback(Localizations.of<AppLocalizations>(context, AppLocalizations)!.languageCode)}"؟ لا يمكن التراجع.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('إلغاء'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('حذف'),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    await db.deleteCourse(course.id);
    if (context.mounted)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حذف الكورس')));
  }
}

Future<void> _confirmDeleteTrack(
  BuildContext context,
  DatabaseService db,
  Track track,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('حذف المسار'),
      content: Text(
        'هل تريد حذف "${track.name.getWithFallback(Localizations.of<AppLocalizations>(context, AppLocalizations)!.languageCode)}"؟ لا يمكن التراجع.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('إلغاء'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('حذف'),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    await db.deleteTrack(track.id);
    if (context.mounted)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حذف المسار')));
  }
}
