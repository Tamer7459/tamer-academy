import 'package:firebase_ai/firebase_ai.dart' as fb_ai;
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as ggl;

import '../core/app_constants.dart';
import 'tamer_prompt.dart';

class AiService {
  fb_ai.GenerativeModel? _fbModel;
  fb_ai.ChatSession? _fbChat;
  ggl.GenerativeModel? _gglModel;
  ggl.ChatSession? _gglChat;
  bool _isAdmin = false;

  bool get isReady => _fbModel != null || _gglModel != null;

  void init({required bool isAdmin, String? lessonContext, String? userName}) {
    _isAdmin = isAdmin;
    final prompt = isAdmin ? tamerAdminPrompt : tamerPrompt;
    final withContext = lessonContext != null && lessonContext.trim().isNotEmpty
        ? "$prompt\n\nCURRENT LESSON CONTEXT (for tailoring, not to repeat verbatim):\n${lessonContext.substring(0, lessonContext.length.clamp(0, 3000))}\nUSER: ${userName ?? 'طالب'}"
        : prompt;
    // 1) Try Firebase AI — use latest available (2.5-flash, 3.1-preview) — avoid 2.5-pro (not for new users)
    for (final m in ['gemini-2.5-flash', 'gemini-2.5-flash-lite', 'gemini-3.1-pro-preview', 'gemini-1.5-flash']) {
      try {
        _fbModel = fb_ai.FirebaseAI.googleAI().generativeModel(
          model: m,
          systemInstruction: fb_ai.Content.text(withContext),
          generationConfig: fb_ai.GenerationConfig(temperature: 0.7, maxOutputTokens: 800),
        );
        _fbChat = _fbModel!.startChat();
        debugPrint('AiService: Firebase AI ready with $m');
        break;
      } catch (e) {
        debugPrint('AiService Firebase init $m error: $e');
      }
    }
    // 2) Direct Gemini — prefer 2.5-flash / 3.1-preview (available per ListModels for this key)
    if (AppConstants.geminiApiKey.trim().isNotEmpty) {
      for (final m in ['gemini-2.5-flash', 'gemini-2.5-flash-lite', 'gemini-3.1-pro-preview', 'gemini-1.5-flash']) {
        try {
          _gglModel = ggl.GenerativeModel(
            model: m,
            apiKey: AppConstants.geminiApiKey,
            systemInstruction: ggl.Content.text(withContext),
            generationConfig: ggl.GenerationConfig(temperature: 0.7, maxOutputTokens: 800),
          );
          _gglChat = _gglModel!.startChat(history: []);
          debugPrint('AiService: Direct Gemini ready with $m');
          break;
        } catch (e) {
          debugPrint('AiService GGL init $m error: $e');
        }
      }
    }
  }

  Future<String> sendMessage(String userMessage, {String? codeContext}) async {
    final fullMessage = codeContext != null && codeContext.trim().isNotEmpty
        ? "$userMessage\n\n[كود الطالب للتحليل — أعطِ تلميحاً فقط]:\n```dart\n${codeContext.substring(0, codeContext.length.clamp(0, 2000))}\n```"
        : userMessage;

    Future<String?> tryFbChat() async {
      if (_fbChat != null) {
        try {
          final response = await _fbChat!.sendMessage(fb_ai.Content.text(fullMessage));
          final text = response.text;
          if (text != null && text.trim().isNotEmpty) return text.trim();
        } catch (e) {
          debugPrint('AiService FB chat error: $e');
          if (e.toString().contains('is no longer available') || e.toString().contains('not found') || e.toString().contains('not supported') || e.toString().contains('no longer available to new users')) {
            for (final m in ['gemini-2.5-flash', 'gemini-2.5-flash-lite', 'gemini-3.1-pro-preview']) {
              try {
                _fbModel = fb_ai.FirebaseAI.googleAI().generativeModel(model: m, systemInstruction: fb_ai.Content.text(_isAdmin ? tamerAdminPrompt : tamerPrompt));
                _fbChat = _fbModel!.startChat();
                final r2 = await _fbChat!.sendMessage(fb_ai.Content.text(fullMessage));
                if (r2.text != null && r2.text!.trim().isNotEmpty) return r2.text!.trim();
              } catch (_) {}
            }
          }
        }
      }
      return null;
    }

    Future<String?> tryFbGenerate() async {
      if (_fbModel != null) {
        try {
          final res = await _fbModel!.generateContent([fb_ai.Content.text(fullMessage)]);
          final t = res.text;
          if (t != null && t.trim().isNotEmpty) return t.trim();
        } catch (e) {
          debugPrint('AiService FB generate error: $e');
        }
      }
      return null;
    }

    Future<String?> tryGglChat() async {
      if (_gglChat != null) {
        try {
          final response = await _gglChat!.sendMessage(ggl.Content.text(fullMessage));
          final text = response.text;
          if (text != null && text.trim().isNotEmpty) return text.trim();
        } catch (e) {
          debugPrint('AiService GGL chat error: $e');
          if (e.toString().contains('is no longer available') || e.toString().contains('not found') || e.toString().contains('not supported') || e.toString().contains('no longer available to new users')) {
            for (final m in ['gemini-2.5-flash', 'gemini-2.5-flash-lite', 'gemini-3.1-pro-preview']) {
              try {
                _gglModel = ggl.GenerativeModel(model: m, apiKey: AppConstants.geminiApiKey, systemInstruction: ggl.Content.text(_isAdmin ? tamerAdminPrompt : tamerPrompt));
                _gglChat = _gglModel!.startChat(history: []);
                final r2 = await _gglChat!.sendMessage(ggl.Content.text(fullMessage));
                if (r2.text != null && r2.text!.trim().isNotEmpty) return r2.text!.trim();
              } catch (_) {}
            }
          }
        }
      }
      return null;
    }

    Future<String?> tryGglGenerate() async {
      if (_gglModel != null) {
        try {
          final res = await _gglModel!.generateContent([ggl.Content.text(fullMessage)]);
          final t = res.text;
          if (t != null && t.trim().isNotEmpty) return t.trim();
        } catch (e) {
          debugPrint('AiService GGL generate error: $e');
          if (e.toString().contains('is no longer available') || e.toString().contains('not found') || e.toString().contains('no longer available to new users')) {
            for (final m in ['gemini-2.5-flash', 'gemini-2.5-flash-lite', 'gemini-3.1-pro-preview']) {
              try {
                final m2 = ggl.GenerativeModel(model: m, apiKey: AppConstants.geminiApiKey);
                final r2 = await m2.generateContent([ggl.Content.text(fullMessage)]);
                if (r2.text != null && r2.text!.trim().isNotEmpty) return r2.text!.trim();
              } catch (_) {}
            }
          }
          return 'حدث خطأ في الاتصال بـ Gemini: $e\nجرب تغيير المفتاح أو استخدم Firebase AI Logic.';
        }
      }
      return null;
    }

    // Try in order: FB chat -> FB generate -> GGL chat -> GGL generate
    var r = await tryFbChat();
    if (r != null) return r;
    r = await tryFbGenerate();
    if (r != null) return r;
    r = await tryGglChat();
    if (r != null) return r;
    r = await tryGglGenerate();
    if (r != null) return r;

    return 'الذكاء غير مهيأ حالياً. تأكد من تفعيل Firebase AI Logic في Console أو صحة GEMINI_API_KEY. إذا استمر الخطأ، جرب gemini-1.5-flash.';
  }

  void reset() {
    try {
      if (_fbModel != null) _fbChat = _fbModel!.startChat();
    } catch (_) {}
    try {
      if (_gglModel != null) _gglChat = _gglModel!.startChat(history: []);
    } catch (_) {}
  }
}
