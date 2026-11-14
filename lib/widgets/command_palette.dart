import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_localizations.dart';
import '../core/design_tokens.dart';

/// ═════════════════════════════════════════════════════════════════════════════
/// Command Palette — Ctrl/Cmd+K for quick search and navigation
/// ═════════════════════════════════════════════════════════════════════════════

class CommandPalette extends StatefulWidget {
  final List<CommandItem> commands;
  final ValueChanged<CommandItem> onSelected;

  const CommandPalette({
    super.key,
    required this.commands,
    required this.onSelected,
  });

  static Future<CommandItem?> show(BuildContext context, List<CommandItem> commands) {
    return showDialog<CommandItem>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => CommandPalette(
        commands: commands,
        onSelected: (item) => Navigator.of(ctx).pop(item),
      ),
    );
  }

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<CommandItem> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.commands;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filter(String query) {
    if (query.isEmpty) {
      setState(() => _filtered = widget.commands);
      return;
    }
    final q = query.toLowerCase();
    setState(() {
      _filtered = widget.commands.where((c) {
        return c.label.toLowerCase().contains(q) ||
            c.command.toLowerCase().contains(q) ||
            (c.description?.toLowerCase().contains(q) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? DColorsDark.surfaceElevated : DColorsLight.surfaceElevated;
    final border = isDark ? DColorsDark.border : DColorsLight.border;
    final onSurface = isDark ? DColorsDark.onSurface : DColorsLight.onSurface;
    final muted = isDark ? DColorsDark.onSurfaceMuted : DColorsLight.onSurfaceMuted;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 560,
          constraints: const BoxConstraints(maxHeight: 480),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: DTokens.borderRadiusMd,
            border: Border.all(color: border),
            boxShadow: DShadows.cardElevated,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search field
              Padding(
                padding: const EdgeInsets.all(DTokens.spaceMd),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: _filter,
                  style: TextStyle(color: onSurface, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Type a command or search...',
                    hintStyle: TextStyle(color: muted),
                    prefixIcon: Icon(Icons.search, color: muted),
                    border: OutlineInputBorder(
                      borderRadius: DTokens.borderRadiusSm,
                      borderSide: BorderSide(color: border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: DTokens.borderRadiusSm,
                      borderSide: BorderSide(color: border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: DTokens.borderRadiusSm,
                      borderSide: const BorderSide(color: Color(0xFFC1232C), width: 2),
                    ),
                    filled: true,
                    fillColor: isDark ? DColorsDark.surface : DColorsLight.surface,
                  ),
                ),
              ),
              const Divider(height: 1),
              // Results
              Flexible(
                child: _filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(DTokens.spaceLg),
                        child: Text('No results found', style: TextStyle(color: muted)),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filtered.length,
                        itemBuilder: (context, i) {
                          final item = _filtered[i];
                          return ListTile(
                            leading: Icon(item.icon, color: const Color(0xFFC1232C), size: 20),
                            title: Text(item.label, style: TextStyle(color: onSurface, fontWeight: FontWeight.w600)),
                            subtitle: item.description != null
                                ? Text(item.description!, style: TextStyle(color: muted, fontSize: 12))
                                : null,
                            trailing: item.command != null
                                ? Text(
                                    '\$ ${item.command}',
                                    style: TextStyle(
                                      fontFamily: 'JetBrains Mono',
                                      fontSize: 11,
                                      color: isDark ? DColorsDark.eagle : DColorsLight.eagle,
                                    ),
                                  )
                                : null,
                            onTap: () => widget.onSelected(item),
                          );
                        },
                      ),
              ),
              // Footer hint
              Container(
                padding: const EdgeInsets.symmetric(horizontal: DTokens.spaceMd, vertical: DTokens.spaceSm),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: border)),
                ),
                child: Row(
                  children: [
                    Text('↑↓ Navigate', style: TextStyle(fontSize: 11, color: muted)),
                    const SizedBox(width: DTokens.spaceMd),
                    Text('Enter Select', style: TextStyle(fontSize: 11, color: muted)),
                    const SizedBox(width: DTokens.spaceMd),
                    Text('Esc Close', style: TextStyle(fontSize: 11, color: muted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommandItem {
  final IconData icon;
  final String label;
  final String? command;
  final String? description;
  final VoidCallback? action;

  const CommandItem({
    required this.icon,
    required this.label,
    this.command,
    this.description,
    this.action,
  });
}
