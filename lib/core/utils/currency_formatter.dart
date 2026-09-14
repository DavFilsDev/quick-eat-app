import 'package:intl/intl.dart';

/// Formate un montant en FCFA, ex: 4000 -> "4 000 FCFA".
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _format = NumberFormat.decimalPattern('fr_FR');

  static String format(num montant) => '${_format.format(montant)} FCFA';
}
