import 'dart:math' as math;

import 'package:app_bar_search/app_bar_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(
  Widget appBar, {
  ThemeMode mode = ThemeMode.light,
  TextDirection dir = TextDirection.ltr,
  Widget? drawer,
  bool reduceMotion = false,
}) {
  return MaterialApp(
    theme: ThemeData(colorSchemeSeed: Colors.indigo),
    darkTheme: ThemeData(colorSchemeSeed: Colors.indigo, brightness: Brightness.dark),
    themeMode: mode,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
      child: Directionality(textDirection: dir, child: child!),
    ),
    home: Scaffold(appBar: appBar as PreferredSizeWidget, drawer: drawer, body: const SizedBox.expand()),
  );
}

void _size(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

Finder get _field => find.byType(TextField);

void main() {
  group('every design renders open and closed', () {
    for (final design in AppBarSearchDesign.values) {
      for (final (label, size) in [('phone', const Size(390, 844)), ('desktop', const Size(1280, 800))]) {
        for (final mode in [ThemeMode.light, ThemeMode.dark]) {
          for (final dir in [TextDirection.ltr, TextDirection.rtl]) {
            testWidgets('${design.name} · $label · ${mode.name} · ${dir.name}', (tester) async {
              _size(tester, size);
              final c = AppBarSearchController();
              await tester.pumpWidget(
                _app(
                  AppBarSearch(
                    title: 'Inbox',
                    design: design,
                    searchController: c,
                    actions: const [Icon(Icons.more_vert)],
                  ),
                  mode: mode,
                  dir: dir,
                ),
              );
              await tester.pumpAndSettle();
              expect(find.text('Inbox'), findsOneWidget);
              c.open();
              await tester.pumpAndSettle();
              expect(_field, findsOneWidget);
              await tester.enterText(_field, 'flutter');
              await tester.pump();
              c.close();
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            });
          }
        }
      }
    }
  });

  group('icon swap', () {
    double opacityOf(WidgetTester tester, IconData icon) {
      final toggle = find.byKey(const ValueKey('app_bar_search.toggle'));
      final iconFinder = find.descendant(of: toggle, matching: find.byIcon(icon));
      if (iconFinder.evaluate().isEmpty) return 0;
      final fades = find.ancestor(of: iconFinder, matching: find.byType(FadeTransition));
      var o = 1.0;
      for (final e in fades.evaluate()) {
        o *= (e.widget as FadeTransition).opacity.value;
      }
      return o;
    }

    for (final style in SearchAnimationStyle.values) {
      testWidgets('search and close icons never overlap · ${style.name}', (tester) async {
        final c = AppBarSearchController();
        await tester.pumpWidget(
          _app(AppBarSearch(title: 'Home', animationStyle: style, searchController: c, autoFocus: false)),
        );
        await tester.pumpAndSettle();
        for (final open in [true, false]) {
          open ? c.open() : c.close();
          var worst = 0.0;
          for (var i = 0; i < 60; i++) {
            await tester.pump(const Duration(milliseconds: 8));
            final both = math.min(opacityOf(tester, Icons.search_rounded), opacityOf(tester, Icons.close_rounded));
            worst = math.max(worst, both);
          }
          expect(
            worst,
            lessThan(0.01),
            reason: '${style.name} ${open ? 'opening' : 'closing'}: both icons visible at once',
          );
          await tester.pumpAndSettle();
        }
      });
    }
  });

  group('correctness', () {
    testWidgets('the hidden field is not focusable, tappable or announced', (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(_app(AppBarSearch(title: 'Home', focusNode: focus)));
      await tester.pumpAndSettle();
      // The closed field is offstage: finders skip it and taps can't reach it.
      expect(_field, findsNothing);
      await tester.tap(find.text('Home'));
      await tester.pump();
      expect(focus.hasFocus, isFalse);
      // Tab traversal never lands in the hidden field.
      for (var i = 0; i < 4; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(focus.hasFocus, isFalse);
      }
    });

    testWidgets('quick open→close never pops the keyboard', (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      final c = AppBarSearchController();
      await tester.pumpWidget(_app(AppBarSearch(title: 'Home', focusNode: focus, searchController: c)));
      c.open();
      c.close(); // same frame
      await tester.pumpAndSettle();
      expect(focus.hasFocus, isFalse);
    });

    testWidgets('opening focuses the field', (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(_app(AppBarSearch(title: 'Home', focusNode: focus)));
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();
      expect(focus.hasFocus, isTrue);
    });

    testWidgets("closing clears the text and reports '' so filters reset", (tester) async {
      final changes = <String>[];
      var cleared = 0, closed = 0;
      await tester.pumpWidget(
        _app(AppBarSearch(title: 'Home', onChanged: changes.add, onClear: () => cleared++, onClose: () => closed++)),
      );
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();
      await tester.enterText(_field, 'abc');
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(changes, ['abc', '']);
      expect(cleared, 1);
      expect(closed, 1);
    });

    testWidgets('inline clear button empties the field and keeps it open', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _app(AppBarSearch(title: 'Home', design: AppBarSearchDesign.pill, onChanged: changes.add)),
      );
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Clear text'), findsNothing, reason: 'hidden while empty');
      await tester.enterText(_field, 'x');
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Clear text'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(_field).controller!.text, isEmpty);
      expect(changes.last, '');
      expect(_field, findsOneWidget, reason: 'still open');
    });

    testWidgets('debounce delivers only the last value; submit flushes', (tester) async {
      final changes = <String>[];
      final submits = <String>[];
      await tester.pumpWidget(
        _app(
          AppBarSearch(
            title: 'Home',
            initiallyOpen: true,
            debounce: const Duration(milliseconds: 300),
            onChanged: changes.add,
            onSubmitted: submits.add,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(_field, 'a');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(_field, 'ab');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(_field, 'abc');
      expect(changes, isEmpty);
      await tester.pump(const Duration(milliseconds: 350));
      expect(changes, ['abc']);

      await tester.enterText(_field, 'abcd');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      expect(changes.last, 'abcd', reason: 'flushed on submit');
      expect(submits, ['abcd']);
      await tester.pump(const Duration(milliseconds: 400));
      expect(changes.where((c) => c == 'abcd'), hasLength(1), reason: 'not delivered twice');
    });

    testWidgets('controller stays in sync both ways', (tester) async {
      final c = AppBarSearchController();
      var opens = 0;
      await tester.pumpWidget(_app(AppBarSearch(title: 'Home', searchController: c, onOpen: () => opens++)));
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();
      expect(c.isOpen, isTrue);
      c.close();
      await tester.pumpAndSettle();
      expect(_field, findsNothing);
      c.toggle();
      await tester.pumpAndSettle();
      expect(_field, findsOneWidget);
      expect(opens, 2);
    });

    testWidgets('swapping controllers/focus nodes at runtime is safe', (tester) async {
      final t1 = TextEditingController(text: 'one');
      final t2 = TextEditingController(text: 'two');
      final s = AppBarSearchController(isOpen: true);
      addTearDown(t1.dispose);
      addTearDown(t2.dispose);
      await tester.pumpWidget(_app(AppBarSearch(title: 'Home', controller: t1, initiallyOpen: true)));
      await tester.pumpAndSettle();
      await tester.pumpWidget(_app(AppBarSearch(title: 'Home', controller: t2, searchController: s)));
      await tester.pumpAndSettle();
      expect(find.text('two'), findsOneWidget);
      await tester.pumpWidget(_app(const AppBarSearch(title: 'Home')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('system back closes search before leaving the page', (tester) async {
      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: key,
          home: const Scaffold(body: Text('root')),
        ),
      );
      key.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(appBar: AppBarSearch(title: 'Detail', initiallyOpen: true)),
        ),
      );
      await tester.pumpAndSettle();
      expect(_field, findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(_field, findsNothing, reason: 'search closed');
      expect(find.text('Detail'), findsOneWidget, reason: 'still on the page');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('root'), findsOneWidget);
    });

    testWidgets('keyboard: Ctrl+K and / open, Esc closes', (tester) async {
      await tester.pumpWidget(_app(const AppBarSearch(title: 'Home', keyboardShortcuts: true)));
      await tester.pumpAndSettle();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(_field, findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(_field, findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.slash);
      await tester.pumpAndSettle();
      expect(_field, findsOneWidget);
    });

    testWidgets('shortcuts are off by default on phones', (tester) async {
      await tester.pumpWidget(_app(const AppBarSearch(title: 'Home')));
      await tester.sendKeyEvent(LogicalKeyboardKey.slash);
      await tester.pumpAndSettle();
      expect(_field, findsNothing);
    }, variant: const TargetPlatformVariant({TargetPlatform.android, TargetPlatform.iOS}));

    testWidgets('reduced motion opens instantly', (tester) async {
      await tester.pumpWidget(_app(const AppBarSearch(title: 'Home'), reduceMotion: true));
      await tester.tap(find.byTooltip('Search'));
      await tester.pump(); // one frame, no elapsed time
      expect(_field, findsOneWidget);
      expect(find.text('Home'), findsNothing, reason: 'transition already complete: title layer offstage');
    });

    testWidgets('implies drawer and back buttons like AppBar', (tester) async {
      await tester.pumpWidget(
        _app(
          const AppBarSearch(title: 'Home', design: AppBarSearchDesign.glass),
          drawer: const Drawer(),
        ),
      );
      expect(find.byType(DrawerButton), findsOneWidget);
      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(MaterialApp(navigatorKey: key, home: const SizedBox()));
      key.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(
            appBar: AppBarSearch(title: 'X', design: AppBarSearchDesign.pill),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('spotlight: trigger opens the field; title kept on wide screens', (tester) async {
      _size(tester, const Size(1280, 800));
      await tester.pumpWidget(
        _app(const AppBarSearch(title: 'Docs', design: AppBarSearchDesign.spotlight, keyboardShortcuts: true)),
      );
      await tester.pumpAndSettle();
      expect(find.text('K'), findsOneWidget, reason: 'shortcut hint');
      await tester.tap(find.bySemanticsLabel('Search'));
      await tester.pumpAndSettle();
      expect(_field, findsOneWidget);
      expect(find.text('Docs'), findsOneWidget);
    });

    testWidgets('wide screens keep the title next to the open search', (tester) async {
      _size(tester, const Size(1280, 800));
      await tester.pumpWidget(
        _app(const AppBarSearch(title: 'Shop', design: AppBarSearchDesign.pill, initiallyOpen: true)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Shop'), findsOneWidget);
      expect(tester.getSize(find.byType(TextField)).width, lessThanOrEqualTo(560));
    });

    test('preferredSize accounts for design chrome and bottom', () {
      expect(const AppBarSearch(title: 'a').preferredSize.height, kToolbarHeight);
      expect(const AppBarSearch(title: 'a', design: AppBarSearchDesign.pill).preferredSize.height, 64);
      expect(const AppBarSearch(title: 'a', design: AppBarSearchDesign.floating).preferredSize.height, 76);
      final tabs = TabBar(tabs: const [Tab(text: 'A')], controller: null);
      expect(AppBarSearch(title: 'a', bottom: tabs).preferredSize.height, kToolbarHeight + tabs.preferredSize.height);
    });
  });
}
