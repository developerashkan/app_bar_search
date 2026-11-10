import 'package:app_bar_search/app_bar_search.dart';
import 'package:flutter/material.dart';

void main() => runApp(const GalleryApp());

class GalleryApp extends StatefulWidget {
  const GalleryApp({
    super.key,
    this.initialDesign = AppBarSearchDesign.pill,
    this.initialMode = ThemeMode.light,
    this.initialQuery,
    this.home,
  });

  final AppBarSearchDesign initialDesign;
  final ThemeMode initialMode;

  /// Opens search with this query (screenshots / tests).
  final String? initialQuery;
  final Widget? home;

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  late ThemeMode _mode = widget.initialMode;
  bool _rtl = false;

  ThemeData _theme(Brightness b) => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B5BF7), brightness: b),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'app_bar_search gallery',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: _mode,
      builder: (context, child) =>
          Directionality(textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr, child: child!),
      home:
          widget.home ??
          GalleryPage(
            initialDesign: widget.initialDesign,
            initialQuery: widget.initialQuery,
            dark: _mode == ThemeMode.dark,
            rtl: _rtl,
            onDark: (v) => setState(() => _mode = v ? ThemeMode.dark : ThemeMode.light),
            onRtl: (v) => setState(() => _rtl = v),
          ),
    );
  }
}

class Destination {
  const Destination(this.name, this.country, this.a, this.b, this.icon);
  final String name;
  final String country;
  final Color a;
  final Color b;
  final IconData icon;
}

const destinations = [
  Destination('Kyoto', 'Japan', Color(0xFFFF7A8A), Color(0xFFFFB86B), Icons.temple_buddhist_rounded),
  Destination('Lisbon', 'Portugal', Color(0xFF4F8CFF), Color(0xFF7BE0FF), Icons.tram_rounded),
  Destination('Reykjavík', 'Iceland', Color(0xFF6A5BFF), Color(0xFF39D5C4), Icons.ac_unit_rounded),
  Destination('Marrakech', 'Morocco', Color(0xFFFF8A3D), Color(0xFFFFD166), Icons.mosque_rounded),
  Destination('Banff', 'Canada', Color(0xFF1FB37E), Color(0xFF8BE36A), Icons.landscape_rounded),
  Destination('Santorini', 'Greece', Color(0xFF3D7BFF), Color(0xFFB2C8FF), Icons.sailing_rounded),
  Destination('Cape Town', 'South Africa', Color(0xFFF65B7A), Color(0xFF9D6BFF), Icons.terrain_rounded),
  Destination('Queenstown', 'New Zealand', Color(0xFF00B4D8), Color(0xFF90E0EF), Icons.paragliding_rounded),
  Destination('Patagonia', 'Argentina', Color(0xFF5E60CE), Color(0xFF64DFDF), Icons.hiking_rounded),
  Destination('Bali', 'Indonesia', Color(0xFF2DC653), Color(0xFFFFD60A), Icons.beach_access_rounded),
];

class GalleryPage extends StatefulWidget {
  const GalleryPage({
    super.key,
    required this.initialDesign,
    required this.dark,
    required this.rtl,
    required this.onDark,
    required this.onRtl,
    this.initialQuery,
  });

  final AppBarSearchDesign initialDesign;
  final String? initialQuery;
  final bool dark;
  final bool rtl;
  final ValueChanged<bool> onDark;
  final ValueChanged<bool> onRtl;

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late AppBarSearchDesign _design = widget.initialDesign;
  SearchAnimationStyle _animation = SearchAnimationStyle.fadeSlide;
  late final TextEditingController _text = TextEditingController(text: widget.initialQuery);
  late final AppBarSearchController _search = AppBarSearchController(isOpen: widget.initialQuery != null);
  late String _query = widget.initialQuery ?? '';

  @override
  void dispose() {
    _text.dispose();
    _search.dispose();
    super.dispose();
  }

  List<Destination> get _results {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return destinations;
    return destinations.where((d) => d.name.toLowerCase().contains(q) || d.country.toLowerCase().contains(q)).toList();
  }

  static String _label(AppBarSearchDesign d) => switch (d) {
    AppBarSearchDesign.classic => 'Classic',
    AppBarSearchDesign.pill => 'Pill',
    AppBarSearchDesign.glass => 'Glass',
    AppBarSearchDesign.gradient => 'Gradient',
    AppBarSearchDesign.floating => 'Floating',
    AppBarSearchDesign.spotlight => 'Spotlight',
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 900;
    final overlay = _design == AppBarSearchDesign.glass || _design == AppBarSearchDesign.floating;

    final appBar = AppBarSearch(
      title: 'Explore',
      design: _design,
      animationStyle: _animation,
      controller: _text,
      searchController: _search,
      hintText: 'Search destinations',
      onChanged: (q) => setState(() => _query = q),
      actions: [
        IconButton(
          tooltip: widget.dark ? 'Light mode' : 'Dark mode',
          onPressed: () => widget.onDark(!widget.dark),
          icon: Icon(widget.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
        ),
      ],
    );

    final controls = _Controls(
      design: _design,
      animation: _animation,
      rtl: widget.rtl,
      label: _label,
      onDesign: (d) => setState(() => _design = d),
      onAnimation: (a) => setState(() => _animation = a),
      onRtl: widget.onRtl,
      onOpen: _search.open,
    );

    final results = _results;
    final grid = SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      sliver: results.isEmpty
          ? SliverToBoxAdapter(child: _Empty(query: _query))
          : SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: wide ? 240 : 220,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.92,
              ),
              itemCount: results.length,
              itemBuilder: (context, i) => _DestinationCard(d: results[i]),
            ),
    );

    final topInset = overlay ? appBar.preferredSize.height + MediaQuery.paddingOf(context).top : 0.0;
    final scroll = CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: topInset)),
        if (!wide)
          SliverToBoxAdapter(
            child: Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: controls),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Text(
              _query.isEmpty
                  ? 'Popular destinations'
                  : '${results.length} result${results.length == 1 ? '' : 's'} for "$_query"',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface),
            ),
          ),
        ),
        grid,
      ],
    );

    return Scaffold(
      extendBodyBehindAppBar: overlay,
      appBar: appBar,
      body: wide
          ? Row(
              children: [
                SizedBox(
                  width: 340,
                  child: ListView(padding: EdgeInsets.fromLTRB(16, topInset + 16, 8, 24), children: [controls]),
                ),
                Expanded(child: scroll),
              ],
            )
          : scroll,
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.design,
    required this.animation,
    required this.rtl,
    required this.label,
    required this.onDesign,
    required this.onAnimation,
    required this.onRtl,
    required this.onOpen,
  });

  final AppBarSearchDesign design;
  final SearchAnimationStyle animation;
  final bool rtl;
  final String Function(AppBarSearchDesign) label;
  final ValueChanged<AppBarSearchDesign> onDesign;
  final ValueChanged<SearchAnimationStyle> onAnimation;
  final ValueChanged<bool> onRtl;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Card.filled(
      color: cs.surfaceContainerLow,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Design', style: t.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final d in AppBarSearchDesign.values)
                  ChoiceChip(label: Text(label(d)), selected: d == design, onSelected: (_) => onDesign(d)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Animation', style: t.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            DropdownMenu<SearchAnimationStyle>(
              initialSelection: animation,
              expandedInsets: EdgeInsets.zero,
              onSelected: (a) => a == null ? null : onAnimation(a),
              dropdownMenuEntries: [
                for (final a in SearchAnimationStyle.values) DropdownMenuEntry(value: a, label: a.name),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Right-to-left'),
                    value: rtl,
                    onChanged: onRtl,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: onOpen,
                icon: const Icon(Icons.search_rounded),
                label: const Text('Open search from code'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({required this.d});
  final Destination d;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: '${d.name}, ${d.country}',
      excludeSemantics: true,
      child: Material(
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {},
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [d.a, d.b]),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -18,
                  top: -10,
                  child: Icon(d.icon, size: 120, color: Colors.white.withValues(alpha: 0.22)),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(d.icon, color: Colors.white, size: 20),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        d.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        d.country,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodySmall?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.travel_explore_rounded, size: 48, color: cs.onSurfaceVariant),
          const SizedBox(height: 12),
          Text('No destinations match "$query"', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16)),
        ],
      ),
    );
  }
}
