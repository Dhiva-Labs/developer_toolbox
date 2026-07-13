import 'package:flutter/material.dart';

import '../tools/design_tools.dart';
import '../tools/json_tools.dart';
import '../tools/security_tools.dart';
import '../tools/text_tools.dart';
import '../tools/utility_tools.dart';
import '../tools/web_tools.dart';
import 'tool.dart';

/// All tools in the app. To add a tool: build its widget and append an entry.
final List<Tool> allTools = [
  // Text
  Tool(
    id: 'case-converter',
    name: 'Case Converter',
    description: 'UPPER, lower, camelCase, snake_case and more',
    icon: Icons.text_rotation_none,
    category: ToolCategory.text,
    keywords: const ['uppercase', 'lowercase', 'camel', 'snake', 'kebab'],
    builder: (_) => const CaseConverterTool(),
  ),
  Tool(
    id: 'word-counter',
    name: 'Word & Character Counter',
    description: 'Live counts of characters, words, lines and sentences',
    icon: Icons.numbers,
    category: ToolCategory.text,
    keywords: const ['count', 'length', 'statistics'],
    builder: (_) => const WordCounterTool(),
  ),
  Tool(
    id: 'dedupe-lines',
    name: 'Remove Duplicate Lines',
    description: 'Deduplicate a list, with trim and case options',
    icon: Icons.playlist_remove,
    category: ToolCategory.text,
    keywords: const ['unique', 'dedupe', 'distinct'],
    builder: (_) => const DuplicateLinesTool(),
  ),
  Tool(
    id: 'base64',
    name: 'Base64 Encode / Decode',
    description: 'Convert text to and from Base64',
    icon: Icons.transform,
    category: ToolCategory.text,
    keywords: const ['b64', 'encode', 'decode'],
    builder: (_) => const Base64Tool(),
  ),
  Tool(
    id: 'url-encode',
    name: 'URL Encode / Decode',
    description: 'Percent-encode and decode URL text',
    icon: Icons.link,
    category: ToolCategory.text,
    keywords: const ['percent', 'escape', 'uri'],
    builder: (_) => const UrlEncodeTool(),
  ),

  // JSON
  Tool(
    id: 'json-format',
    name: 'JSON Formatter',
    description: 'Pretty-print JSON with configurable indentation',
    icon: Icons.format_align_left,
    category: ToolCategory.json,
    keywords: const ['pretty', 'beautify', 'indent'],
    builder: (_) => const JsonFormatterTool(),
  ),
  Tool(
    id: 'json-minify',
    name: 'JSON Minifier',
    description: 'Strip whitespace to shrink JSON',
    icon: Icons.compress,
    category: ToolCategory.json,
    keywords: const ['compact', 'compress'],
    builder: (_) => const JsonMinifierTool(),
  ),
  Tool(
    id: 'json-validate',
    name: 'JSON Validator',
    description: 'Check syntax with line and column error reporting',
    icon: Icons.rule,
    category: ToolCategory.json,
    keywords: const ['lint', 'check', 'syntax'],
    builder: (_) => const JsonValidatorTool(),
  ),

  // Security
  Tool(
    id: 'jwt-decoder',
    name: 'JWT Decoder',
    description: 'Inspect header, payload and expiry of a JWT',
    icon: Icons.key,
    category: ToolCategory.security,
    keywords: const ['token', 'auth', 'bearer'],
    builder: (_) => const JwtDecoderTool(),
  ),
  Tool(
    id: 'uuid',
    name: 'UUID Generator',
    description: 'Generate v1, v4 or v7 UUIDs in bulk',
    icon: Icons.fingerprint,
    category: ToolCategory.security,
    keywords: const ['guid', 'identifier'],
    builder: (_) => const UuidGeneratorTool(),
  ),
  Tool(
    id: 'password',
    name: 'Password Generator',
    description: 'Random passwords with a strength meter',
    icon: Icons.password,
    category: ToolCategory.security,
    keywords: const ['random', 'secure', 'secret'],
    builder: (_) => const PasswordGeneratorTool(),
  ),
  Tool(
    id: 'hash',
    name: 'Hash Generator',
    description: 'MD5, SHA-1, SHA-256 and SHA-512 digests',
    icon: Icons.tag,
    category: ToolCategory.security,
    keywords: const ['md5', 'sha256', 'checksum', 'digest'],
    builder: (_) => const HashGeneratorTool(),
  ),

  // Web
  Tool(
    id: 'regex',
    name: 'Regex Tester',
    description: 'Live matching with highlights and capture groups',
    icon: Icons.manage_search,
    category: ToolCategory.web,
    keywords: const ['regular expression', 'pattern', 'match'],
    builder: (_) => const RegexTesterTool(),
  ),
  Tool(
    id: 'http-status',
    name: 'HTTP Status Codes',
    description: 'Searchable reference from 100 to 504',
    icon: Icons.dns,
    category: ToolCategory.web,
    keywords: const ['404', '500', 'rest', 'response'],
    builder: (_) => const HttpStatusTool(),
  ),
  Tool(
    id: 'url-parser',
    name: 'URL Parser',
    description: 'Break a URL into scheme, host, path and query',
    icon: Icons.account_tree_outlined,
    category: ToolCategory.web,
    keywords: const ['uri', 'query', 'parameters'],
    builder: (_) => const UrlParserTool(),
  ),

  // Design
  Tool(
    id: 'color-picker',
    name: 'Color Picker',
    description: 'Pick a color and copy HEX, RGB, HSL or Flutter code',
    icon: Icons.colorize,
    category: ToolCategory.design,
    keywords: const ['colour', 'palette', 'hsl'],
    builder: (_) => const ColorPickerTool(),
  ),
  Tool(
    id: 'hex-rgb',
    name: 'HEX ↔ RGB Converter',
    description: 'Convert between hex codes and RGB values',
    icon: Icons.swap_horiz,
    category: ToolCategory.design,
    keywords: const ['colour', 'color', 'convert'],
    builder: (_) => const HexRgbTool(),
  ),
  Tool(
    id: 'gradient',
    name: 'CSS Gradient Generator',
    description: 'Build linear or radial gradients with live preview',
    icon: Icons.gradient,
    category: ToolCategory.design,
    keywords: const ['background', 'linear-gradient', 'css'],
    builder: (_) => const GradientGeneratorTool(),
  ),

  // Utilities
  Tool(
    id: 'qr-generate',
    name: 'QR Code Generator',
    description: 'Turn any text or URL into a QR code',
    icon: Icons.qr_code_2,
    category: ToolCategory.utilities,
    keywords: const ['barcode'],
    builder: (_) => const QrGeneratorTool(),
  ),
  Tool(
    id: 'qr-scan',
    name: 'QR Code Scanner',
    description: 'Scan QR codes with the camera (Android)',
    icon: Icons.qr_code_scanner,
    category: ToolCategory.utilities,
    keywords: const ['barcode', 'camera', 'read'],
    builder: (_) => const QrScannerTool(),
  ),
  Tool(
    id: 'timestamp',
    name: 'Unix Timestamp Converter',
    description: 'Convert between epoch time and readable dates',
    icon: Icons.schedule,
    category: ToolCategory.utilities,
    keywords: const ['epoch', 'date', 'time', 'unix'],
    builder: (_) => const TimestampTool(),
  ),
];
