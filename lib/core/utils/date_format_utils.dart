class DateFormatUtils {
  const DateFormatUtils._();

  static const String displayPattern = 'dd-MM-yyyy';

  static String formatDisplay(String value) {
    final String normalized = value.trim();
    if (normalized.isEmpty || normalized == '-' || normalized == 'null') {
      return value;
    }

    final DateTime? parsed = _tryParseDate(normalized);
    if (parsed == null) {
      return value;
    }

    return formatDateTime(parsed);
  }

  static String formatDateTime(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }

  static String formatDisplayDate(String value) {
    return formatDisplay(value);
  }

  static bool isDateLike(String value) {
    return _tryParseDate(value.trim()) != null;
  }

  static DateTime? _tryParseDate(String value) {
    if (value.isEmpty) {
      return null;
    }

    final String normalized = value.replaceAll('T', ' ').trim();

    if (normalized.length >= 10) {
      final String datePortion = normalized.substring(0, 10);
      final List<String> parts = datePortion.split('-');
      if (parts.length == 3) {
        final int? year = int.tryParse(parts[0]);
        final int? month = int.tryParse(parts[1]);
        final int? day = int.tryParse(parts[2]);
        if (year != null && month != null && day != null) {
          final DateTime candidate = DateTime(year, month, day);
          if (candidate.year == year &&
              candidate.month == month &&
              candidate.day == day) {
            return candidate;
          }
        }
      }
    }

    final RegExpMatch? slashMatch = RegExp(
      r'^(\d{1,2})/(\d{1,2})/(\d{4})$',
    ).firstMatch(value);
    if (slashMatch != null) {
      final int day = int.parse(slashMatch.group(1)!);
      final int month = int.parse(slashMatch.group(2)!);
      final int year = int.parse(slashMatch.group(3)!);
      final DateTime candidate = DateTime(year, month, day);
      if (candidate.year == year &&
          candidate.month == month &&
          candidate.day == day) {
        return candidate;
      }
    }

    final RegExpMatch? dashMatch = RegExp(
      r'^(\d{1,2})-(\d{1,2})-(\d{4})$',
    ).firstMatch(value);
    if (dashMatch != null) {
      final int day = int.parse(dashMatch.group(1)!);
      final int month = int.parse(dashMatch.group(2)!);
      final int year = int.parse(dashMatch.group(3)!);
      final DateTime candidate = DateTime(year, month, day);
      if (candidate.year == year &&
          candidate.month == month &&
          candidate.day == day) {
        return candidate;
      }
    }

    return null;
  }
}
