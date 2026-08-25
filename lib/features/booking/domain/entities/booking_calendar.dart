import 'package:equatable/equatable.dart';

import '../../../api_data/domain/entities/api_collection.dart';

class BookingCalendarResponse extends Equatable {
  const BookingCalendarResponse({
    required this.year,
    required this.month,
    required this.days,
  });

  factory BookingCalendarResponse.fromJson(Map<String, dynamic> json) {
    final dynamic rawDays = json['days'];
    final List<BookingCalendarDay> days = rawDays is List<dynamic>
        ? rawDays
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (Map<dynamic, dynamic> item) => BookingCalendarDay.fromJson(
                  item.map(
                    (dynamic key, dynamic value) =>
                        MapEntry<String, dynamic>(key.toString(), value),
                  ),
                ),
              )
              .toList()
        : <BookingCalendarDay>[];

    return BookingCalendarResponse(
      year: _toInt(json['year']),
      month: _toInt(json['month']),
      days: days,
    );
  }

  final int year;
  final int month;
  final List<BookingCalendarDay> days;

  Map<String, BookingCalendarDay> get dayByDate {
    return <String, BookingCalendarDay>{
      for (final BookingCalendarDay day in days) day.date: day,
    };
  }

  BookingCalendarDay? dayFor(DateTime date) {
    return dayByDate[_dateKey(date)];
  }

  @override
  List<Object?> get props => <Object?>[year, month, days];
}

class BookingCalendarDay extends Equatable {
  const BookingCalendarDay({
    required this.date,
    required this.dayName,
    required this.isSunday,
    required this.hasSundaySchedule,
    required this.isHoliday,
    required this.isLeave,
    required this.isOffDay,
    required this.isOpen,
    required this.reason,
    required this.holidayNames,
  });

  factory BookingCalendarDay.fromJson(Map<String, dynamic> json) {
    final dynamic rawNames = json['holiday_names'];
    final List<String> holidayNames = rawNames is List<dynamic>
        ? rawNames
              .map((dynamic item) => item?.toString().trim() ?? '')
              .where((String item) => item.isNotEmpty)
              .toList()
        : <String>[];

    return BookingCalendarDay(
      date: _normalizeDateKey(json['date']),
      dayName: ApiResponseReader.stringValue(json, const <String>[
        'day_name',
      ], fallback: ''),
      isSunday: _toBool(json['is_sunday']),
      hasSundaySchedule: _toBool(json['has_sunday_schedule']),
      isHoliday: _toBool(json['is_holiday']),
      isLeave: _toBool(json['is_leave']),
      isOffDay: _toBool(json['is_off_day']),
      isOpen: _toBool(json['is_open']),
      reason: ApiResponseReader.stringValue(json, const <String>[
        'reason',
      ], fallback: ''),
      holidayNames: holidayNames,
    );
  }

  final String date;
  final String dayName;
  final bool isSunday;
  final bool hasSundaySchedule;
  final bool isHoliday;
  final bool isLeave;
  final bool isOffDay;
  final bool isOpen;
  final String reason;
  final List<String> holidayNames;

  DateTime? get dateValue {
    return _parseDateKey(date);
  }

  String get badgeLabel {
    if (isHoliday) {
      return 'Libur';
    }
    if (isLeave) {
      return 'Cuti Bersama';
    }
    if (isSunday && !hasSundaySchedule) {
      return 'Minggu';
    }
    if (isSunday && hasSundaySchedule) {
      return 'Buka';
    }
    return '';
  }

  String get displayReason {
    if (reason.trim().isNotEmpty) {
      return reason;
    }
    if (isHoliday) {
      return 'Libur nasional';
    }
    if (isLeave) {
      return 'Cuti Bersama';
    }
    if (isSunday && !hasSundaySchedule) {
      return 'Hari Minggu';
    }
    return 'Tersedia';
  }

  @override
  List<Object?> get props => <Object?>[
    date,
    dayName,
    isSunday,
    hasSundaySchedule,
    isHoliday,
    isLeave,
    isOffDay,
    isOpen,
    reason,
    holidayNames,
  ];
}

String _dateKey(DateTime date) {
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String _normalizeDateKey(Object? value) {
  final DateTime? parsed = _parseDateKey(value?.toString().trim() ?? '');
  if (parsed == null) {
    return value?.toString().trim() ?? '';
  }

  return _dateKey(parsed);
}

DateTime? _parseDateKey(String value) {
  final String normalized = value.trim();
  if (normalized.isEmpty) {
    return null;
  }

  final RegExpMatch? isoMatch = RegExp(
    r'^(\d{4})-(\d{1,2})-(\d{1,2})$',
  ).firstMatch(normalized);
  if (isoMatch != null) {
    return _validDate(
      int.tryParse(isoMatch.group(1)!),
      int.tryParse(isoMatch.group(2)!),
      int.tryParse(isoMatch.group(3)!),
    );
  }

  final RegExpMatch? displayMatch = RegExp(
    r'^(\d{1,2})-(\d{1,2})-(\d{4})$',
  ).firstMatch(normalized);
  if (displayMatch != null) {
    return _validDate(
      int.tryParse(displayMatch.group(3)!),
      int.tryParse(displayMatch.group(2)!),
      int.tryParse(displayMatch.group(1)!),
    );
  }

  return null;
}

DateTime? _validDate(int? year, int? month, int? day) {
  if (year == null || month == null || day == null) {
    return null;
  }

  final DateTime candidate = DateTime(year, month, day);
  if (candidate.year != year ||
      candidate.month != month ||
      candidate.day != day) {
    return null;
  }

  return candidate;
}

int _toInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _toBool(Object? value) {
  if (value is bool) {
    return value;
  }

  final String normalized = value?.toString().trim().toLowerCase() ?? '';
  return normalized == 'true' || normalized == '1' || normalized == 'y';
}
