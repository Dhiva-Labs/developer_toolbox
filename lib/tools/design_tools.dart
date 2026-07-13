import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../widgets/tool_widgets.dart';

String _hex(Color c, {bool withAlpha = false}) {
  final argb = c.toARGB32();
  final hex = argb.toRadixString(16).padLeft(8, '0').toUpperCase();
  return '#${withAlpha ? hex : hex.substring(2)}';
}

(int, int, int) _rgb(Color c) {
  final argb = c.toARGB32();
  return ((argb >> 16) & 0xFF, (argb >> 8) & 0xFF, argb & 0xFF);
}

// ---------------------------------------------------------------------------
// Color Picker
// ---------------------------------------------------------------------------

class ColorPickerTool extends StatefulWidget {
  const ColorPickerTool({super.key});

  @override
  State<ColorPickerTool> createState() => _ColorPickerToolState();
}

class _ColorPickerToolState extends State<ColorPickerTool> {
  Color _color = const Color(0xFF3D5AFE);

  @override
  Widget build(BuildContext context) {
    final (r, g, b) = _rgb(_color);
    final hsl = HSLColor.fromColor(_color);
    final outputs = <(String, String)>[
      ('HEX', _hex(_color)),
      ('RGB', 'rgb($r, $g, $b)'),
      (
        'HSL',
        'hsl(${hsl.hue.round()}, ${(hsl.saturation * 100).round()}%, '
            '${(hsl.lightness * 100).round()}%)'
      ),
      ('Flutter', 'Color(0xFF${_hex(_color).substring(1)})'),
    ];

    return ToolPage(
      title: 'Color Picker',
      children: [
        Center(
          child: ColorPicker(
            pickerColor: _color,
            onColorChanged: (c) => setState(() => _color = c),
            pickerAreaHeightPercent: 0.6,
            enableAlpha: false,
            hexInputBar: true,
            paletteType: PaletteType.hsvWithHue,
          ),
        ),
        Card(
          child: Column(
            children: [
              for (final (label, value) in outputs)
                ListTile(
                  dense: true,
                  leading: SizedBox(width: 64, child: Text(label)),
                  title: SelectableText(value,
                      style: const TextStyle(fontFamily: 'monospace')),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () => copyToClipboard(context, value),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// HEX <-> RGB Converter
// ---------------------------------------------------------------------------

class HexRgbTool extends StatefulWidget {
  const HexRgbTool({super.key});

  @override
  State<HexRgbTool> createState() => _HexRgbToolState();
}

class _HexRgbToolState extends State<HexRgbTool> {
  final _hexCtrl = TextEditingController(text: '3D5AFE');
  final _rCtrl = TextEditingController(text: '61');
  final _gCtrl = TextEditingController(text: '90');
  final _bCtrl = TextEditingController(text: '254');
  Color? _color = const Color(0xFF3D5AFE);
  String? _error;

  void _fromHex(String value) {
    var v = value.trim().replaceFirst('#', '');
    if (v.length == 3) v = v.split('').map((c) => '$c$c').join();
    setState(() {
      if (v.length != 6 || int.tryParse(v, radix: 16) == null) {
        _error = 'Enter a 3 or 6 digit hex color';
        _color = null;
        return;
      }
      _error = null;
      _color = Color(0xFF000000 | int.parse(v, radix: 16));
      final (r, g, b) = _rgb(_color!);
      _rCtrl.text = '$r';
      _gCtrl.text = '$g';
      _bCtrl.text = '$b';
    });
  }

  void _fromRgb() {
    setState(() {
      final r = int.tryParse(_rCtrl.text);
      final g = int.tryParse(_gCtrl.text);
      final b = int.tryParse(_bCtrl.text);
      if ([r, g, b].any((v) => v == null || v < 0 || v > 255)) {
        _error = 'R, G and B must be 0–255';
        _color = null;
        return;
      }
      _error = null;
      _color = Color.fromARGB(255, r!, g!, b!);
      _hexCtrl.text = _hex(_color!).substring(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget rgbField(String label, TextEditingController ctrl) => Expanded(
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            onChanged: (_) => _fromRgb(),
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
        );

    return ToolPage(
      title: 'HEX ↔ RGB Converter',
      children: [
        TextField(
          controller: _hexCtrl,
          onChanged: _fromHex,
          style: const TextStyle(fontFamily: 'monospace'),
          decoration: const InputDecoration(
            labelText: 'HEX',
            prefixText: '# ',
            border: OutlineInputBorder(),
          ),
        ),
        Row(
          children: [
            rgbField('R', _rCtrl),
            const SizedBox(width: 8),
            rgbField('G', _gCtrl),
            const SizedBox(width: 8),
            rgbField('B', _bCtrl),
          ],
        ),
        if (_error != null)
          Text(_error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
        if (_color != null) ...[
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: _color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant),
            ),
          ),
          Builder(builder: (context) {
            final (r, g, b) = _rgb(_color!);
            return ActionRow(children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.copy, size: 16),
                label: Text(_hex(_color!)),
                onPressed: () => copyToClipboard(context, _hex(_color!)),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.copy, size: 16),
                label: Text('rgb($r, $g, $b)'),
                onPressed: () =>
                    copyToClipboard(context, 'rgb($r, $g, $b)'),
              ),
            ]);
          }),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// CSS Gradient Generator
// ---------------------------------------------------------------------------

class GradientGeneratorTool extends StatefulWidget {
  const GradientGeneratorTool({super.key});

  @override
  State<GradientGeneratorTool> createState() => _GradientGeneratorToolState();
}

class _GradientGeneratorToolState extends State<GradientGeneratorTool> {
  final _colors = <Color>[const Color(0xFF3D5AFE), const Color(0xFFFF4081)];
  double _angle = 90;
  bool _radial = false;

  Future<void> _editColor(int index) async {
    var picked = _colors[index];
    final result = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: picked,
            onColorChanged: (c) => picked = c,
            enableAlpha: false,
            hexInputBar: true,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, picked),
              child: const Text('Select')),
        ],
      ),
    );
    if (result != null) setState(() => _colors[index] = result);
  }

  String get _css {
    final stops = <String>[];
    for (var i = 0; i < _colors.length; i++) {
      final pct = _colors.length == 1
          ? 0
          : (i * 100 / (_colors.length - 1)).round();
      stops.add('${_hex(_colors[i]).toLowerCase()} $pct%');
    }
    return _radial
        ? 'background: radial-gradient(circle, ${stops.join(', ')});'
        : 'background: linear-gradient(${_angle.round()}deg, ${stops.join(', ')});';
  }

  Gradient get _flutterGradient {
    if (_radial) return RadialGradient(colors: _colors);
    // CSS angle: 0deg points up, clockwise. Convert to Flutter alignment.
    final rad = (_angle - 90) * math.pi / 180;
    return LinearGradient(
      begin: Alignment(-math.cos(rad), -math.sin(rad)),
      end: Alignment(math.cos(rad), math.sin(rad)),
      colors: _colors,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: 'CSS Gradient Generator',
      children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
            gradient: _flutterGradient,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (var i = 0; i < _colors.length; i++)
              InputChip(
                avatar: CircleAvatar(backgroundColor: _colors[i]),
                label: Text(_hex(_colors[i])),
                onPressed: () => _editColor(i),
                onDeleted:
                    _colors.length > 2 ? () => setState(() => _colors.removeAt(i)) : null,
              ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: const Text('Add stop'),
              onPressed: _colors.length >= 6
                  ? null
                  : () => setState(() => _colors.add(Colors.teal)),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Radial gradient'),
          value: _radial,
          onChanged: (v) => setState(() => _radial = v),
        ),
        if (!_radial)
          Row(
            children: [
              const Text('Angle:'),
              Expanded(
                child: Slider(
                  value: _angle,
                  min: 0,
                  max: 360,
                  divisions: 72,
                  label: '${_angle.round()}°',
                  onChanged: (v) => setState(() => _angle = v),
                ),
              ),
              SizedBox(width: 48, child: Text('${_angle.round()}°')),
            ],
          ),
        ToolOutput(text: _css, label: 'CSS'),
      ],
    );
  }
}
