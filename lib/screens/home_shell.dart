import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../core/design_tokens.dart';
import '../models/app_user.dart';
import '../state/app_state.dart';
import '../services/auth_service.dart';
import '../widgets/notification_bell.dart';
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
  bool _sidebarCollapsed = false;

  @override
  void initState() {
    super.initState();
    _loadIndex();
  }

  Future<void> _loadIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_kPageIndexKey) ?? 1;
    const maxIndex = 5;
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

  bool get _isWide => MediaQuery.sizeOf(context).width >= 900;

  List<Widget> _buildPages(AppUser user) {
    return <Widget>[
      LandingScreen(loggedIn: true, isAdmin: user.isAdmin, onEnter: () => _goTo(1)),
      HomeScreen(user: user),
      HomeScreen(user: user, myCoursesOnly: true),
      if (!user.isAdmin) MyHomeworksScreen(user: user),
      ProfileScreen(user: user),
      if (user.isAdmin) AdminScreen(user: user),
    ];
  }

  List<_NavItem> _buildNavItems(AppUser user, String Function(String) t) {
    final items = <_NavItem>[
      _NavItem(icon: Icons.public_rounded, label: t('site'), command: 'cd site'),
      _NavItem(icon: Icons.home_rounded, label: t('home'), command: 'cd home'),
      _NavItem(icon: Icons.bookmark_rounded, label: t('myCourses'), command: 'ls courses'),
    ];
    if (!user.isAdmin) {
      items.add(_NavItem(icon: Icons.assignment_rounded, label: t('myHomeworks'), command: 'ls homeworks'));
    }
    items.add(_NavItem(icon: Icons.person_rounded, label: t('profile'), command: 'whoami'));
    if (user.isAdmin) {
      items.add(_NavItem(icon: Icons.admin_panel_settings_rounded, label: t('admin'), command: 'sudo admin'));
    }
    return items;
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppUser user, String Function(String) t, bool isDark) {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(gradient: DGradients.crimsonGlow, borderRadius: DTokens.borderRadiusSm),
            child: Image.asset('assets/logo.png', width: 20, height: 20, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Text('Tamer Academy', style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.navyText)),
        ],
      ),
      actions: [
        const NotificationBell(),
        Consumer<AppState>(builder: (context, state, _) => IconButton(tooltip: t('theme'), icon: Icon(state.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode), onPressed: () => context.read<AppState>().toggleTheme())),
        PopupMenuButton<String>(tooltip: t('language'), icon: const Icon(Icons.language), onSelected: (code) => context.read<AppState>().setLanguage(code), itemBuilder: (_) => [PopupMenuItem(value: 'ar', child: Text(t('arabic'))), PopupMenuItem(value: 'en', child: Text(t('english'))), PopupMenuItem(value: 'fr', child: Text(t('french')))]),
      ],
    );
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
    final pages = _buildPages(user);
    final navItems = _buildNavItems(user, t);

    if (_index >= pages.length) _index = 0;

    if (_isWide) {
      return _buildWide(context, user, t, isDark, pages, navItems);
    }
    return _buildMobile(context, user, t, isDark, pages);
  }

  Widget _buildWide(BuildContext context, AppUser user, String Function(String) t, bool isDark, List<Widget> pages, List<_NavItem> navItems) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar
          AnimatedContainer(
            duration: DTokens.durNormal,
            curve: DTokens.curveStandard,
            width: _sidebarCollapsed ? 64 : DTokens.sidebarWidth,
            decoration: BoxDecoration(
              color: isDark ? DColorsDark.surface : DColorsLight.surface,
              border: Border(right: BorderSide(color: (isDark ? DColorsDark.border : DColorsLight.border).withValues(alpha: 0.5))),
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                children: [
                  // Header: logo + collapse toggle
                  Padding(
                    padding: const EdgeInsets.all(DTokens.spaceMd),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: DGradients.crimsonGlow,
                            borderRadius: DTokens.borderRadiusSm,
                          ),
                          child: Image.asset('assets/logo.png', width: 22, height: 22, fit: BoxFit.cover),
                        ),
                        if (!_sidebarCollapsed) ...[
                          const SizedBox(width: DTokens.spaceSm),
                          Flexible(
                            child: Text(
                              'Tamer Academy',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, fontFamily: DTypography.heading),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        const Spacer(),
                        IconButton(
                          icon: Icon(_sidebarCollapsed ? Icons.chevron_right : Icons.chevron_left, size: 18),
                          onPressed: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Nav items (Terminal style)
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: DTokens.spaceSm),
                      children: navItems.asMap().entries.map((entry) {
                        final i = entry.key;
                        final item = entry.value;
                        final selected = _index == i;
                        return Tooltip(
                          message: _sidebarCollapsed ? item.label : '',
                          child: InkWell(
                            onTap: () => _goTo(i),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: _sidebarCollapsed ? DTokens.spaceSm : DTokens.spaceMd,
                                vertical: DTokens.spaceSm + 2,
                              ),
                              margin: const EdgeInsets.symmetric(horizontal: DTokens.spaceSm, vertical: 2),
                              decoration: BoxDecoration(
                                color: selected ? const Color(0xFFC1232C).withValues(alpha: 0.12) : Colors.transparent,
                                borderRadius: DTokens.borderRadiusSm,
                                border: selected ? Border.all(color: const Color(0xFFC1232C).withValues(alpha: 0.3)) : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(item.icon, size: 20, color: selected ? const Color(0xFFC1232C) : (isDark ? DColorsDark.onSurfaceMuted : DColorsLight.onSurfaceMuted)),
                                  if (!_sidebarCollapsed) ...[
                                    const SizedBox(width: DTokens.spaceSm),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.label,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                                              color: selected ? const Color(0xFFC1232C) : (isDark ? DColorsDark.onSurface : DColorsLight.onSurface),
                                            ),
                                          ),
                                          Text(
                                            '\$ ${item.command}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontFamily: 'JetBrains Mono',
                                              color: isDark ? DColorsDark.onSurfaceMuted : DColorsLight.onSurfaceMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Bottom: theme + language + logout
                  Padding(
                    padding: const EdgeInsets.all(DTokens.spaceMd),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_sidebarCollapsed) const Divider(),
                        Row(
                          mainAxisAlignment: _sidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                          children: [
                            Consumer<AppState>(
                              builder: (context, state, _) => IconButton(
                                tooltip: t('theme'),
                                icon: Icon(state.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode, size: 20),
                                onPressed: () => context.read<AppState>().toggleTheme(),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                              ),
                            ),
                            if (!_sidebarCollapsed) ...[
                              PopupMenuButton<String>(
                                tooltip: t('language'),
                                icon: const Icon(Icons.language, size: 20),
                                onSelected: (code) => context.read<AppState>().setLanguage(code),
                                itemBuilder: (_) => [
                                  PopupMenuItem(value: 'ar', child: Text(t('arabic'))),
                                  PopupMenuItem(value: 'en', child: Text(t('english'))),
                                  PopupMenuItem(value: 'fr', child: Text(t('french'))),
                                ],
                              ),
                              const Spacer(),
                              IconButton(
                                tooltip: t('logout'),
                                icon: const Icon(Icons.logout, size: 20),
                                onPressed: () async {
                                  await context.read<AuthService>().logout();
                                  if (mounted) _goTo(0);
                                },
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          VerticalDivider(width: 1, color: isDark ? DColorsDark.border : DColorsLight.border),
          // Main content
          Expanded(
            child: IndexedStack(index: _index, children: pages),
          ),
        ],
      );
  }

  Widget _buildMobile(BuildContext context, AppUser user, String Function(String) t, bool isDark, List<Widget> pages) {
    return Scaffold(
      appBar: _index == 0 ? null : _buildAppBar(context, user, t, isDark),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.public_outlined), selectedIcon: const Icon(Icons.public_rounded), label: t('site')),
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home_rounded), label: t('home')),
          NavigationDestination(icon: const Icon(Icons.bookmark_border_rounded), selectedIcon: const Icon(Icons.bookmark_rounded), label: t('myCourses')),
          if (!user.isAdmin) NavigationDestination(icon: Badge(isLabelVisible: false, child: const Icon(Icons.assignment_outlined)), selectedIcon: const Icon(Icons.assignment_rounded), label: t('myHomeworks')),
          NavigationDestination(icon: const Icon(Icons.person_outline_rounded), selectedIcon: const Icon(Icons.person_rounded), label: t('profile')),
          if (user.isAdmin) NavigationDestination(icon: const Icon(Icons.admin_panel_settings_outlined), selectedIcon: const Icon(Icons.admin_panel_settings_rounded), label: t('admin')),
        ],
      ),
    );
  }

}
class _NavItem {
  final IconData icon;
  final String label;
  final String command;
  const _NavItem({required this.icon, required this.label, required this.command});
}
