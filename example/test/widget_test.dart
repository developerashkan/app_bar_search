import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_bar_search_example/main.dart';

void main() {
  testWidgets('Verify AppBarSearch functionality', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title "Home" is present.
    expect(find.text('Home'), findsOneWidget);
    
    // Verify that the search icon is present.
    expect(find.byIcon(Icons.search), findsOneWidget);

    // Tap the search icon.
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // Verify that the search field is now visible (hint text).
    expect(find.text('Search...'), findsOneWidget);
    
    // Verify that the close icon is now present.
    expect(find.byIcon(Icons.close), findsOneWidget);

    // Type into the search field.
    await tester.enterText(find.byType(TextField), 'Flutter');
    await tester.pump();

    // Verify that the body reflects the search query.
    expect(find.text('Searching for: Flutter'), findsOneWidget);

    // Tap the close icon to clear and close search.
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Verify that we are back to the initial state.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('You have pushed the button this many times:'), findsOneWidget);
  });
}
