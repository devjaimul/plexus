import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'auth_session.freezed.dart';

@freezed
sealed class AuthSession with _$AuthSession {
  const factory AuthSession.signedIn({
    required String username,
    User? profile,
  }) = SignedIn;

  const factory AuthSession.signedOut() = SignedOut;
}
