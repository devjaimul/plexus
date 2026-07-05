import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plexus/core/errors/app_exception.dart';
import 'package:plexus/domain/entities/auth_session.dart';
import 'package:plexus/domain/repositories/auth_repository.dart';
import 'package:plexus/l10n/app_localizations.dart';
import 'package:plexus/presentation/providers/auth_providers.dart';
import 'package:plexus/presentation/screens/auth/login_page.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
    when(
      () => repository.restoreSession(),
    ).thenAnswer((_) async => const AuthSession.signedOut());
  });

  Future<void> pumpLoginPage(WidgetTester tester) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LoginPage(),
        ),
      ),
    );
  }

  testWidgets('shows validation errors when submitted empty', (tester) async {
    await pumpLoginPage(tester);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text('Enter your username'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    verifyNever(
      () => repository.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('submits trimmed credentials to the repository', (tester) async {
    when(
      () => repository.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const AuthSession.signedIn(username: 'mor_2314'));

    await pumpLoginPage(tester);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, ' mor_2314 ');
    await tester.enterText(find.byType(TextFormField).last, '83r5^_');
    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    verify(
      () => repository.login(username: 'mor_2314', password: '83r5^_'),
    ).called(1);
  });

  testWidgets('shows an inline error for bad credentials', (tester) async {
    when(
      () => repository.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const UnauthorizedException());

    await pumpLoginPage(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Use demo account'));
    await tester.pump();
    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Incorrect username or password.'), findsOneWidget);
  });
}
