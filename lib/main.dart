import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox<dynamic>(AppConstants.settingsBox),
    Hive.openBox<dynamic>(AppConstants.productCacheBox),
    Hive.openBox<dynamic>(AppConstants.favoritesBox),
  ]);

  runApp(
    ProviderScope(retry: (retryCount, error) => null, child: const PlexusApp()),
  );
}
