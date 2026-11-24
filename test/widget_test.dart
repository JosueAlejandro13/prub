import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiverse_explorers/main.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MultiverseApp(),
      ),
    );
    expect(find.byType(MultiverseApp), findsOneWidget);
  });
}
