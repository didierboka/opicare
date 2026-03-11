import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// Conversion utilitaire vers le franc CFA (XOF).
///
/// - Si la devise est déjà XOF/XAF, renvoie le montant tel quel.
/// - Sinon, tente une conversion via un endpoint public.
/// - Met en cache les taux en mémoire pour éviter de refetch.
class CurrencyConverter {
  CurrencyConverter._();

  static final CurrencyConverter instance = CurrencyConverter._();

  final Map<String, double> _toXofRateByCurrency = {};

  static const String _target = 'XOF';

  Future<double?> convertToXof({
    required double amount,
    required String fromCurrency,
  }) async {
    final from = fromCurrency.toUpperCase().trim();
    if (from.isEmpty) return null;

    if (from == _target || from == 'XAF') return amount;

    final cached = _toXofRateByCurrency[from];
    if (cached != null) return amount * cached;

    final rate = await _fetchRateToXof(from);
    if (rate == null) return null;

    _toXofRateByCurrency[from] = rate;
    return amount * rate;
  }

  Future<double?> _fetchRateToXof(String from) async {
    // Endpoint public (peut échouer selon restrictions réseau / provider).
    final uri = Uri.parse('https://api.exchangerate.host/latest?base=$from&symbols=$_target');

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 6));
      if (res.statusCode < 200 || res.statusCode >= 300) return null;

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final rates = decoded['rates'];
      if (rates is! Map) return null;
      final xof = rates[_target];
      if (xof is num) return xof.toDouble();
      return null;
    } catch (_) {
      // Fallback: taux fixe EUR->XOF (UEMOA) si l'API est indisponible.
      if (from == 'EUR') return 655.957;
      return null;
    }
  }

  static String formatFcfa(num amount) {
    final formatted = NumberFormat.decimalPattern('fr_FR').format(amount.round());
    return '$formatted FCFA';
  }
}

