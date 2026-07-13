import 'dart:convert';

import 'package:flutter/material.dart';

import '../widgets/tool_widgets.dart';

/// Line/column for a character offset, for friendlier error messages.
String _position(String source, int offset) {
  var line = 1, col = 1;
  for (var i = 0; i < offset && i < source.length; i++) {
    if (source[i] == '\n') {
      line++;
      col = 1;
    } else {
      col++;
    }
  }
  return 'line $line, column $col';
}

// ---------------------------------------------------------------------------
// JSON Formatter
// ---------------------------------------------------------------------------

class JsonFormatterTool extends StatefulWidget {
  const JsonFormatterTool({super.key});

  @override
  State<JsonFormatterTool> createState() => _JsonFormatterToolState();
}

class _JsonFormatterToolState extends State<JsonFormatterTool> {
  final _input = TextEditingController();
  String _output = '';
  bool _error = false;
  String _indent = '  ';

  void _format() {
    try {
      final decoded = jsonDecode(_input.text);
      setState(() {
        _output = JsonEncoder.withIndent(_indent).convert(decoded);
        _error = false;
      });
    } on FormatException catch (e) {
      setState(() {
        _output = e.offset != null
            ? '${e.message}\nAt ${_position(_input.text, e.offset!)}'
            : e.message;
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: 'JSON Formatter',
      children: [
        ToolInput(controller: _input, hint: 'Paste JSON…', minLines: 6),
        Row(
          children: [
            FilledButton.icon(
              onPressed: _format,
              icon: const Icon(Icons.format_align_left),
              label: const Text('Format'),
            ),
            const SizedBox(width: 16),
            const Text('Indent:'),
            const SizedBox(width: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: '  ', label: Text('2')),
                ButtonSegment(value: '    ', label: Text('4')),
                ButtonSegment(value: '\t', label: Text('Tab')),
              ],
              selected: {_indent},
              onSelectionChanged: (s) => setState(() => _indent = s.first),
            ),
          ],
        ),
        ToolOutput(text: _output, isError: _error, maxHeight: 400),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// JSON Minifier
// ---------------------------------------------------------------------------

class JsonMinifierTool extends StatefulWidget {
  const JsonMinifierTool({super.key});

  @override
  State<JsonMinifierTool> createState() => _JsonMinifierToolState();
}

class _JsonMinifierToolState extends State<JsonMinifierTool> {
  final _input = TextEditingController();
  String _output = '';
  bool _error = false;
  String _stats = '';

  void _minify() {
    try {
      final decoded = jsonDecode(_input.text);
      final minified = jsonEncode(decoded);
      setState(() {
        _output = minified;
        _error = false;
        final before = _input.text.length;
        final after = minified.length;
        final pct =
            before == 0 ? 0 : ((before - after) / before * 100).round();
        _stats = '$before → $after chars (−$pct%)';
      });
    } on FormatException catch (e) {
      setState(() {
        _output = e.offset != null
            ? '${e.message}\nAt ${_position(_input.text, e.offset!)}'
            : e.message;
        _error = true;
        _stats = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: 'JSON Minifier',
      children: [
        ToolInput(controller: _input, hint: 'Paste JSON…', minLines: 6),
        FilledButton.icon(
          onPressed: _minify,
          icon: const Icon(Icons.compress),
          label: const Text('Minify'),
        ),
        ToolOutput(
          text: _output,
          isError: _error,
          label: _stats.isEmpty ? 'Output' : 'Output — $_stats',
          maxHeight: 400,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// JSON Validator
// ---------------------------------------------------------------------------

class JsonValidatorTool extends StatefulWidget {
  const JsonValidatorTool({super.key});

  @override
  State<JsonValidatorTool> createState() => _JsonValidatorToolState();
}

class _JsonValidatorToolState extends State<JsonValidatorTool> {
  final _input = TextEditingController();
  bool? _valid;
  String _message = '';

  void _validate() {
    final text = _input.text;
    if (text.trim().isEmpty) {
      setState(() {
        _valid = null;
        _message = '';
      });
      return;
    }
    try {
      final decoded = jsonDecode(text);
      var summary = 'Valid JSON';
      if (decoded is Map) summary += ' — object with ${decoded.length} keys';
      if (decoded is List) summary += ' — array with ${decoded.length} items';
      setState(() {
        _valid = true;
        _message = summary;
      });
    } on FormatException catch (e) {
      setState(() {
        _valid = false;
        _message = e.offset != null
            ? '${e.message}\nAt ${_position(text, e.offset!)}'
            : e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ToolPage(
      title: 'JSON Validator',
      children: [
        ToolInput(
          controller: _input,
          hint: 'Paste JSON…',
          minLines: 8,
          maxLines: 16,
          onChanged: (_) => _validate(),
        ),
        if (_valid != null)
          Card(
            color: _valid!
                ? Colors.green.withValues(alpha: 0.15)
                : scheme.errorContainer,
            child: ListTile(
              leading: Icon(
                _valid! ? Icons.check_circle : Icons.error,
                color: _valid! ? Colors.green : scheme.error,
              ),
              title: SelectableText(_message),
            ),
          ),
      ],
    );
  }
}
