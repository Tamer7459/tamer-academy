import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/web_utils_stub.dart' if (dart.library.html) '../utils/web_utils.dart' as web_utils;

import '../core/app_theme.dart';
import 'test_viewer.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/app_user.dart';
import 'home_shell.dart';
import 'landing/landing_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  AppUser? _appUser;
  bool _loading = true;
  bool _hookSetup = false;

  @override
  void initState() {
    super.initState();
    _listenAuth();
    if (kIsWeb) {
      web_utils.setupWebHashListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  void _listenAuth() {
    final auth = context.read<AuthService>();
    final db = context.read<DatabaseService>();

    auth.userStream.listen((User? user) async {
      if (user == null) {
        setState(() {
          _appUser = null;
          _loading = false;
        });
        return;
      }
      AppUser? appUser = await db.getUser(user.uid);
      if (appUser == null) {
        appUser = AppUser(
          uid: user.uid,
          name: user.displayName ?? user.email!.split('@').first,
          email: user.email ?? '',
          photoUrl: user.photoURL ?? '',
          createdAt: DateTime.now(),
        );
        await db.createUser(appUser);
      }
      if (mounted) {
        setState(() {
          _appUser = appUser;
          _loading = false;
        });
      }
      db.userStream(user.uid).listen((u) {
        if (u != null && mounted) {
          setState(() => _appUser = u);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && !_hookSetup) {
      _hookSetup = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          web_utils.setupWebTestHook(context);
        } catch (_) {}
      });
    }
    // Web test route: https://tamer-academy.web.app/#/test
    if (kIsWeb && web_utils.isTestRoute()) {
      return const SelectionArea(child: TestViewerScreen());
    }
    if (_loading) {
      return const SelectionArea(child: Scaffold(body: _SplashScreen()));
    }
    if (_appUser == null) {
      return const SelectionArea(child: LandingScreen());
    }
    return SelectionArea(child: HomeShell(user: _appUser!));
  }
}

/// شاشة البداية: شعار الهوية + اسم المنصة
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.tealPrimary.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/logo.png',
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Tamer Academy',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 28),
          const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ],
      ),
    );
  }
}