import 'package:flutter/foundation.dart';
import 'ai_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  ChatMessage({required this.text, required this.isUser, DateTime? time}) : time = time ?? DateTime.now();
}

class ChatController extends ChangeNotifier {
  final AiService _ai = AiService();
  final List<ChatMessage> messages = [];
  bool isLoading = false;
  bool isInitialized = false;
  String? lessonContext;
  String? userName;
  bool isAdmin = false;

  void init({required bool isAdmin, String? lessonContext, String? userName}) {
    this.isAdmin = isAdmin;
    this.lessonContext = lessonContext;
    this.userName = userName;
    _ai.init(isAdmin: isAdmin, lessonContext: lessonContext, userName: userName);
    isInitialized = true;
    if (messages.isEmpty) {
      messages.add(ChatMessage(
        text: isAdmin
            ? 'مرحباً أستاذ ${userName ?? ''} 👋\nأنا مساعدك الذكي — أستطيع توليد 9 أسئلة، صياغة واجب، أو تلخيص الإرسالات. كيف أساعدك اليوم؟'
            : 'مرحباً ${userName ?? ''} 👋\nأنا مساعد تامر الذكي — اشرح لك الدروس، أحلل كودك وأعطيك تلميحات. اسألني عن أي درس أو الصق كودك!',
        isUser: false,
      ));
    }
    notifyListeners();
  }

  void updateLessonContext(String? ctx) {
    lessonContext = ctx;
    _ai.init(isAdmin: isAdmin, lessonContext: ctx, userName: userName);
  }

  Future<void> send(String text, {String? code}) async {
    if (text.trim().isEmpty) return;
    messages.add(ChatMessage(text: text.trim(), isUser: true));
    isLoading = true;
    notifyListeners();
    try {
      final reply = await _ai.sendMessage(text.trim(), codeContext: code);
      messages.add(ChatMessage(text: reply, isUser: false));
    } catch (e) {
      messages.add(ChatMessage(text: 'خطأ: $e', isUser: false));
    }
    isLoading = false;
    // keep last 24 messages (12 exchanges)
    if (messages.length > 24) {
      messages.removeRange(0, messages.length - 24);
    }
    notifyListeners();
  }

  void clear() {
    messages.clear();
    _ai.reset();
    // re-add welcome
    messages.add(ChatMessage(
      text: isAdmin
          ? 'تم مسح المحادثة. كيف أساعدك الآن؟'
          : 'تم مسح المحادثة. اسألني من جديد!',
      isUser: false,
    ));
    notifyListeners();
  }
}
