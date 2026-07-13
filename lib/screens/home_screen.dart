import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../core/registry.dart';
import '../core/tool.dart';

/// Selected category filter; null = All.
class _CategoryFilterNotifier extends Notifier<ToolCategory?> {
  @override
  ToolCategory? build() => null;

  void set(ToolCategory? value) => state = value;
}

final _categoryFilterProvider =
    NotifierProvider<_CategoryFilterNotifier, ToolCategory?>(
        _CategoryFilterNotifier.new);

class _FavoritesOnlyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final _favoritesOnlyProvider =
    NotifierProvider<_FavoritesOnlyNotifier, bool>(_FavoritesOnlyNotifier.new);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final category = ref.watch(_categoryFilterProvider);
    final favoritesOnly = ref.watch(_favoritesOnlyProvider);
    final favorites = ref.watch(favoritesProvider);
    final themeMode = ref.watch(themeModeProvider);

    var tools = allTools.where((t) => query.isEmpty || t.matches(query));
    if (favoritesOnly) {
      tools = tools.where((t) => favorites.contains(t.id));
    } else if (category != null) {
      tools = tools.where((t) => t.category == category);
    }
    final visible = tools.toList();

    final themeIcon = switch (themeMode) {
      ThemeMode.system => Icons.brightness_auto,
      ThemeMode.light => Icons.light_mode,
      ThemeMode.dark => Icons.dark_mode,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Toolbox'),
        actions: [
          IconButton(
            tooltip: 'Theme: ${themeMode.name}',
            icon: Icon(themeIcon),
            onPressed: () =>
                ref.read(themeModeProvider.notifier).cycle(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SearchBar(
              hintText: 'Search tools…',
              leading: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.search),
              ),
              elevation: const WidgetStatePropertyAll(1),
              onChanged: (v) =>
                  ref.read(searchQueryProvider.notifier).set(v),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                FilterChip(
                  avatar: Icon(
                    Icons.star,
                    size: 18,
                    color: favoritesOnly ? null : Colors.amber,
                  ),
                  label: const Text('Favorites'),
                  selected: favoritesOnly,
                  onSelected: (v) {
                    ref.read(_favoritesOnlyProvider.notifier).set(v);
                    if (v) {
                      ref.read(_categoryFilterProvider.notifier).set(null);
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('All'),
                  selected: !favoritesOnly && category == null,
                  onSelected: (_) {
                    ref.read(_favoritesOnlyProvider.notifier).set(false);
                    ref.read(_categoryFilterProvider.notifier).set(null);
                  },
                ),
                for (final c in ToolCategory.values) ...[
                  const SizedBox(width: 8),
                  FilterChip(
                    avatar: Icon(c.icon, size: 18),
                    label: Text(c.label),
                    selected: !favoritesOnly && category == c,
                    onSelected: (_) {
                      ref.read(_favoritesOnlyProvider.notifier).set(false);
                      ref
                          .read(_categoryFilterProvider.notifier)
                          .set(category == c ? null : c);
                    },
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          favoritesOnly
                              ? Icons.star_border
                              : Icons.search_off,
                          size: 56,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          favoritesOnly
                              ? 'No favorites yet — tap the star on any tool'
                              : 'No tools match “$query”',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final columns =
                          (constraints.maxWidth / 340).floor().clamp(1, 4);
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisExtent: 96,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: visible.length,
                        itemBuilder: (context, i) =>
                            _ToolCard(tool: visible[i]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends ConsumerWidget {
  const _ToolCard({required this.tool});

  final Tool tool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoritesProvider.select((favs) => favs.contains(tool.id)),
    );
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: tool.builder),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                child: Icon(tool.icon, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tool.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tool.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isFavorite ? 'Unfavorite' : 'Favorite',
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? Colors.amber : null,
                ),
                onPressed: () =>
                    ref.read(favoritesProvider.notifier).toggle(tool.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
