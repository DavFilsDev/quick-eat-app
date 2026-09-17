import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _format = NumberFormat.decimalPattern('fr_FR');

  static String format(num montant) => '${_format.format(montant)} FCFA';
}
