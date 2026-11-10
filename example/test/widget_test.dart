import 'package:app_bar_search/app_bar_search.dart';
import 'package:app_bar_search_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('search filters destinations; closing restores the list', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();
    expect(find.text('Popular destinations'), findsOneWidget);

    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'japan');
    await tester.pumpAndSettle();
    expect(find.text('1 result for "japan"'), findsOneWidget);
    expect(find.text('Kyoto'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Popular destinations'), findsOneWidget, reason: "closing reports '' so the filter resets");
  });

  testWidgets('every design works in the gallery, phone and desktop', (tester) async {
    for (final size in [const Size(390, 844), const Size(1280, 800)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      for (final d in AppBarSearchDesign.values) {
        await tester.pumpWidget(GalleryApp(key: ValueKey('$d$size'), initialDesign: d, initialQuery: 'a'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$d at $size');
      }
    }
    tester.view.reset();
  });
}
