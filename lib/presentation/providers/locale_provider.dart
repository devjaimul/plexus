import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);

/// Null means follow the system language.
class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final stored =
        Hive.box<dynamic>(AppConstants.settingsBox).get(AppConstants.localeKey)
            as String?;
    return stored == null ? null : Locale(stored);
  }

  Future<void> set(Locale? locale) async {
    state = locale;
    final box = Hive.box<dynamic>(AppConstants.settingsBox);
    if (locale == null) {
      await box.delete(AppConstants.localeKey);
    } else {
      await box.put(AppConstants.localeKey, locale.languageCode);
    }
  }
}
