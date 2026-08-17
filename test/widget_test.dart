import 'package:flutter_test/flutter_test.dart';
import 'package:zad_alakhira/main.dart';

void main() {
  testWidgets('زاد الآخرة app can be created', (WidgetTester tester) async {
    await tester.pumpWidget(const ZadAlakhiraApp());
    expect(find.byType(ZadAlakhiraApp), findsOneWidget);
  });
}
