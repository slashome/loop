import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('Hello World is shown', (tester) async {
    await tester.pumpWidget(const LoopApp());

    expect(find.text('Hello World'), findsOneWidget);
  });
}
