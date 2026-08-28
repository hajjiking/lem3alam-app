import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;

String earningsMoney(BuildContext context, int minor, String currency) {
  final format = NumberFormat.currency(
      locale: Localizations.localeOf(context).toString(),
      name: currency,
      symbol: currency,
      decimalDigits: 2);
  // Keep the sign adjacent to the LTR monetary value even in Arabic; retain
  // intl's locale-specific separators and currency placement.
  final value = format
      .format(minor.abs() / 100)
      .replaceAll(RegExp('[\u200e\u200f\u061c]'), '');
  return minor < 0 ? '−$value' : value;
}

class EarningsMoney extends StatelessWidget {
  const EarningsMoney(this.minor,
      {super.key, required this.currency, this.style});
  final int minor;
  final String currency;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) =>
      Text(earningsMoney(context, minor, currency),
          textDirection: TextDirection.ltr, style: style);
}
