import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../widgets/tool_widgets.dart';

// ---------------------------------------------------------------------------
// JWT Decoder
// ---------------------------------------------------------------------------

class JwtDecoderTool extends StatefulWidget {
  const JwtDecoderTool({super.key});

  @override
  State<JwtDecoderTool> createState() => _JwtDecoderToolState();
}

class _JwtDecoderToolState extends State<JwtDecoderTool> {
  final _input = TextEditingController();
  String _header = '';
  String _payload = '';
  String _meta = '';
  bool _error = false;

  static String _decodePart(String part) {
    final normalized =
        part.padRight(part.length + (4 - part.length % 4) % 4, '=');
    final decoded = utf8.decode(base64Url.decode(normalized));
    return const JsonEncoder.withIndent('  ').convert(jsonDecode(decoded));
  }

  void _decode() {
    final token = _input.text.trim();
    final parts = token.split('.');
    if (parts.length != 3) {
      setState(() {
        _header = 'A JWT must have three dot-separated parts '
            '(header.payload.signature); got ${parts.length}.';
        _payload = '';
        _meta = '';
        _error = true;
      });
      return;
    }
    try {
      final header = _decodePart(parts[0]);
      final payload = _decodePart(parts[1]);
      final claims = jsonDecode(
          utf8.decode(base64Url.decode(parts[1].padRight(
              parts[1].length + (4 - parts[1].length % 4) % 4, '=')))) as Map;

      final meta = <String>[];
      for (final claim in ['iat', 'nbf', 'exp']) {
        final v = claims[claim];
        if (v is num) {
          final dt =
              DateTime.fromMillisecondsSinceEpoch(v.toInt() * 1000).toLocal();
          var line = '$claim: $dt';
          if (claim == 'exp') {
            line += DateTime.now().isAfter(dt) ? '  ⚠ EXPIRED' : '  ✓ valid';
          }
          meta.add(line);
        }
      }
      setState(() {
        _header = header;
        _payload = payload;
        _meta = meta.join('\n');
        _error = false;
      });
    } catch (e) {
      setState(() {
        _header = 'Failed to decode: $e';
        _payload = '';
        _meta = '';
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: 'JWT Decoder',
      children: [
        ToolInput(
            controller: _input, hint: 'Paste a JWT (xxx.yyy.zzz)…', minLines: 3),
        FilledButton.icon(
          onPressed: _decode,
          icon: const Icon(Icons.key),
          label: const Text('Decode'),
        ),
        ToolOutput(text: _header, label: 'Header', isError: _error),
        if (!_error) ToolOutput(text: _payload, label: 'Payload'),
        if (_meta.isNotEmpty) ToolOutput(text: _meta, label: 'Timestamps'),
        const Card(
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Signature is not verified'),
            subtitle: Text(
                'Decoding only reads the token contents. It does not check '
                'that the signature is valid.'),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// UUID Generator
// ---------------------------------------------------------------------------

class UuidGeneratorTool extends StatefulWidget {
  const UuidGeneratorTool({super.key});

  @override
  State<UuidGeneratorTool> createState() => _UuidGeneratorToolState();
}

class _UuidGeneratorToolState extends State<UuidGeneratorTool> {
  static const _uuid = Uuid();
  String _version = 'v4';
  double _count = 1;
  bool _uppercase = false;
  bool _noDashes = false;
  String _output = '';

  void _generate() {
    final out = List.generate(_count.round(), (_) {
      var id = switch (_version) {
        'v1' => _uuid.v1(),
        'v7' => _uuid.v7(),
        _ => _uuid.v4(),
      };
      if (_noDashes) id = id.replaceAll('-', '');
      if (_uppercase) id = id.toUpperCase();
      return id;
    });
    setState(() => _output = out.join('\n'));
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: 'UUID Generator',
      children: [
        Row(
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'v1', label: Text('v1 (time)')),
                ButtonSegment(value: 'v4', label: Text('v4 (random)')),
                ButtonSegment(value: 'v7', label: Text('v7 (sortable)')),
              ],
              selected: {_version},
              onSelectionChanged: (s) => setState(() => _version = s.first),
            ),
          ],
        ),
        Row(
          children: [
            const Text('Count:'),
            Expanded(
              child: Slider(
                value: _count,
                min: 1,
                max: 50,
                divisions: 49,
                label: '${_count.round()}',
                onChanged: (v) => setState(() => _count = v),
              ),
            ),
            SizedBox(width: 32, child: Text('${_count.round()}')),
          ],
        ),
        Wrap(
          spacing: 4,
          children: [
            FilterChip(
              label: const Text('Uppercase'),
              selected: _uppercase,
              onSelected: (v) => setState(() => _uppercase = v),
            ),
            FilterChip(
              label: const Text('Remove dashes'),
              selected: _noDashes,
              onSelected: (v) => setState(() => _noDashes = v),
            ),
          ],
        ),
        FilledButton.icon(
          onPressed: _generate,
          icon: const Icon(Icons.refresh),
          label: const Text('Generate'),
        ),
        ToolOutput(text: _output, maxHeight: 400),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Password Generator
// ---------------------------------------------------------------------------

class PasswordGeneratorTool extends StatefulWidget {
  const PasswordGeneratorTool({super.key});

  @override
  State<PasswordGeneratorTool> createState() => _PasswordGeneratorToolState();
}

class _PasswordGeneratorToolState extends State<PasswordGeneratorTool> {
  double _length = 16;
  bool _upper = true;
  bool _lower = true;
  bool _digits = true;
  bool _symbols = true;
  bool _excludeAmbiguous = false;
  String _output = '';

  static const _ambiguous = 'Il1O0o';

  void _generate() {
    var pool = '';
    final required = <String>[];
    String filtered(String s) => _excludeAmbiguous
        ? s.split('').where((c) => !_ambiguous.contains(c)).join()
        : s;

    if (_upper) {
      final set = filtered('ABCDEFGHIJKLMNOPQRSTUVWXYZ');
      pool += set;
      required.add(set);
    }
    if (_lower) {
      final set = filtered('abcdefghijklmnopqrstuvwxyz');
      pool += set;
      required.add(set);
    }
    if (_digits) {
      final set = filtered('0123456789');
      pool += set;
      required.add(set);
    }
    if (_symbols) {
      const set = '!@#\$%^&*()-_=+[]{};:,.<>?';
      pool += set;
      required.add(set);
    }
    if (pool.isEmpty) {
      setState(() => _output = 'Select at least one character set.');
      return;
    }

    final rng = Random.secure();
    final len = _length.round();
    final chars = List.generate(
        len, (_) => pool[rng.nextInt(pool.length)]);
    // Guarantee at least one char from every selected set.
    for (var i = 0; i < required.length && i < len; i++) {
      chars[i] = required[i][rng.nextInt(required[i].length)];
    }
    chars.shuffle(rng);
    setState(() => _output = chars.join());
  }

  double get _entropyBits {
    var poolSize = 0;
    if (_upper) poolSize += _excludeAmbiguous ? 23 : 26;
    if (_lower) poolSize += _excludeAmbiguous ? 23 : 26;
    if (_digits) poolSize += _excludeAmbiguous ? 8 : 10;
    if (_symbols) poolSize += 25;
    if (poolSize == 0) return 0;
    return _length * log(poolSize) / ln2;
  }

  @override
  Widget build(BuildContext context) {
    final bits = _entropyBits;
    final (label, color) = switch (bits) {
      < 45 => ('Weak', Colors.red),
      < 70 => ('Fair', Colors.orange),
      < 100 => ('Strong', Colors.lightGreen),
      _ => ('Very strong', Colors.green),
    };

    return ToolPage(
      title: 'Password Generator',
      children: [
        Row(
          children: [
            const Text('Length:'),
            Expanded(
              child: Slider(
                value: _length,
                min: 6,
                max: 64,
                divisions: 58,
                label: '${_length.round()}',
                onChanged: (v) => setState(() => _length = v),
              ),
            ),
            SizedBox(width: 32, child: Text('${_length.round()}')),
          ],
        ),
        Wrap(
          spacing: 4,
          children: [
            FilterChip(
                label: const Text('A–Z'),
                selected: _upper,
                onSelected: (v) => setState(() => _upper = v)),
            FilterChip(
                label: const Text('a–z'),
                selected: _lower,
                onSelected: (v) => setState(() => _lower = v)),
            FilterChip(
                label: const Text('0–9'),
                selected: _digits,
                onSelected: (v) => setState(() => _digits = v)),
            FilterChip(
                label: const Text('!@#\$'),
                selected: _symbols,
                onSelected: (v) => setState(() => _symbols = v)),
            FilterChip(
                label: const Text('Exclude ambiguous (Il1O0o)'),
                selected: _excludeAmbiguous,
                onSelected: (v) => setState(() => _excludeAmbiguous = v)),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: (bits / 128).clamp(0, 1),
                color: color,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Text('$label (${bits.round()} bits)'),
          ],
        ),
        FilledButton.icon(
          onPressed: _generate,
          icon: const Icon(Icons.password),
          label: const Text('Generate'),
        ),
        ToolOutput(text: _output),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Hash Generator
// ---------------------------------------------------------------------------

class HashGeneratorTool extends StatefulWidget {
  const HashGeneratorTool({super.key});

  @override
  State<HashGeneratorTool> createState() => _HashGeneratorToolState();
}

class _HashGeneratorToolState extends State<HashGeneratorTool> {
  final _input = TextEditingController();
  String _text = '';

  @override
  Widget build(BuildContext context) {
    final bytes = utf8.encode(_text);
    final hashes = _text.isEmpty
        ? <String, String>{}
        : {
            'MD5': md5.convert(bytes).toString(),
            'SHA-1': sha1.convert(bytes).toString(),
            'SHA-256': sha256.convert(bytes).toString(),
            'SHA-512': sha512.convert(bytes).toString(),
          };

    return ToolPage(
      title: 'Hash Generator',
      children: [
        ToolInput(
          controller: _input,
          hint: 'Text to hash…',
          onChanged: (v) => setState(() => _text = v),
        ),
        for (final entry in hashes.entries)
          ToolOutput(text: entry.value, label: entry.key, maxHeight: 120),
        if (_text.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Hashes update live as you type'),
              subtitle: Text('MD5, SHA-1, SHA-256 and SHA-512 of the '
                  'UTF-8 bytes of the input.'),
            ),
          ),
      ],
    );
  }
}
