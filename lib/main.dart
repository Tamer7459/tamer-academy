import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_constants.dart';
import 'core/app_localizations.dart';
import 'core/app_theme.dart';
import 'screens/root_screen.dart';
import 'screens/test_viewer.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(options: AppConstants.firebaseWebOptions);
  } else {
    await Firebase.initializeApp();
  }
  // Supabase لتخفيف ضغط Firebase (قراءات/كتابات/تخزين) — يبقى Firebase Auth هو المصدر
  try {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  } catch (e) {
    debugPrint('Supabase init failed (fallback to Firebase): $e');
  }
  runApp(const TamerAcademyApp());
}

class TamerAcademyApp extends StatelessWidget {
  const TamerAcademyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => DatabaseService()),
      ],
      child: Consumer<AppState>(
        builder: (context, state, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: state.themeMode,
            locale: state.locale,
            scrollBehavior: AppTheme.scrollBehavior,
            onGenerateRoute: (settings) {
              if (settings.name == '/test') {
                return MaterialPageRoute(builder: (_) => const TestViewerScreen());
              }
              return null;
            },
            builder: (context, child) => ScrollConfiguration(
              behavior: AppTheme.scrollBehavior,
              child: MediaQuery.withClampedTextScaling(
                maxScaleFactor: 1.3,
                child: Scrollbar(
                  thumbVisibility: false,
                  trackVisibility: false,
                  child: child!,
                ),
              ),
            ),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const RootScreen(),
          );
        },
      ),
    );
  }
}
