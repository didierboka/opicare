import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opicare/core/widgets/form_widgets/custom_input_field.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  testWidgets('password field starts hidden and toggles visibility',
      (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(
        CustomInputField(
          controller: controller,
          hint: 'Mot de passe',
          icon: Icons.lock,
          label: 'Mot de passe',
          obscureText: true,
        ),
      ),
    );

    final fieldFinder = find.byType(TextFormField);
    expect(fieldFinder, findsOneWidget);
    expect(tester.widget<TextFormField>(fieldFinder).obscureText, isTrue);
    expect(find.byIcon(Icons.visibility), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off), findsNothing);
    expect(find.byTooltip('Afficher le mot de passe'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();

    expect(tester.widget<TextFormField>(fieldFinder).obscureText, isFalse);
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    expect(find.byIcon(Icons.visibility), findsNothing);
    expect(find.byTooltip('Masquer le mot de passe'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    expect(tester.widget<TextFormField>(fieldFinder).obscureText, isTrue);
    expect(find.byIcon(Icons.visibility), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off), findsNothing);
  });

  testWidgets('non-password field has no visibility toggle', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(
        CustomInputField(
          controller: controller,
          hint: 'Email',
          icon: Icons.email,
          label: 'Email',
        ),
      ),
    );

    expect(tester.widget<TextFormField>(find.byType(TextFormField)).obscureText,
        isFalse);
    expect(find.byIcon(Icons.visibility), findsNothing);
    expect(find.byIcon(Icons.visibility_off), findsNothing);
    expect(find.byType(IconButton), findsNothing);
  });
}
