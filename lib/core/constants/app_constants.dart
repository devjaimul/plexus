abstract final class AppConstants {
  static const apiBaseUrl = 'https://fakestoreapi.com';
  static const connectTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 15);

  // api has no pagination, list is chunked client-side
  static const productsPageSize = 8;

  static const settingsBox = 'settings';
  static const productCacheBox = 'product_cache';
  static const favoritesBox = 'favorites';

  static const themeModeKey = 'theme_mode';
  static const localeKey = 'locale';
  static const authTokenKey = 'auth_token';
  static const authUsernameKey = 'auth_username';
}
