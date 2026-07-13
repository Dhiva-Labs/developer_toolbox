import 'package:flutter/material.dart';

enum ToolCategory {
  text('Text Tools', Icons.text_fields),
  json('JSON Tools', Icons.data_object),
  security('Security', Icons.lock_outline),
  web('Web Tools', Icons.language),
  design('Design Tools', Icons.palette_outlined),
  utilities('Utilities', Icons.handyman_outlined);

  const ToolCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

class Tool {
  const Tool({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.builder,
    this.keywords = const [],
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final ToolCategory category;
  final WidgetBuilder builder;

  /// Extra search terms besides name/description/category.
  final List<String> keywords;

  bool matches(String query) {
    final q = query.toLowerCase();
    return name.toLowerCase().contains(q) ||
        description.toLowerCase().contains(q) ||
        category.label.toLowerCase().contains(q) ||
        keywords.any((k) => k.toLowerCase().contains(q));
  }
}
