/// Everything the data layer throws gets mapped into one of these.
sealed class AppException implements Exception {
  const AppException([this.message]);

  final String? message;

  @override
  String toString() => '$runtimeType(${message ?? ''})';
}

final class NetworkException extends AppException {
  const NetworkException([super.message]);
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message]);
}

final class ApiException extends AppException {
  const ApiException(this.statusCode, [String? message]) : super(message);

  final int statusCode;
}

final class UnexpectedException extends AppException {
  const UnexpectedException([super.message]);
}
