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

  List<Widget> _buildPages(AppUser user, String Function(String) t) {
    return <Widget>[
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
  }

  List<NavigationRailDestination> _buildRailDestinations(
      AppUser user, String Function(String) t) {
    final dest = <NavigationRailDestination>[
      NavigationRailDestination(
        icon: const Icon(Icons.public_outlined),
        selectedIcon: const Icon(Icons.public_rounded),
        label: Text(t('site')),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home_rounded),
        label: Text(t('home')),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.bookmark_border_rounded),
        selectedIcon: const Icon(Icons.bookmark_rounded),
        label: Text(t('myCourses')),
      ),
      if (!user.isAdmin)
        NavigationRailDestination(
          icon: const Icon(Icons.assignment_outlined),
          selectedIcon: const Icon(Icons.assignment_rounded),
          label: Text(t('myHomeworks')),
        ),
      NavigationRailDestination(
        icon: const Icon(Icons.person_outline_rounded),
        selectedIcon: const Icon(Icons.person_rounded),
        label: Text(t('profile')),
      ),
      if (user.isAdmin)
        NavigationRailDestination(
          icon: const Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: const Icon(Icons.admin_panel_settings_rounded),
          label: Text(t('admin')),
        ),
    ];
    return dest;
  }

  Widget _buildWideBody(
      BuildContext context, AppUser user, String Function(String) t, bool isDark,
      List<Widget> pages, List<NavigationRailDestination> destinations) {
    final surface = isDark ? DColorsDark.surface : DColorsLight.surface;
    final border = isDark ? DColorsDark.border : DColorsLight.border;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ════════════════════════════════════════════════════════════════════
        // Sidebar — Navigation Rail (للمسحوب والتابلت العريض فقط)
        // ═════════════════════════════════════════════════════════════════════
        Container(
          width: DTokens.sidebarWidth,
          decoration: BoxDecoration(
            color: surface,
            border: Border(right: BorderSide(color: border.withValues(alpha: 0.5))),
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Column(
              children: [
                // رأس الشريط الجانبي: شعار + اسم العلامة
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DTokens.spaceMd, DTokens.spaceLg, DTokens.spaceMd, DTokens.spaceLg,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          gradient: DGradients.brandGlow,
                          borderRadius: DTokens.borderRadiusMd,
                        ),
                        child: Image.asset(
                          'assets/logo.png',
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: DTokens.spaceSm),
                      Flexible(
                        child: Text(
                          t('appName'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DTokens.spaceMd),
                Expanded(
                  child: NavigationRail(
                    selectedIndex: _index,
                    onDestinationSelected: _goTo,
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    selectedIconTheme: const IconThemeData(color: DTokens.brandTeal),
                    unselectedIconTheme: IconThemeData(
                      color: isDark ? DColorsDark.onSurfaceMuted : DColorsLight.onSurfaceMuted,
                    ),
                    selectedLabelTextStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: DTokens.brandTeal,
                    ),
                    unselectedLabelTextStyle: TextStyle(
                      color: isDark ? DColorsDark.onSurfaceMuted : DColorsLight.onSurfaceMuted,
                    ),
                    destinations: destinations,
                  ),
                ),
                const SizedBox(height: DTokens.spaceMd),
                // أدوات أسفل الشريط الجانبي (المظهر، اللغة، خروج)
                Padding(
                  padding: const EdgeInsets.all(DTokens.spaceMd),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Consumer<AppState>(
                        builder: (context, state, _) => IconButton(
                          tooltip: t('theme'),
                          icon: Icon(
                            state.themeMode == ThemeMode.dark
                                ? Icons.light_mode
                                : Icons.dark_mode,
                          ),
                          onPressed: () => context.read<AppState>().toggleTheme(),
                          iconSize: 20,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(height: DTokens.spaceSm),
                      PopupMenuButton<String>(
                        tooltip: t('language'),
                        icon: const Icon(Icons.language),
                        iconSize: 20,
                        onSelected: (code) => context.read<AppState>().setLanguage(code),
                        itemBuilder: (_) => [
                          PopupMenuItem(value: 'ar', child: Text(t('arabic'))),
                          PopupMenuItem(value: 'en', child: Text(t('english'))),
                          PopupMenuItem(value: 'fr', child: Text(t('french'))),
                        ],
                      ),
                      const Divider(height: DTokens.spaceLg * 2),
                      ListTile(
                        leading: const Icon(Icons.logout, size: 20),
                        title: Text(
                          t('logout'),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        contentPadding: EdgeInsets.zero,
                        onTap: () async {
                          await context.read<AuthService>().logout();
                          if (mounted) _goTo(0);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        VerticalDivider(width: 1),
        // ═════════════════════════════════════════════════════════════════════════
        // المحتوى الرئيسي
        // ═════════════════════════════════════════════════════════════════════════
        Expanded(
          child: IndexedStack(index: _index, children: pages),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, AppUser user, String Function(String) t, bool isDark) {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: DGradients.brandGlow,
              borderRadius: DTokens.borderRadiusMd,
            ),
            child: Image.asset(
              'assets/logo.png',
              width: 22,
              height: 22,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            t('appName'),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.navyText,
            ),
          ),
        ],
      ),
      actions: [
        const NotificationBell(),
        Consumer<AppState>(
          builder: (context, state, _) => IconButton(
            tooltip: t('theme'),
            icon: Icon(
              state.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
            ),
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

    final pages = _buildPages(user, t);
    final destinations = _buildRailDestinations(user, t);

    if (_index >= pages.length) _index = 0;

    // ═══════════════════════════════════════════════════════════════════════
    // ويب عريض / تابلت: Sidebar Rail + محتوى (بدون شريط سفلي)
    // ═════════════════════════════════════════════════════════════════════════
    if (_isWide) {
      return Scaffold(
        body: _buildWideBody(context, user, t, isDark, pages, destinations),
      );
    }

    // ═════════════════════════════════════════════════════════════════════════
    // موبايل: شريط سفلي + AppBar (كما كان)
    // ═════════════════════════════════════════════════════════════════════════
    return Scaffold(
      appBar: _index == 0 ? null : _buildAppBar(context, user, t, isDark),
      body: IndexedStack(index: _index, children: pages),
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
