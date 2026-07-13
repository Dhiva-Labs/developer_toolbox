import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../widgets/tool_widgets.dart';

// ---------------------------------------------------------------------------
// QR Code Generator
// ---------------------------------------------------------------------------

class QrGeneratorTool extends StatefulWidget {
  const QrGeneratorTool({super.key});

  @override
  State<QrGeneratorTool> createState() => _QrGeneratorToolState();
}

class _QrGeneratorToolState extends State<QrGeneratorTool> {
  final _input = TextEditingController();
  String _data = '';
  double _size = 240;

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: 'QR Code Generator',
      children: [
        ToolInput(
          controller: _input,
          label: 'Content',
          hint: 'URL, text, WiFi config…',
          minLines: 2,
          maxLines: 6,
          onChanged: (v) => setState(() => _data = v),
        ),
        Row(
          children: [
            const Text('Size:'),
            Expanded(
              child: Slider(
                value: _size,
                min: 120,
                max: 400,
                divisions: 14,
                label: '${_size.round()} px',
                onChanged: (v) => setState(() => _size = v),
              ),
            ),
          ],
        ),
        if (_data.isNotEmpty)
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: _data,
                version: QrVersions.auto,
                size: _size,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            ),
          )
        else
          const Card(
            child: ListTile(
              leading: Icon(Icons.qr_code_2),
              title: Text('Enter content above'),
              subtitle: Text('The QR code renders live as you type.'),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// QR Code Scanner
// ---------------------------------------------------------------------------

class QrScannerTool extends StatefulWidget {
  const QrScannerTool({super.key});

  @override
  State<QrScannerTool> createState() => _QrScannerToolState();
}

class _QrScannerToolState extends State<QrScannerTool> {
  String _result = '';
  bool _scanning = true;

  bool get _supported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  @override
  Widget build(BuildContext context) {
    if (!_supported) {
      return ToolPage(
        title: 'QR Code Scanner',
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.videocam_off,
                  color: Theme.of(context).colorScheme.error),
              title: const Text('Camera scanning is not available on this platform'),
              subtitle: const Text(
                  'QR scanning uses the device camera and is supported on '
                  'Android. On desktop, use your phone to scan.'),
            ),
          ),
        ],
      );
    }

    return ToolPage(
      title: 'QR Code Scanner',
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 360,
            child: _scanning
                ? MobileScanner(
                    onDetect: (capture) {
                      final value = capture.barcodes
                          .map((b) => b.rawValue)
                          .whereType<String>()
                          .firstOrNull;
                      if (value != null && value != _result) {
                        setState(() {
                          _result = value;
                          _scanning = false;
                        });
                      }
                    },
                  )
                : Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: FilledButton.icon(
                        onPressed: () => setState(() {
                          _result = '';
                          _scanning = true;
                        }),
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Scan again'),
                      ),
                    ),
                  ),
          ),
        ),
        ToolOutput(text: _result, label: 'Scanned content'),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Unix Timestamp Converter
// ---------------------------------------------------------------------------

class TimestampTool extends StatefulWidget {
  const TimestampTool({super.key});

  @override
  State<TimestampTool> createState() => _TimestampToolState();
}

class _TimestampToolState extends State<TimestampTool> {
  final _tsCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  String _tsResult = '';
  String _dateResult = '';
  bool _tsError = false;
  bool _dateError = false;

  String _fmt(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}:'
      '${dt.second.toString().padLeft(2, '0')}';

  void _fromTimestamp() {
    final raw = _tsCtrl.text.trim();
    final n = int.tryParse(raw);
    if (n == null) {
      setState(() {
        _tsResult = 'Enter a numeric Unix timestamp';
        _tsError = true;
      });
      return;
    }
    // Heuristic: 13+ digit values are milliseconds.
    final ms = raw.length >= 13 ? n : n * 1000;
    final utc = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
    final local = utc.toLocal();
    final unit = raw.length >= 13 ? 'milliseconds' : 'seconds';
    setState(() {
      _tsResult = 'Interpreted as: $unit\n'
          'Local: ${_fmt(local)}\n'
          'UTC:   ${_fmt(utc)}\n'
          'ISO:   ${utc.toIso8601String()}';
      _tsError = false;
    });
  }

  void _fromDate() {
    final parsed = DateTime.tryParse(_dateCtrl.text.trim());
    if (parsed == null) {
      setState(() {
        _dateResult =
            'Could not parse. Use e.g. 2026-07-13 14:30:00 or ISO 8601.';
        _dateError = true;
      });
      return;
    }
    final seconds = parsed.millisecondsSinceEpoch ~/ 1000;
    setState(() {
      _dateResult = 'Seconds:      $seconds\n'
          'Milliseconds: ${parsed.millisecondsSinceEpoch}';
      _dateError = false;
    });
  }

  void _now() {
    final now = DateTime.now();
    _tsCtrl.text = '${now.millisecondsSinceEpoch ~/ 1000}';
    _fromTimestamp();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: 'Unix Timestamp Converter',
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(
                'Now: ${DateTime.now().millisecondsSinceEpoch ~/ 1000}',
                style: const TextStyle(fontFamily: 'monospace')),
            trailing: TextButton(
                onPressed: _now, child: const Text('Use current time')),
          ),
        ),
        Text('Timestamp → Date',
            style: Theme.of(context).textTheme.titleMedium),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tsCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: const InputDecoration(
                  labelText: 'Unix timestamp (s or ms)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => _fromTimestamp(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
                onPressed: _fromTimestamp, child: const Text('Convert')),
          ],
        ),
        ToolOutput(text: _tsResult, isError: _tsError, label: 'Date'),
        const Divider(),
        Text('Date → Timestamp',
            style: Theme.of(context).textTheme.titleMedium),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _dateCtrl,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: const InputDecoration(
                  labelText: 'Date (e.g. 2026-07-13 14:30:00)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => _fromDate(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(onPressed: _fromDate, child: const Text('Convert')),
          ],
        ),
        ToolOutput(text: _dateResult, isError: _dateError, label: 'Timestamp'),
      ],
    );
  }
}
