# Developer Toolbox

A clean, offline-first collection of developer tools built with Flutter.
One codebase, runs on **Windows, Linux, and Android**.

## Tools

| Category | Tools |
|---|---|
| Text | Case Converter, Word & Character Counter, Remove Duplicate Lines, Base64 Encode/Decode, URL Encode/Decode |
| JSON | Formatter, Minifier, Validator (with line/column errors) |
| Security | JWT Decoder, UUID Generator (v1/v4/v7), Password Generator, Hash Generator (MD5/SHA-1/SHA-256/SHA-512) |
| Web | Regex Tester (live highlight + groups), HTTP Status Code Reference, URL Parser |
| Design | Color Picker, HEX ↔ RGB Converter, CSS Gradient Generator |
| Utilities | QR Code Generator, QR Code Scanner (Android), Unix Timestamp Converter |

## Features

- Material 3 with light / dark / system theme (persisted)
- Search bar and category filters to find tools quickly
- Star tools as favorites (persisted with Hive)
- Responsive: grid scales from 1 column on phones to 4 on wide desktops

## Architecture

Tools are registered in [`lib/core/registry.dart`](lib/core/registry.dart).
Adding a tool is two steps:

1. Build a widget for it (see `lib/tools/` — use the shared `ToolPage`,
   `ToolInput`, and `ToolOutput` widgets from `lib/widgets/tool_widgets.dart`).
2. Append a `Tool(...)` entry to `allTools` with an id, name, description,
   icon, category, and search keywords.

State management is Riverpod; persistence (theme + favorites) is Hive.

## Building

```sh
flutter pub get
flutter run                  # current desktop platform
flutter build linux --release
flutter build windows --release   # on Windows
flutter build apk --release
```

QR scanning uses the device camera and is available on Android only;
desktop builds show a friendly notice instead.
# developer_toolbox
