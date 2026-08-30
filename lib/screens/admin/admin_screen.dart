import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../models/app_user.dart';
import '../../models/course.dart';
import '../../models/track.dart';
import '../../services/database_service.dart';
import '../../widgets/animated_widgets.dart';
import 'course_edit_screen.dart';
import 'exercise_submissions_screen.dart';
import 'homework_submissions_screen.dart';
import 'lessons_manage_screen.dart';
import 'requests_screen.dart';
import 'track_edit_screen.dart';
import 'users_screen.dart';

class AdminScreen extends StatefulWidget {
  final AppUser user;
  const AdminScreen({super.key, required this.user});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _section = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3))),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.admin_panel_settings_rounded, size: 20, color: AppColors.warning),
              ),
              const SizedBox(width: 10),
              Text(
                t('admin'),
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isDark ? Colors.white : AppColors.navyText),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(
                  value: 0,
                  icon: const Icon(Icons.menu_book_rounded, size: 18),
                  label: Text(t('manageCourses')),
                ),
                ButtonSegment(
                  value: 1,
                  icon: const Icon(Icons.category_rounded, size: 18),
                  label: Text(t('tracks')),
                ),
                ButtonSegment(
                  value: 2,
                  icon: const Icon(Icons.group_rounded, size: 18),
                  label: Text(t('manageUsers')),
                ),
                ButtonSegment(
                  value: 3,
                  icon: const Icon(Icons.mark_email_read_rounded, size: 18),
                  label: Text(t('manageRequests')),
                ),
                ButtonSegment(
                  value: 4,
                  icon: const Icon(Icons.assignment_rounded, size: 18),
                  label: Text(t('homeworkSubmissions')),
                ),
                ButtonSegment(
                  value: 5,
                  icon: const Icon(Icons.edit_note_rounded, size: 18),
                  label: const Text('التمارين'),
                ),
              ],
              selected: {_section},
              onSelectionChanged: (s) => setState(() => _section = s.first),
              showSelectedIcon: false,
            ),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _section,
            children: [
              _CoursesSection(user: widget.user),
              _TracksSection(user: widget.user),
              UsersScreen(user: widget.user),
              const RequestsScreen(),
              const HomeworkSubmissionsScreen(),
              const ExerciseSubmissionsScreen(),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoursesSection extends StatefulWidget {
  final AppUser user;
  const _CoursesSection({required this.user});

  @override
  State<_CoursesSection> createState() => _CoursesSectionState();
}

class _CoursesSectionState extends State<_CoursesSection> {
  String? _trackFilter;

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final db = context.watch<DatabaseService>();

    return StreamBuilder<List<Course>>(
      stream: db.coursesStream(),
      builder: (context, snapshot) {
        var courses = snapshot.data ?? [];
        if (_trackFilter != null) {
          courses = courses.where((c) => c.track == _trackFilter).toList();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: StreamBuilder<List<Track>>(
                      stream: db.tracksStream(),
                      builder: (context, trackSnap) {
                        final tracks = trackSnap.data ?? [];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.colorScheme.outlineVariant),
                          ),
                          child: DropdownButton<String?>(
                            value: _trackFilter,
                            isExpanded: true,
                            underline: const SizedBox(),
                            hint: Text(t('allLevels')),
                            items: [
                              DropdownMenuItem(value: null, child: Text(t('allLevels'))),
                              ...tracks.map((tr) => DropdownMenuItem(
                                    value: tr.id,
                                    child: Text(tr.name.get(l10n.languageCode)),
                                  )),
                            ],
                            onChanged: (v) => setState(() => _trackFilter = v),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CourseEditScreen()),
                      );
                    },
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: Text(t('addCourse'), style: const TextStyle(fontWeight: FontWeight.w800)),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : courses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.tealPrimary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(Icons.menu_book_rounded, size: 48, color: AppColors.tealPrimary.withValues(alpha: 0.4)),
                              ),
                              const SizedBox(height: 16),
                              Text(t('noCourses'), style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.grayMedium)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: courses.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final course = courses[i];
                            final lang = l10n.languageCode;
                            const palette = [0xFF1A8A7A, 0xFF3BBFAE, 0xFFF5A623, 0xFF3B82F6, 0xFF8B5CF6, 0xFFEF4444];
                            final base = AppTheme.track(context, course.track);
                            final trackColor = (course.colorSeed >= 0 && course.colorSeed < palette.length) ? Color(palette[course.colorSeed]) : base;
                            return Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    if (course.imageUrl.isNotEmpty)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: course.imageUrl.startsWith('data:')
                                            ? Image.memory(
                                                base64Decode(course.imageUrl.split(',').last),
                                                width: 44,
                                                height: 44,
                                                fit: course.boxFit,
                                              )
                                            : Image.network(
                                                course.imageUrl,
                                                width: 44,
                                                height: 44,
                                                fit: course.boxFit,
                                                errorBuilder: (_, __, ___) => Container(
                                                  width: 44,
                                                  height: 44,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(colors: [trackColor, trackColor.withValues(alpha: 0.7)]),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Icon(course.track == 'web' ? Icons.language_rounded : Icons.smartphone_rounded, color: Colors.white, size: 22),
                                                ),
                                              ),
                                      )
                                    else
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [trackColor, trackColor.withValues(alpha: 0.7)],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(color: trackColor.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2)),
                                          ],
                                        ),
                                        child: Icon(
                                          course.track == 'web' ? Icons.language_rounded : Icons.smartphone_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            course.title.getWithFallback(lang),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: isDark ? Colors.white : AppColors.navyText),
                                          ),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: [
                                              _ChipBadge(
                                                text: course.isFree ? t('free') : '${course.price}\$',
                                                color: course.isFree ? AppColors.success : AppColors.warning,
                                              ),
                                              _ChipBadge(text: t(course.level), color: AppColors.tealPrimary),
                                              if (!course.published) _ChipBadge(text: t('locked'), color: AppColors.danger),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _ActionBtn(
                                          icon: Icons.edit_rounded,
                                          tooltip: t('editCourse'),
                                          color: AppColors.tealPrimary,
                                          onTap: () async {
                                            await Navigator.of(context).push(
                                              MaterialPageRoute(builder: (_) => CourseEditScreen(course: course)),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 4),
                                        _ActionBtn(
                                          icon: Icons.playlist_play_rounded,
                                          tooltip: t('manageLessons'),
                                          color: AppColors.goldPrimary,
                                          onTap: () => Navigator.of(context).push(
                                            MaterialPageRoute(builder: (_) => LessonsManageScreen(user: widget.user, course: course)),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        _ActionBtn(
                                          icon: Icons.delete_rounded,
                                          tooltip: t('delete'),
                                          color: AppColors.danger,
                                          onTap: () => _confirmDelete(context, course),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Course course) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
        title: Text(t('deleteConfirm')),
        content: Text('${t('deleteWarning')}\n\n${course.title.en}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(t('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              await context.read<DatabaseService>().deleteCourse(course.id);
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t('deleted')), behavior: SnackBarBehavior.floating),
                );
              }
            },
            child: Text(t('delete')),
          ),
        ],
      ),
    );
  }
}

class _ChipBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _ChipBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({required this.icon, required this.tooltip, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// TRACKS SECTION
// ══════════════════════════════════════════════
class _TracksSection extends StatelessWidget {
  final AppUser user;
  const _TracksSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final db = context.watch<DatabaseService>();
    final lang = l10n.languageCode;

    return StreamBuilder<List<Track>>(
      stream: db.tracksStream(),
      builder: (context, snapshot) {
        final tracks = snapshot.data ?? [];

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${t('tracks')} (${tracks.length})',
                      style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.navyText),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TrackEditScreen()),
                      );
                    },
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: Text(t('addTrack'), style: const TextStyle(fontWeight: FontWeight.w800)),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : tracks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.tealPrimary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(Icons.category_rounded, size: 48, color: AppColors.tealPrimary.withValues(alpha: 0.4)),
                              ),
                              const SizedBox(height: 16),
                              Text(t('noTracks'), style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.grayMedium)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: tracks.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final track = tracks[i];
                            final trackColor = Color(track.color);
                            return Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    // Track image or icon
                                    if (track.imageUrl.isNotEmpty)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: track.imageUrl.startsWith('data:')
                                            ? Image.memory(
                                                base64Decode(track.imageUrl.split(',').last),
                                                width: 44,
                                                height: 44,
                                                fit: track.boxFit,
                                              )
                                            : Image.network(
                                                track.imageUrl,
                                                width: 44,
                                                height: 44,
                                                fit: track.boxFit,
                                              ),
                                      )
                                    else
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [trackColor, trackColor.withValues(alpha: 0.7)],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(color: trackColor.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2)),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.category_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                    const SizedBox(width: 12),
                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            track.name.getWithFallback(lang),
                                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: isDark ? Colors.white : AppColors.navyText),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              _ChipBadge(
                                                text: track.published ? t('published') : t('draft'),
                                                color: track.published ? AppColors.success : AppColors.warning,
                                              ),
                                              const SizedBox(width: 6),
                                              _ChipBadge(
                                                text: '${t('order')}: ${track.order}',
                                                color: AppColors.tealPrimary,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Actions
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _ActionBtn(
                                          icon: Icons.edit_rounded,
                                          tooltip: t('editTrack'),
                                          color: AppColors.tealPrimary,
                                          onTap: () async {
                                            await Navigator.of(context).push(
                                              MaterialPageRoute(builder: (_) => TrackEditScreen(track: track)),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 4),
                                        _ActionBtn(
                                          icon: Icons.delete_rounded,
                                          tooltip: t('delete'),
                                          color: AppColors.danger,
                                          onTap: () => _confirmDeleteTrack(context, track),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteTrack(BuildContext context, Track track) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
        title: Text(t('deleteConfirm')),
        content: Text('${t('deleteWarning')}\n\n${track.name.en}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(t('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              await context.read<DatabaseService>().deleteTrack(track.id);
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t('deleted')), behavior: SnackBarBehavior.floating),
                );
              }
            },
            child: Text(t('delete')),
          ),
        ],
      ),
    );
  }
}

