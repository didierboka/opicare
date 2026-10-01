import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/features/carnet_sante/presentation/pages/carnet_sante_screen.dart';
import 'package:opicare/features/famille/data/models/family_member.dart';
import 'package:opicare/features/famille/presentation/widgets/family_card.dart';
import 'package:opicare/features/iap/presentation/pages/iap_screen.dart';

FamilyMember _member({
  required String formula,
  String expirationDate = '31-12-2099',
  String id = '42',
}) {
  return FamilyMember(
    id: id,
    name: 'Kid',
    surname: 'Test',
    sex: 'M',
    birthdate: '2015-01-01',
    subscriptionDate: '01-01-2025',
    expirationDate: expirationDate,
    formula: formula,
  );
}

Future<void> _pumpCard(
  WidgetTester tester, {
  required FamilyMember member,
}) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => Scaffold(body: FamilyMemberCard(member: member)),
      ),
      GoRoute(
        path: '${CarnetSanteScreen.path}/:patientId',
        builder: (_, state) => Text('carnet:${state.pathParameters['patientId']}'),
      ),
      GoRoute(
        path: IapScreen.path,
        builder: (_, __) => const Text('iap'),
      ),
    ],
  );

  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('PREMIUM actif ouvre le carnet du membre', (tester) async {
    await _pumpCard(tester, member: _member(formula: 'PREMIUM'));

    await tester.tap(find.text('Kid Test'));
    await tester.pumpAndSettle();

    expect(find.text('carnet:42'), findsOneWidget);
  });

  testWidgets('BUSINESS actif ouvre le carnet du membre', (tester) async {
    await _pumpCard(tester, member: _member(formula: 'BUSINESS'));

    await tester.tap(find.text('Kid Test'));
    await tester.pumpAndSettle();

    expect(find.text('carnet:42'), findsOneWidget);
  });

  testWidgets('SERENITY actif ouvre le carnet du membre', (tester) async {
    await _pumpCard(tester, member: _member(formula: 'SERENITY'));

    await tester.tap(find.text('Kid Test'));
    await tester.pumpAndSettle();

    expect(find.text('carnet:42'), findsOneWidget);
  });

  testWidgets('STANDARD actif refuse le carnet avec le message minimum PREMIUM',
      (tester) async {
    await _pumpCard(tester, member: _member(formula: 'STANDARD'));

    await tester.tap(find.text('Kid Test'));
    await tester.pumpAndSettle();

    expect(find.text('Accès refusé'), findsOneWidget);
    expect(
      find.textContaining('PREMIUM, BUSINESS ou SERENITY'),
      findsOneWidget,
    );
    expect(find.text('carnet:42'), findsNothing);
  });

  testWidgets(
      'membre expiré (même PREMIUM) ouvre le renouvellement, pas le refus formule',
      (tester) async {
    await _pumpCard(
      tester,
      member: _member(formula: 'PREMIUM', expirationDate: '01-01-2020'),
    );

    await tester.tap(find.text('Kid Test'));
    await tester.pumpAndSettle();

    expect(find.text('Abonnement expiré'), findsOneWidget);
    expect(find.text('Accès refusé'), findsNothing);
    expect(find.text('carnet:42'), findsNothing);
  });
}
