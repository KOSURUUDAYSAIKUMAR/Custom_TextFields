import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneNumberInput Widget Tests', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Text("data"))));
      expect(find.text('+91'), findsOneWidget);
      expect(find.text('|'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('accepts input correctly', (WidgetTester tester) async {
      String capturedValue = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text("data"),
            // body: PhoneTextField(
            //   hint: 'Enter your phone number',
            //   label: 'Mobile Number',
            //   maxLength: 12,
            //   decoration: InputDecoration(
            //     labelText: 'Mobile Number',
            //     hintText: 'Mobile number (12 digits)',
            //     prefixIcon: const Icon(Icons.smartphone),
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     filled: true,
            //     fillColor: Colors.grey.shade100,
            //   ),
            //   onChanged: (value) {},
            // ),
          ),
        ),
      );

      // Enter text in the TextField
      await tester.enterText(find.byType(TextField), '9876543210');
      await tester.pump();

      // Check if onChanged was called with correct E.164 format
      expect(capturedValue, '+919876543210');
    });
  });
}
