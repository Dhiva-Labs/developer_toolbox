import 'dart:convert';

import 'package:flutter/material.dart';

import '../widgets/tool_widgets.dart';

// ---------------------------------------------------------------------------
// Case Converter
// ---------------------------------------------------------------------------

class CaseConverterTool extends StatefulWidget {
  const CaseConverterTool({super.key});

  @override
  State<CaseConverterTool> createState() => _CaseConverterToolState();
}

class _CaseConverterToolState extends State<CaseConverterTool> {
  final _input = TextEditingController();
  String _output = '';

  List<String> _words(String s) => s
      .replaceAllMapped(RegExp('([a-z0-9])([A-Z])'), (m) => '${m[1]} ${m[2]}')
      .split(RegExp(r'[\s_\-]+'))
      .where((w) => w.isNotEmpty)
      .toList();

  void _convert(String Function(String) fn) =>
      setState(() => _output = fn(_input.text));

  String _title(String s) => s
      .split('\n')
      .map((line) => line
          .split(' ')
          .map((w) => w.isEmpty
              ? w
              : w[0].toUpperCase() + w.substring(1).toLowerCase())
          .join(' '))
      .join('\n');

  String _sentence(String s) {
    final lower = s.toLowerCase();
    final buf = StringBuffer();
    var capitalize = true;
    for (final ch in lower.split('')) {
      buf.write(capitalize && RegExp('[a-z]').hasMatch(ch)
          ? ch.toUpperCase()
          : ch);
      if (RegExp('[a-z]').hasMatch(ch)) capitalize = false;
      if ('.!?\n'.contains(ch)) capitalize = true;
    }
    return buf.toString();
  }

  String _camel(String s) {
    final w = _words(s);
    if (w.isEmpty) return '';
    return w.first.toLowerCase() +
        w.skip(1).map((x) => x[0].toUpperCase() + x.substring(1).toLowerCase()).join();
  }

  String _pascal(String s) => _words(s)
      .map((x) => x[0].toUpperCase() + x.substring(1).toLowerCase())
      .join();

  String _snake(String s) =>
      _words(s).map((x) => x.toLowerCase()).join('_');

  String _kebab(String s) =>
      _words(s).map((x) => x.toLowerCase()).join('-');

  String _constant(String s) =>
      _words(s).map((x) => x.toUpperCase()).join('_');

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: 'Case Converter',
      children: [
        ToolInput(controller: _input, hint: 'Enter text to convert…'),
        ActionRow(children: [
          FilledButton.tonal(
              onPressed: () => _convert((s) => s.toUpperCase()),
              child: const Text('UPPERCASE')),
          FilledButton.tonal(
              onPressed: () => _convert((s) => s.toLowerCase()),
              child: const Text('lowercase')),
          FilledButton.tonal(
              onPressed: () => _convert(_title),
              child: const Text('Title Case')),
          FilledButton.tonal(
              onPressed: () => _convert(_sentence),
              child: const Text('Sentence case')),
          FilledButton.tonal(
              onPressed: () => _convert(_camel),
              child: const Text('camelCase')),
          FilledButton.tonal(
              onPressed: () => _convert(_pascal),
              child: const Text('PascalCase')),
          FilledButton.tonal(
              onPressed: () => _convert(_snake),
              child: const Text('snake_case')),
          FilledButton.tonal(
              onPressed: () => _convert(_kebab),
              child: const Text('kebab-case')),
          FilledButton.tonal(
              onPressed: () => _convert(_constant),
              child: const Text('CONSTANT_CASE')),
        ]),
        ToolOutput(text: _output),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Word & Character Counter
// ---------------------------------------------------------------------------

class WordCounterTool extends StatefulWidget {
  const WordCounterTool({super.key});

  @override
  State<WordCounterTool> createState() => _WordCounterToolState();
}

class _WordCounterToolState extends State<WordCounterTool> {
  final _input = TextEditingController();
  String _text = '';

  @override
  Widget build(BuildContext context) {
    final chars = _text.length;
    final charsNoSpace = _text.replaceAll(RegExp(r'\s'), '').length;
    final words =
        RegExp(r'\S+').allMatches(_text).length;
    final lines = _text.isEmpty ? 0 : _text.split('\n').length;
    final sentences = RegExp(r'[^.!?]+[.!?]+', dotAll: true)
        .allMatches(_text)
        .length;
    final paragraphs = _text
        .split(RegExp(r'\n\s*\n'))
        .where((p) => p.trim().isNotEmpty)
        .length;

    Widget stat(String label, int value) => Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              children: [
                Text('$value',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        );

    return ToolPage(
      title: 'Word & Character Counter',
      children: [
        ToolInput(
          controller: _input,
          hint: 'Type or paste text…',
          minLines: 8,
          maxLines: 16,
          onChanged: (v) => setState(() => _text = v),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            stat('Characters', chars),
            stat('No spaces', charsNoSpace),
            stat('Words', words),
            stat('Lines', lines),
            stat('Sentences', sentences),
            stat('Paragraphs', paragraphs),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Remove Duplicate Lines
// ---------------------------------------------------------------------------

class DuplicateLinesTool extends StatefulWidget {
  const DuplicateLinesTool({super.key});

  @override
  State<DuplicateLinesTool> createState() => _DuplicateLinesToolState();
}

class _DuplicateLinesToolState extends State<DuplicateLinesTool> {
  final _input = TextEditingController();
  String _output = '';
  bool _trim = true;
  bool _ignoreCase = false;
  bool _dropEmpty = false;
  int _removed = 0;

  void _run() {
    final seen = <String>{};
    final out = <String>[];
    var removed = 0;
    for (final raw in _input.text.split('\n')) {
      var key = _trim ? raw.trim() : raw;
      if (_ignoreCase) key = key.toLowerCase();
      if (_dropEmpty && key.isEmpty) {
        removed++;
        continue;
      }
      if (seen.add(key)) {
        out.add(raw);
      } else {
        removed++;
      }
    }
    setState(() {
      _output = out.join('\n');
      _removed = removed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: 'Remove Duplicate Lines',
      children: [
        ToolInput(controller: _input, hint: 'One entry per line…'),
        Wrap(
          spacing: 4,
          children: [
            FilterChip(
              label: const Text('Trim whitespace'),
              selected: _trim,
              onSelected: (v) => setState(() => _trim = v),
            ),
            FilterChip(
              label: const Text('Ignore case'),
              selected: _ignoreCase,
              onSelected: (v) => setState(() => _ignoreCase = v),
            ),
            FilterChip(
              label: const Text('Drop empty lines'),
              selected: _dropEmpty,
              onSelected: (v) => setState(() => _dropEmpty = v),
            ),
          ],
        ),
        FilledButton.icon(
          onPressed: _run,
          icon: const Icon(Icons.filter_alt),
          label: const Text('Remove duplicates'),
        ),
        ToolOutput(
          text: _output,
          label: _removed > 0 ? 'Output ($_removed removed)' : 'Output',
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Base64 Encode / Decode
// ---------------------------------------------------------------------------

class Base64Tool extends StatefulWidget {
  const Base64Tool({super.key});

  @override
  State<Base64Tool> createState() => _Base64ToolState();
}

class _Base64ToolState extends State<Base64Tool> {
  final _input = TextEditingController();
  String _output = '';
  bool _error = false;
  bool _urlSafe = false;

  void _encode() {
    final bytes = utf8.encode(_input.text);
    setState(() {
      _output = _urlSafe ? base64Url.encode(bytes) : base64.encode(bytes);
      _error = false;
    });
  }

  void _decode() {
    try {
      var s = _input.text.trim().replaceAll('\n', '');
      // Tolerate missing padding.
      s = s.padRight(s.length + (4 - s.length % 4) % 4, '=');
      final bytes =
          _urlSafe || s.contains('-') || s.contains('_')
              ? base64Url.decode(s.replaceAll('+', '-').replaceAll('/', '_'))
              : base64.decode(s);
      setState(() {
        _output = utf8.decode(bytes);
        _error = false;
      });
    } catch (e) {
      setState(() {
        _output = 'Invalid Base64 input: $e';
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: 'Base64 Encode / Decode',
      children: [
        ToolInput(controller: _input, hint: 'Text or Base64…'),
        Row(
          children: [
            FilledButton.icon(
              onPressed: _encode,
              icon: const Icon(Icons.arrow_downward),
              label: const Text('Encode'),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: _decode,
              icon: const Icon(Icons.arrow_upward),
              label: const Text('Decode'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('URL-safe alphabet'),
                value: _urlSafe,
                onChanged: (v) => setState(() => _urlSafe = v),
              ),
            ),
          ],
        ),
        ToolOutput(text: _output, isError: _error),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// URL Encode / Decode
// ---------------------------------------------------------------------------

class UrlEncodeTool extends StatefulWidget {
  const UrlEncodeTool({super.key});

  @override
  State<UrlEncodeTool> createState() => _UrlEncodeToolState();
}

class _UrlEncodeToolState extends State<UrlEncodeTool> {
  final _input = TextEditingController();
  String _output = '';
  bool _error = false;
  bool _fullComponent = true;

  void _encode() {
    setState(() {
      _output = _fullComponent
          ? Uri.encodeComponent(_input.text)
          : Uri.encodeFull(_input.text);
      _error = false;
    });
  }

  void _decode() {
    try {
      setState(() {
        _output = Uri.decodeComponent(_input.text);
        _error = false;
      });
    } catch (e) {
      setState(() {
        _output = 'Invalid percent-encoding: $e';
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: 'URL Encode / Decode',
      children: [
        ToolInput(controller: _input, hint: 'Text or URL…'),
        Row(
          children: [
            FilledButton.icon(
              onPressed: _encode,
              icon: const Icon(Icons.arrow_downward),
              label: const Text('Encode'),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: _decode,
              icon: const Icon(Icons.arrow_upward),
              label: const Text('Decode'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Encode all reserved characters'),
                subtitle: const Text('Off = keep / ? & = : intact'),
                value: _fullComponent,
                onChanged: (v) => setState(() => _fullComponent = v),
              ),
            ),
          ],
        ),
        ToolOutput(text: _output, isError: _error),
      ],
    );
  }
}
