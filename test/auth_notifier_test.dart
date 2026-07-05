import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plexus/core/errors/app_exception.dart';
import 'package:plexus/domain/entities/auth_session.dart';
import 'package:plexus/domain/repositories/auth_repository.dart';
import 'package:plexus/presentation/providers/auth_providers.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockAuthRepository();
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() => container.dispose());

  test('restores a signed-in session on startup', () async {
    when(
      () => repository.restoreSession(),
    ).thenAnswer((_) async => const AuthSession.signedIn(username: 'mor_2314'));

    final session = await container.read(authSessionProvider.future);

    expect(session, const AuthSession.signedIn(username: 'mor_2314'));
  });

  test('falls back to signed out when session restore blows up', () async {
    when(
      () => repository.restoreSession(),
    ).thenThrow(const UnexpectedException('keychain unavailable'));

    final session = await container.read(authSessionProvider.future);

    expect(session, const AuthSession.signedOut());
  });

  test('successful login stores the new session', () async {
    when(
      () => repository.restoreSession(),
    ).thenAnswer((_) async => const AuthSession.signedOut());
    when(
      () => repository.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const AuthSession.signedIn(username: 'mor_2314'));

    await container.read(authSessionProvider.future);
    await container
        .read(authSessionProvider.notifier)
        .login(username: 'mor_2314', password: '83r5^_');

    expect(
      container.read(authSessionProvider).value,
      const AuthSession.signedIn(username: 'mor_2314'),
    );
    verify(
      () => repository.login(username: 'mor_2314', password: '83r5^_'),
    ).called(1);
  });

  test('failed login rethrows and leaves the session signed out', () async {
    when(
      () => repository.restoreSession(),
    ).thenAnswer((_) async => const AuthSession.signedOut());
    when(
      () => repository.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const UnauthorizedException());

    await container.read(authSessionProvider.future);

    await expectLater(
      container
          .read(authSessionProvider.notifier)
          .login(username: 'mor_2314', password: 'wrong'),
      throwsA(isA<UnauthorizedException>()),
    );
    expect(
      container.read(authSessionProvider).value,
      const AuthSession.signedOut(),
    );
  });

  test('logout clears the session', () async {
    when(
      () => repository.restoreSession(),
    ).thenAnswer((_) async => const AuthSession.signedIn(username: 'mor_2314'));
    when(() => repository.logout()).thenAnswer((_) async {});

    await container.read(authSessionProvider.future);
    await container.read(authSessionProvider.notifier).logout();

    expect(
      container.read(authSessionProvider).value,
      const AuthSession.signedOut(),
    );
    verify(() => repository.logout()).called(1);
  });
}
