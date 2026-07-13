import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

Box get _settings => Hive.box('settings');

// ---------------------------------------------------------------------------
// Theme
// ---------------------------------------------------------------------------

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final stored = _settings.get('themeMode', defaultValue: 'system') as String;
    return ThemeMode.values.firstWhere(
      (m) => m.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  void cycle() {
    final next = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    state = next;
    _settings.put('themeMode', next.name);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

// ---------------------------------------------------------------------------
// Favorites
// ---------------------------------------------------------------------------

class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final stored =
        (_settings.get('favorites', defaultValue: <dynamic>[]) as List)
            .cast<String>();
    return stored.toSet();
  }

  void toggle(String toolId) {
    final next = {...state};
    if (!next.remove(toolId)) next.add(toolId);
    state = next;
    _settings.put('favorites', next.toList());
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

// ---------------------------------------------------------------------------
// Home screen filters
// ---------------------------------------------------------------------------

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);
