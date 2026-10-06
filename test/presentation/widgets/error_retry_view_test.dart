import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_gallery/presentation/widgets/error_retry_view.dart';

void main() {
  testWidgets('renders the message and fires the retry callback', (
    WidgetTester tester,
  ) async {
    int retries = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorRetryView(
            message: 'No connectivity',
            onRetry: () => retries++,
          ),
        ),
      ),
    );

    expect(find.text('No connectivity'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    expect(retries, 1);
  });
}
