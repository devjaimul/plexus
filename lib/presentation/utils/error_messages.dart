import '../../core/errors/app_exception.dart';
import '../../l10n/app_localizations.dart';

String errorMessage(Object error, AppLocalizations l10n) => switch (error) {
  NetworkException() => l10n.errorNetwork,
  UnauthorizedException() => l10n.errorUnauthorized,
  ApiException(:final statusCode) => l10n.errorServer(statusCode),
  _ => l10n.errorUnexpected,
};
