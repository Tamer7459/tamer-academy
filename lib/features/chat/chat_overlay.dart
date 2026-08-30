import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ai/chat_controller.dart';
import '../../core/app_theme.dart';

class AiChatOverlay extends StatefulWidget {
  const AiChatOverlay({super.key});

  @override
  State<AiChatOverlay> createState() => _AiChatOverlayState();
}

class _AiChatOverlayState extends State<AiChatOverlay> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _showCodeField = false;
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _inputCtrl.dispose();
    _codeCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ChatController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).colorScheme.surface,
      child: Container(
        width: 360,
        height: 460,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.tealPrimary, AppColors.tealLight]),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/ai_robot.jpg', width: 32, height: 32, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18)))),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(ctrl.isAdmin ? 'مساعد الأدمن الذكي' : 'Tamer AI', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)), Text(ctrl.isAdmin ? 'توليد أسئلة • تلخيص' : 'شرح • تحليل كود • تلميحات', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 10))])),
                  IconButton(onPressed: () => ctrl.clear(), icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 18), tooltip: 'مسح', padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                  const SizedBox(width: 4),
                  // Close is handled by parent
                ],
              ),
            ),
            // Messages
            Expanded(
              child: Container(
                color: isDark ? const Color(0xFF0F1A2A) : const Color(0xFFF8FAFC),
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(12),
                  itemCount: ctrl.messages.length + (ctrl.isLoading ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (ctrl.isLoading && i == ctrl.messages.length) {
                      return const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Row(children: [SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width: 8), Text('يفكر...', style: TextStyle(fontSize: 12, color: Colors.grey))]));
                    }
                    final m = ctrl.messages[i];
                    final isUser = m.isUser;
                    if (isUser) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          constraints: const BoxConstraints(maxWidth: 270),
                          decoration: BoxDecoration(
                            color: AppColors.tealPrimary,
                            borderRadius: BorderRadius.circular(14).copyWith(bottomRight: const Radius.circular(4)),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
                          ),
                          child: SelectableText(m.text, style: const TextStyle(fontSize: 12.5, height: 1.5, color: Colors.white)),
                        ),
                      );
                    }
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipOval(child: Image.asset('assets/ai_robot.jpg', width: 28, height: 28, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(width: 28, height: 28, decoration: BoxDecoration(color: AppColors.tealPrimary, shape: BoxShape.circle), child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 14)))),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            constraints: const BoxConstraints(maxWidth: 220),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E2E4A) : Colors.white,
                              borderRadius: BorderRadius.circular(14).copyWith(bottomLeft: const Radius.circular(4)),
                              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
                            ),
                            child: SelectableText(m.text, style: TextStyle(fontSize: 12.5, height: 1.5, color: isDark ? Colors.white : AppColors.navyText)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            // Code attach
            if (_showCodeField)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)))),
                child: Row(
                  children: [
                    Expanded(child: TextField(controller: _codeCtrl, maxLines: 3, minLines: 1, style: const TextStyle(fontFamily: 'monospace', fontSize: 11), decoration: InputDecoration(hintText: 'الصق كودك هنا للتحليل...', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(8)))),
                    const SizedBox(width: 6),
                    IconButton(onPressed: () => setState(() => _showCodeField = false), icon: const Icon(Icons.close_rounded, size: 18)),
                  ],
                ),
              ),
            // Input
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)), border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)))),
              child: Row(
                children: [
                  IconButton(onPressed: () => setState(() => _showCodeField = !_showCodeField), icon: Icon(_showCodeField ? Icons.code_off_rounded : Icons.code_rounded, size: 18, color: _showCodeField ? AppColors.tealPrimary : AppColors.grayMedium), tooltip: 'إرفاق كود', padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 36, minHeight: 36)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: ctrl.isAdmin ? 'اسأل: ولّد 9 أسئلة...' : 'اسأل عن الدرس أو حلّل كودي...',
                        hintStyle: TextStyle(fontSize: 12, color: AppColors.grayMedium),
                        isDense: true,
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1A2942) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 6),
                  FilledButton(
                    onPressed: ctrl.isLoading ? null : _send,
                    style: FilledButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(12), backgroundColor: AppColors.tealPrimary),
                    child: ctrl.isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send_rounded, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    final code = _showCodeField ? _codeCtrl.text.trim() : null;
    final ctrl = context.read<ChatController>();
    ctrl.send(text, code: code?.isEmpty == true ? null : code);
    _inputCtrl.clear();
    // keep code for next message? clear after send
    // _codeCtrl.clear();
    _scrollDown();
  }
}
