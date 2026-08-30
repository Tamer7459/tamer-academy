import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ai/chat_controller.dart';
import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../features/chat/chat_overlay.dart';
import '../models/app_user.dart';
import '../state/app_state.dart';
import 'admin/admin_screen.dart';
import 'home/home_screen.dart';
import 'homeworks/my_homeworks_screen.dart';
import 'landing/landing_screen.dart';
import 'profile/profile_screen.dart';

const _kPageIndexKey = 'home_shell_page_index';

class HomeShell extends StatefulWidget {
  final AppUser user;
  const HomeShell({super.key, required this.user});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  bool _loaded = false;
  bool _showChat = false;

  @override
  void initState() {
    super.initState();
    _loadIndex();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chat = context.read<ChatController>();
      if (!chat.isInitialized) {
        chat.init(isAdmin: widget.user.isAdmin, userName: widget.user.name);
      }
    });
  }

  Future<void> _loadIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_kPageIndexKey) ?? 1;
    const maxIndex = 4;
    if (mounted) {
      setState(() {
        _index = saved.clamp(0, maxIndex);
        _loaded = true;
      });
    }
  }

  void _goTo(int index) async {
    setState(() => _index = index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPageIndexKey, index);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = widget.user;
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = <Widget>[
      LandingScreen(
        loggedIn: true,
        isAdmin: user.isAdmin,
        onEnter: () => _goTo(1),
      ),
      HomeScreen(user: user),
      HomeScreen(user: user, myCoursesOnly: true),
      if (!user.isAdmin) MyHomeworksScreen(user: user),
      ProfileScreen(user: user),
      if (user.isAdmin) AdminScreen(user: user),
    ];

    if (_index >= pages.length) _index = 0;

    return Scaffold(
      appBar: _index == 0
          ? null
          : AppBar(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.tealPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset('assets/logo.png', width: 22, height: 22, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    t('appName'),
                    style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.navyText),
                  ),
                ],
              ),
              actions: [
                Consumer<AppState>(
                  builder: (context, state, _) => IconButton(
                    tooltip: t('theme'),
                    icon: Icon(state.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                    onPressed: () => context.read<AppState>().toggleTheme(),
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: t('language'),
                  icon: const Icon(Icons.language),
                  onSelected: (code) => context.read<AppState>().setLanguage(code),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'ar', child: Text(t('arabic'))),
                    PopupMenuItem(value: 'en', child: Text(t('english'))),
                    PopupMenuItem(value: 'fr', child: Text(t('french'))),
                  ],
                ),
              ],
            ),
      body: Stack(
        children: [
          IndexedStack(index: _index, children: pages),
          if (_showChat)
            Positioned(
              right: 16,
              bottom: 16,
              child: Stack(
                children: [
                  const AiChatOverlay(),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => setState(() => _showChat = false),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), shape: BoxShape.circle),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: _index == 0
          ? null
          : FloatingActionButton(
              onPressed: () => setState(() => _showChat = !_showChat),
              backgroundColor: _showChat ? AppColors.warning : Colors.white,
              tooltip: _showChat ? 'إغلاق' : 'Tamer AI',
              child: _showChat
                  ? const Icon(Icons.close_rounded, color: Colors.white)
                  : ClipOval(child: Image.asset('assets/ai_robot.jpg', width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.smart_toy_rounded, color: AppColors.tealPrimary))),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.public_outlined),
            selectedIcon: const Icon(Icons.public_rounded),
            label: t('site'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: t('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_border_rounded),
            selectedIcon: const Icon(Icons.bookmark_rounded),
            label: t('myCourses'),
          ),
          if (!user.isAdmin)
            NavigationDestination(
              icon: Badge(
                isLabelVisible: false,
                child: const Icon(Icons.assignment_outlined),
              ),
              selectedIcon: const Icon(Icons.assignment_rounded),
              label: t('myHomeworks'),
            ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: t('profile'),
          ),
          if (user.isAdmin)
            NavigationDestination(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              selectedIcon: const Icon(Icons.admin_panel_settings_rounded),
              label: t('admin'),
            ),
        ],
      ),
    );
  }
}