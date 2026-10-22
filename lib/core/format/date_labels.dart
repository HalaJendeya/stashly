import 'package:intl/intl.dart';

import 'package:stashly/l10n/generated/app_localizations.dart';

/// Human date labels used across cards and details ("Today", "Sep 18"),
/// in the language of [l10n] with month and day names from `intl`.
class DateLabels {
  const DateLabels(this.l10n);

  final AppLocalizations l10n;

  String get _locale => l10n.localeName;

  /// "Today", "Yesterday", "Sep 18" or "Sep 18, 2024" for older years.
  String relativeDay(DateTime moment, {DateTime? now}) {
    final local = moment.toLocal();
    final today = _dateOnly(now ?? DateTime.now());
    final day = _dateOnly(local);
    final difference = today.difference(day).inDays;
    if (difference == 0) return l10n.today;
    if (difference == 1) return l10n.yesterday;
    return local.year == today.year
        ? DateFormat.MMMd(_locale).format(local)
        : DateFormat.yMMMd(_locale).format(local);
  }

  /// "THURSDAY, OCTOBER 16" for the Home eyebrow.
  String eyebrowDate(DateTime now) =>
      DateFormat.MMMMEEEEd(_locale).format(now).toUpperCase();

  /// "October 2025" for "Member since".
  String monthYear(DateTime moment) =>
      DateFormat.yMMMM(_locale).format(moment.toLocal());

  /// "Good morning, Maya" by time of day, or just "Good morning".
  String greeting(DateTime now, {String name = ''}) {
    final named = name.isNotEmpty;
    return switch (now.hour) {
      >= 5 && < 12 =>
        named ? l10n.greetingMorning(name) : l10n.greetingMorningPlain,
      >= 12 && < 18 =>
        named ? l10n.greetingAfternoon(name) : l10n.greetingAfternoonPlain,
      _ => named ? l10n.greetingEvening(name) : l10n.greetingEveningPlain,
    };
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
