import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/main.dart';

void main() {
  testWidgets('l\'app démarre et affiche le shell Loop', (tester) async {
    await tester.pumpWidget(const LoopApp());
    expect(find.text('Loop'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
