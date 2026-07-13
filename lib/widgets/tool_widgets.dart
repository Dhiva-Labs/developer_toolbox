import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Standard page scaffold for a tool: app-bar title, scrollable body,
/// content width capped so desktop layouts stay readable.
class ToolPage extends StatelessWidget {
  const ToolPage({
    super.key,
    required this.title,
    required this.children,
    this.scrollable = true,
  });

  final String title;
  final List<Widget> children;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final child in children)
          Padding(padding: const EdgeInsets.only(bottom: 16), child: child),
      ],
    );
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: scrollable
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16), child: column)
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Multiline text input with a label and paste / clear actions.
class ToolInput extends StatelessWidget {
  const ToolInput({
    super.key,
    required this.controller,
    this.label = 'Input',
    this.hint,
    this.minLines = 4,
    this.maxLines = 10,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            IconButton(
              tooltip: 'Paste',
              icon: const Icon(Icons.content_paste, size: 20),
              onPressed: () async {
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                if (data?.text != null) {
                  controller.text = data!.text!;
                  onChanged?.call(controller.text);
                }
              },
            ),
            IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () {
                controller.clear();
                onChanged?.call('');
              },
            ),
          ],
        ),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          onChanged: onChanged,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ],
    );
  }
}

/// Read-only output block with a copy button.
class ToolOutput extends StatelessWidget {
  const ToolOutput({
    super.key,
    required this.text,
    this.label = 'Output',
    this.isError = false,
    this.maxHeight = 300,
  });

  final String text;
  final String label;
  final bool isError;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            IconButton(
              tooltip: 'Copy',
              icon: const Icon(Icons.copy, size: 20),
              onPressed: text.isEmpty
                  ? null
                  : () {
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(const SnackBar(
                          content: Text('Copied to clipboard'),
                          duration: Duration(seconds: 1),
                        ));
                    },
            ),
          ],
        ),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 56, maxHeight: maxHeight),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isError
                ? scheme.errorContainer
                : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              text.isEmpty ? ' ' : text,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: isError ? scheme.onErrorContainer : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A labelled row of action buttons.
class ActionRow extends StatelessWidget {
  const ActionRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: children);
  }
}

void copyToClipboard(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(
      content: Text('Copied to clipboard'),
      duration: Duration(seconds: 1),
    ));
}
