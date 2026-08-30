// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/material.dart';
import '../main.dart';
import '../screens/test_viewer.dart';

bool isTestRoute() {
  try {
    final hash = html.window.location.hash;
    return hash == '#/test' || hash == '#test';
  } catch (_) {
    return false;
  }
}

void setupWebHashListener(void Function() onChange) {
  try {
    html.window.addEventListener('hashchange', (_) => onChange());
  } catch (_) {}
}

void setupWebTestHook(BuildContext context) {
  print('setupWebTestHook called');
  void showTest() {
    print('showTest called');
    try {
      final nav = TamerAcademyApp.navigatorKey.currentState;
      print('nav: ');
      if (nav != null) {
        nav.push(MaterialPageRoute(builder: (_) => const TestViewerScreen()));
        print('pushed via navKey');
      } else {
        print('nav is null, trying context after delay');
        Future.delayed(const Duration(milliseconds: 100), () {
          try {
            final nav2 = TamerAcademyApp.navigatorKey.currentState;
            if (nav2 != null) {
              nav2.push(MaterialPageRoute(builder: (_) => const TestViewerScreen()));
              print('pushed via navKey (delayed)');
            } else {
              Navigator.of(TamerAcademyApp.navigatorKey.currentContext ?? TamerAcademyApp.navigatorKey.currentState!.context).push(
                MaterialPageRoute(builder: (_) => const TestViewerScreen()),
              );
              print('pushed via context fallback');
            }
          } catch (err) {
            print('delayed push error: ');
          }
        });
      }
    } catch (err) {
      print('showTest error: ');
      try {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TestViewerScreen()));
        print('pushed via context fallback');
      } catch (err2) {
        print('fallback error: ');
      }
    }
  }

  html.window.addEventListener('message', (event) {
    final data = (event as html.MessageEvent).data;
    if (data is Map && data['type'] == 'showTestViewer') showTest();
    if (data is String && data == 'showTestViewer') showTest();
    if (data is String) {
      try {
        if (data.contains('showTestViewer')) showTest();
      } catch (_) {}
    }
  });
  html.window.addEventListener('showTestViewer', (event) => showTest());
  html.window.addEventListener('testViewer', (event) => showTest());
  try {
    js.context['showTestViewer'] = () {
      print('global showTestViewer called');
      try {
        final nav = TamerAcademyApp.navigatorKey.currentState;
        print('global showTestViewer nav checked');
        if (nav != null) {
          nav.push(MaterialPageRoute(builder: (_) => const TestViewerScreen()));
          print('pushed via navKey (global)');
        } else {
          final navContext = TamerAcademyApp.navigatorKey.currentContext;
          if (navContext != null) {
            Navigator.of(navContext).push(MaterialPageRoute(builder: (_) => const TestViewerScreen()));
            print('pushed via context (global)');
          } else {
            Future.delayed(const Duration(milliseconds: 100), () {
              final nav2 = TamerAcademyApp.navigatorKey.currentState;
              if (nav2 != null) {
                nav2.push(MaterialPageRoute(builder: (_) => const TestViewerScreen()));
                print('pushed via navKey (delayed global)');
              }
            });
          }
        }
      } catch (err) {
        print('global showTestViewer error occurred');
      }
    };
  } catch (_) {}
}
