import 'package:intl/intl.dart';

abstract final class Formatters {
  // fakestoreapi prices are plain USD numbers.
  static final _currency = NumberFormat.currency(locale: 'en_US', symbol: r'$');

  static String price(double value) => _currency.format(value);

  static String titleCase(String value) => value
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
