// Renders the README / pub.dev screenshots with real fonts.
//
//   cd example
//   flutter test test/screenshots_test.dart --dart-define=CAPTURE=true
//
// Writes ../assets/screenshots/*.png and build/frames/*.png (GIF frames).
import 'package:app_bar_search/app_bar_search.dart';
import 'package:app_bar_search_example/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/capture.dart';

const _capture = bool.fromEnvironment('CAPTURE');
const _out = '../assets/screenshots';

ThemeData _theme(Brightness b) => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B5BF7), brightness: b),
);

String _label(AppBarSearchDesign d) => '${d.name[0].toUpperCase()}${d.name.substring(1)}';

/// Six designs, closed (left) and open with a query (right).
class _Overview extends StatelessWidget {
  const _Overview({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final b = dark ? Brightness.dark : Brightness.light;
    final theme = _theme(b);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Builder(
        builder: (context) {
          final cs = Theme.of(context).colorScheme;
          Widget bar(AppBarSearchDesign d, bool open) => ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: AppBarSearch(title: '', design: d).preferredSize.height + 28,
              child: Stack(
                children: [
                  // A colorful backdrop so glass/floating read correctly.
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: dark
                              ? [const Color(0xFF1B1B3A), const Color(0xFF2A1940)]
                              : [const Color(0xFFE9E7FF), const Color(0xFFFFE8F1)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 40,
                    top: 30,
                    child: _Blob(color: const Color(0xFFFF7A8A).withValues(alpha: 0.9), size: 64),
                  ),
                  Positioned(
                    right: 60,
                    top: 6,
                    child: _Blob(color: const Color(0xFF39D5C4).withValues(alpha: 0.9), size: 54),
                  ),
                  MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: AppBarSearch(
                      key: ValueKey('$d$open'),
                      title: 'Explore',
                      design: d,
                      initiallyOpen: open,
                      autoFocus: false,
                      keyboardShortcuts: d == AppBarSearchDesign.spotlight,
                      controller: TextEditingController(text: open ? 'Lisbon' : ''),
                      hintText: 'Search destinations',
                      actions: const [IconButton(onPressed: null, icon: Icon(Icons.tune_rounded))],
                    ),
                  ),
                ],
              ),
            ),
          );
          return Scaffold(
            backgroundColor: cs.surface,
            body: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final d in AppBarSearchDesign.values) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 6),
                      child: Text(
                        _label(d),
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurfaceVariant),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(child: bar(d, false)),
                        const SizedBox(width: 16),
                        Expanded(child: bar(d, true)),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}

void main() {
  Future<void> shoot(
    WidgetTester tester,
    Widget app,
    String name, {
    Size size = const Size(393, 852),
    Future<void> Function()? before,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    final key = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(key: key, child: app));
    await tester.pumpAndSettle();
    if (before != null) await before();
    FocusManager.instance.primaryFocus?.unfocus(); // no caret/selection handles
    await tester.pumpAndSettle();
    await capturePng(tester, key, '$_out/$name.png', pixelRatio: size.width > 900 ? 2 : 3);
    await tester.pumpWidget(const SizedBox());
  }

  testWidgets('screenshots', (tester) async {
    if (!_capture) return;
    await loadRealFonts(tester);
    addTearDown(tester.view.reset);

    await shoot(tester, const _Overview(dark: false), 'designs_light', size: const Size(820, 1010));
    await shoot(tester, const _Overview(dark: true), 'designs_dark', size: const Size(820, 1010));

    await shoot(
      tester,
      const GalleryApp(initialDesign: AppBarSearchDesign.pill, initialQuery: 'an'),
      'phone_pill_light',
    );
    await shoot(
      tester,
      const GalleryApp(initialDesign: AppBarSearchDesign.glass, initialMode: ThemeMode.dark),
      'phone_glass_dark',
      before: () async {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -640));
        await tester.pumpAndSettle();
      },
    );
    await shoot(tester, const GalleryApp(initialDesign: AppBarSearchDesign.gradient), 'phone_gradient_light');
    await shoot(
      tester,
      const GalleryApp(initialDesign: AppBarSearchDesign.floating, initialMode: ThemeMode.dark, initialQuery: 'ba'),
      'phone_floating_dark',
    );
    debugDefaultTargetPlatformOverride = TargetPlatform.windows; // desktop: shortcut hint on
    await shoot(
      tester,
      const GalleryApp(initialDesign: AppBarSearchDesign.spotlight),
      'desktop_spotlight_light',
      size: const Size(1280, 800),
    );
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('open animation frames', (tester) async {
    if (!_capture) return;
    await loadRealFonts(tester);
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 300);
    final key = GlobalKey();
    final search = AppBarSearchController();
    final text = TextEditingController();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _theme(Brightness.light),
          home: Scaffold(
            appBar: AppBarSearch(
              title: 'Explore',
              design: AppBarSearchDesign.pill,
              animationStyle: SearchAnimationStyle.scale,
              searchController: search,
              controller: text,
              hintText: 'Search destinations',
              autoFocus: false,
              animationDuration: const Duration(milliseconds: 420),
            ),
            body: const SizedBox.expand(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    var f = 0;
    Future<void> frame() =>
        capturePng(tester, key, 'build/frames/f${(f++).toString().padLeft(3, '0')}.png', pixelRatio: 2);
    for (var i = 0; i < 8; i++) {
      await frame();
    }
    search.open();
    for (var i = 0; i < 14; i++) {
      await tester.pump(const Duration(milliseconds: 33));
      await frame();
    }
    for (final s in ['L', 'Li', 'Lis', 'Lisb', 'Lisbo', 'Lisbon']) {
      text.text = s;
      await tester.pump(const Duration(milliseconds: 90));
      await frame();
      await frame();
    }
    for (var i = 0; i < 10; i++) {
      await frame();
    }
    search.close();
    for (var i = 0; i < 14; i++) {
      await tester.pump(const Duration(milliseconds: 33));
      await frame();
    }
    for (var i = 0; i < 6; i++) {
      await frame();
    }
  });
}
