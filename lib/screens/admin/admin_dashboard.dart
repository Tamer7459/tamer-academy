import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../core/breakpoints.dart';
import '../../models/app_user.dart';
import '../../models/course.dart';
import '../../models/exercise_submission.dart';
import '../../models/homework_submission.dart';
import '../../models/track.dart';
import '../../services/database_service.dart';
import 'course_edit_screen.dart';
import 'exercise_submissions_screen.dart';
import 'homework_submissions_screen.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2))),
            ),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.dashboard_rounded, size: 22, color: AppColors.warning)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t('admin'), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: isDark ? Colors.white : AppColors.navyText)),
                Text(l10n.isRtl ? 'لوحة تحكم شاملة — كل شيء في صفحة واحدة' : 'Full-screen dashboard — all in one page', style: TextStyle(fontSize: 12, color: AppColors.grayMedium)),
              ]),
              const Spacer(),
              FilledButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CourseEditScreen())), icon: const Icon(Icons.add_rounded, size: 18), label: Text(t('addCourse'))),
            ]),
          ),
        ),
        SliverPadding(padding: const EdgeInsets.all(16), sliver: SliverToBoxAdapter(child: _StatsGrid(db: db))),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: LayoutBuilder(builder: (context, c) {
              final wide = c.maxWidth >= Breakpoints.medium;
              final hw = _PendingHomeworkPreview();
              final ex = _PendingExercisePreview();
              if (wide) return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: hw), const SizedBox(width: 16), Expanded(child: ex)]);
              return Column(children: [hw, const SizedBox(height: 16), ex]);
            }),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 16), sliver: SliverToBoxAdapter(child: _RequestsPreview())),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 16), sliver: SliverToBoxAdapter(child: _UsersPreview(user: user))),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 16), sliver: SliverToBoxAdapter(child: _CoursesPreview(user: user))),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 16), sliver: SliverToBoxAdapter(child: _TracksPreview(user: user))),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final DatabaseService db;
  const _StatsGrid({required this.db});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final count = c.maxWidth > 700 ? 3 : 2;
      return GridView.count(
        crossAxisCount: count,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.6,
        children: [
          _StatStreamCard(icon: Icons.menu_book_rounded, color: AppColors.tealPrimary, label: 'الكورسات', stream: db.coursesStream().map((l) => l.length)),
          _StatStreamCard(icon: Icons.category_rounded, color: AppColors.goldPrimary, label: 'المسارات', stream: db.tracksStream().map((l) => l.length)),
          _StatStreamCard(icon: Icons.group_rounded, color: AppColors.navyText, label: 'المستخدمون', stream: db.allUsersStream().map((l) => l.length)),
          _StatStreamCard(icon: Icons.assignment_rounded, color: AppColors.warning, label: 'واجبات معلقة', stream: db.homeworkSubmissionsStream(status: 'pending').map((l) => l.length)),
          _StatStreamCard(icon: Icons.edit_note_rounded, color: AppColors.success, label: 'تمارين معلقة', stream: db.exerciseSubmissionsStream(status: 'pending').map((l) => l.length)),
          _StatStreamCard(icon: Icons.mark_email_read_rounded, color: AppColors.danger, label: 'طلبات معلقة', stream: db.accessRequestsStream().map((l) => l.where((r) => r.status == 'pending').length)),
        ],
      );
    });
  }
}

class _StatStreamCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final Stream<int> stream;
  const _StatStreamCard({required this.icon, required this.color, required this.label, required this.stream});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snap) {
        final count = snap.data ?? 0;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3))),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: color)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$count', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)), Text(label, style: TextStyle(fontSize: 11, color: AppColors.grayMedium, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)])),
          ]),
        );
      },
    );
  }
}

class _PendingHomeworkPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.all(14), child: Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.assignment_rounded, size: 16, color: AppColors.warning)), const SizedBox(width: 8), const Text('واجبات بانتظار التصحيح', style: TextStyle(fontWeight: FontWeight.w800)), const Spacer(), TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HomeworkSubmissionsScreen())), child: const Text('عرض الكل'))])),
        const Divider(height: 1),
        StreamBuilder<List<HomeworkSubmission>>(
          stream: db.homeworkSubmissionsStream(status: 'pending'),
          builder: (context, snap) {
            final list = (snap.data ?? []).take(5).toList();
            if (snap.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
            if (list.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Text('لا توجد واجبات معلقة', style: TextStyle(color: AppColors.grayMedium)));
            return ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(12), itemCount: list.length, separatorBuilder: (_, _) => const Divider(height: 1), itemBuilder: (context, i) {
              final s = list[i];
              return ListTile(dense: true, title: Text(s.lessonTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), subtitle: Text('${s.userName} • ${s.courseTitle}', style: TextStyle(fontSize: 11, color: AppColors.grayMedium)), trailing: Text('${s.createdAt.day}/${s.createdAt.month}', style: TextStyle(fontSize: 11, color: AppColors.grayLight)));
            });
          },
        ),
      ]),
    );
  }
}

class _PendingExercisePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.all(14), child: Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.edit_note_rounded, size: 16, color: AppColors.success)), const SizedBox(width: 8), const Text('تمارين بانتظار التصحيح', style: TextStyle(fontWeight: FontWeight.w800)), const Spacer(), TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExerciseSubmissionsScreen())), child: const Text('عرض الكل'))])),
        const Divider(height: 1),
        StreamBuilder<List<ExerciseSubmission>>(
          stream: db.exerciseSubmissionsStream(status: 'pending'),
          builder: (context, snap) {
            final list = (snap.data ?? []).take(5).toList();
            if (snap.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
            if (list.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Text('لا توجد تمارين معلقة', style: TextStyle(color: AppColors.grayMedium)));
            return ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(12), itemCount: list.length, separatorBuilder: (_, _) => const Divider(height: 1), itemBuilder: (context, i) {
              final s = list[i];
              return ListTile(dense: true, title: Text(s.lessonTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), subtitle: Text('${s.userName} • ${s.courseTitle}', style: TextStyle(fontSize: 11, color: AppColors.grayMedium)), trailing: Text('${s.createdAt.day}/${s.createdAt.month}', style: TextStyle(fontSize: 11, color: AppColors.grayLight)));
            });
          },
        ),
      ]),
    );
  }
}

class _RequestsPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.all(14), child: Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.mark_email_read_rounded, size: 16, color: AppColors.danger)), const SizedBox(width: 8), const Text('طلبات الوصول', style: TextStyle(fontWeight: FontWeight.w800)), const Spacer(), TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RequestsScreen())), child: const Text('إدارة'))])),
        const Divider(height: 1),
        StreamBuilder(stream: db.accessRequestsStream(), builder: (context, snap) {
          final list = (snap.data ?? []).where((r) => r.status == 'pending').take(5).toList();
          if (snap.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
          if (list.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Text('لا توجد طلبات معلقة', style: TextStyle(color: AppColors.grayMedium)));
          return ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(12), itemCount: list.length, separatorBuilder: (_, _) => const Divider(height: 1), itemBuilder: (context, i) {
            final r = list[i];
            return ListTile(dense: true, title: Text(r.userName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), subtitle: Text(r.courseTitle, style: TextStyle(fontSize: 11, color: AppColors.grayMedium)), trailing: const Icon(Icons.hourglass_top_rounded, size: 16, color: AppColors.warning));
          });
        }),
      ]),
    );
  }
}

class _UsersPreview extends StatelessWidget {
  final AppUser user;
  const _UsersPreview({required this.user});
  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.all(14), child: Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.navyText.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.group_rounded, size: 16, color: AppColors.navyText)), const SizedBox(width: 8), const Text('المستخدمون', style: TextStyle(fontWeight: FontWeight.w800)), const Spacer(), TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => UsersScreen(user: user))), child: const Text('إدارة'))])),
        const Divider(height: 1),
        StreamBuilder(stream: db.allUsersStream(), builder: (context, snap) {
          final list = (snap.data ?? []).take(5).toList();
          if (snap.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
          if (list.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Text('لا يوجد مستخدمون', style: TextStyle(color: AppColors.grayMedium)));
          return ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(12), itemCount: list.length, separatorBuilder: (_, _) => const Divider(height: 1), itemBuilder: (context, i) {
            final u = list[i];
            return ListTile(dense: true, leading: CircleAvatar(radius: 14, child: Text(u.name.isEmpty ? '?' : u.name[0].toUpperCase(), style: const TextStyle(fontSize: 12))), title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), subtitle: Text(u.email, style: TextStyle(fontSize: 11, color: AppColors.grayMedium)), trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: (u.isAdmin ? AppColors.warning : AppColors.tealPrimary).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(100)), child: Text(u.isAdmin ? 'أدمن' : 'طالب', style: TextStyle(fontSize: 10, color: u.isAdmin ? AppColors.warning : AppColors.tealPrimary, fontWeight: FontWeight.w700))));
          });
        }),
      ]),
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
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.all(14), child: Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.tealPrimary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.menu_book_rounded, size: 16, color: AppColors.tealPrimary)), const SizedBox(width: 8), const Text('الكورسات', style: TextStyle(fontWeight: FontWeight.w800)), const Spacer(), FilledButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CourseEditScreen())), icon: const Icon(Icons.add_rounded, size: 16), label: const Text('إضافة'))])),
        const Divider(height: 1),
        StreamBuilder<List<Course>>(
          stream: db.coursesStream(),
          builder: (context, snap) {
            final courses = snap.data ?? [];
            if (courses.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Text('لا توجد كورسات'));
            return ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(12), itemCount: courses.length > 5 ? 5 : courses.length, separatorBuilder: (_, _) => const SizedBox(height: 8), itemBuilder: (context, i) {
              final c = courses[i];
              return ListTile(dense: true, title: Text(c.title.getWithFallback(Localizations.of<AppLocalizations>(context, AppLocalizations)!.languageCode), style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(c.track), trailing: IconButton(icon: const Icon(Icons.edit_rounded, size: 18), onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CourseEditScreen(course: c)))));
            });
          },
        ),
      ]),
    );
  }
}

class _TracksPreview extends StatelessWidget {
  final AppUser user;
  const _TracksPreview({required this.user});
  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.all(14), child: Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.goldPrimary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.category_rounded, size: 16, color: AppColors.goldPrimary)), const SizedBox(width: 8), const Text('المسارات', style: TextStyle(fontWeight: FontWeight.w800)), const Spacer(), FilledButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TrackEditScreen())), icon: const Icon(Icons.add_rounded, size: 16), label: const Text('إضافة'))])),
        const Divider(height: 1),
        StreamBuilder<List<Track>>(
          stream: db.tracksStream(),
          builder: (context, snap) {
            final tracks = snap.data ?? [];
            if (tracks.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Text('لا توجد مسارات'));
            return ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(12), itemCount: tracks.length > 5 ? 5 : tracks.length, separatorBuilder: (_, _) => const SizedBox(height: 8), itemBuilder: (context, i) {
              final tr = tracks[i];
              return ListTile(dense: true, title: Text(tr.name.getWithFallback(Localizations.of<AppLocalizations>(context, AppLocalizations)!.languageCode), style: const TextStyle(fontWeight: FontWeight.w700)), trailing: IconButton(icon: const Icon(Icons.edit_rounded, size: 18), onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TrackEditScreen(track: tr)))));
            });
          },
        ),
      ]),
    );
  }
}
