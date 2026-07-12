import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pdf_scanner/app.dart';

void main() {
  testWidgets('App launches with bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PdfScannerApp(),
      ),
    );

    expect(find.byType(NavigationBar), findsOneWidget);
  });
}