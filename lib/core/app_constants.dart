import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  static const appName = 'Tamer Academy';

  static const firebaseWebOptions = FirebaseOptions(
    apiKey: 'AIzaSyAYJRDLk7KiHu0XkWu2_-CRPVbINtfV-aE',
    appId: '1:873541306285:web:c7386c2f9e741e2f898324',
    messagingSenderId: '873541306285',
    projectId: 'tamer-academy',
    authDomain: 'tamer-academy.firebaseapp.com',
    storageBucket: 'tamer-academy.firebasestorage.app',
  );

  static const tracks = ['web', 'mobile'];

  // Supabase — لتخفيف ضغط Firebase (القراءات/الكتابات/التخزين)
  static const supabaseUrl = 'https://kwsgolulpswnknbxkkdf.supabase.co';
  static const supabaseAnonKey = 'sb_publishable_anYVTwzJ-h5rhQlESQyZAA_0L5MY4mz';

  // Gemini AI — يُقرأ من --dart-define أو من .env (flutter_dotenv)
  static String get geminiApiKey {
    const fromDefine = String.fromEnvironment('GEMINI_API_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;
    try {
      final fromEnv = dotenv.env['GEMINI_API_KEY'];
      if (fromEnv != null && fromEnv.trim().isNotEmpty) return fromEnv.trim();
    } catch (_) {}
    return '';
  }
}