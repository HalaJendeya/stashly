/// Human date labels used across cards and details ("Today", "Sep 18").
abstract final class DateLabels {
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July', //
    'August', 'September', 'October', 'November', 'December',
  ];
  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', //
    'Sunday',
  ];

  /// "Today", "Yesterday", "Sep 18" or "Sep 18, 2024" for older years.
  static String relativeDay(DateTime moment, {DateTime? now}) {
    final local = moment.toLocal();
    final today = _dateOnly(now ?? DateTime.now());
    final day = _dateOnly(local);
    final difference = today.difference(day).inDays;
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    final short = '${_months[local.month - 1].substring(0, 3)} ${local.day}';
    return local.year == today.year ? short : '$short, ${local.year}';
  }

  /// "THURSDAY, OCTOBER 16" for the Home eyebrow.
  static String eyebrowDate(DateTime now) =>
      '${_weekdays[now.weekday - 1]}, ${_months[now.month - 1]} ${now.day}'
          .toUpperCase();

  /// "October 2025" for "Member since".
  static String monthYear(DateTime moment) {
    final local = moment.toLocal();
    return '${_months[local.month - 1]} ${local.year}';
  }

  static String greeting(DateTime now) => switch (now.hour) {
    < 5 => 'Good evening',
    < 12 => 'Good morning',
    < 18 => 'Good afternoon',
    _ => 'Good evening',
  };

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
