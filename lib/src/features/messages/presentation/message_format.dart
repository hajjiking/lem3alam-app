import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/l10n/l10n.dart';

bool sameMessageDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
String messageDay(BuildContext context, DateTime time) {
  final now = DateTime.now();
  if (sameMessageDay(time, now)) return context.l10n.messagesToday;
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  if (sameMessageDay(time, yesterday)) return context.l10n.messagesYesterday;
  return DateFormat.yMMMd(Localizations.localeOf(context).toString())
      .format(time);
}

String messageTime(BuildContext context, DateTime time) =>
    DateFormat.jm(Localizations.localeOf(context).toString()).format(time);
String conversationTime(BuildContext context, DateTime? time) => time == null
    ? ''
    : sameMessageDay(time, DateTime.now())
        ? messageTime(context, time)
        : messageDay(context, time);
