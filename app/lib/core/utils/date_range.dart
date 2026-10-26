enum DatePreset {
  today,
  yesterday,
  thisWeek,
  thisMonth,
  previousMonth,
  custom,
}

class DateRange {
  const DateRange({required this.from, required this.to, this.preset});
  final DateTime from;
  final DateTime to;
  final DatePreset? preset;

  String get fromIso => _d(from);
  String get toIso => _d(to);

  static String _d(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateRange forPreset(DatePreset p, {DateTime? customFrom, DateTime? customTo}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (p) {
      case DatePreset.today:
        return DateRange(from: today, to: today, preset: p);
      case DatePreset.yesterday:
        final y = today.subtract(const Duration(days: 1));
        return DateRange(from: y, to: y, preset: p);
      case DatePreset.thisWeek:
        final start = today.subtract(Duration(days: today.weekday - 1));
        return DateRange(from: start, to: today, preset: p);
      case DatePreset.thisMonth:
        return DateRange(
          from: DateTime(today.year, today.month, 1),
          to: today,
          preset: p,
        );
      case DatePreset.previousMonth:
        final first = DateTime(today.year, today.month - 1, 1);
        final last = DateTime(today.year, today.month, 0);
        return DateRange(from: first, to: last, preset: p);
      case DatePreset.custom:
        return DateRange(
          from: customFrom ?? today,
          to: customTo ?? today,
          preset: p,
        );
    }
  }
}
