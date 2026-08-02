import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:score/app.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ScoreApp()));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(ScoreApp), findsOneWidget);
  });
}
