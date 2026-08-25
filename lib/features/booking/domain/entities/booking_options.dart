import 'package:equatable/equatable.dart';

import '../../../api_data/domain/entities/api_collection.dart';

class BookingOptionsResponse extends Equatable {
  const BookingOptionsResponse({required this.poli});

  factory BookingOptionsResponse.fromJson(Map<String, dynamic> json) {
    final dynamic rawPoli = json['poli'];
    final Map<String, dynamic> poliMap = rawPoli is Map<dynamic, dynamic>
        ? rawPoli.map(
            (dynamic key, dynamic value) =>
                MapEntry<String, dynamic>(key.toString(), value),
          )
        : json;

    return BookingOptionsResponse(poli: BookingPoliOption.fromJson(poliMap));
  }

  final BookingPoliOption poli;

  @override
  List<Object?> get props => <Object?>[poli];
}

class BookingPoliOption extends Equatable {
  const BookingPoliOption({
    required this.data,
    required this.doctors,
    required this.schedules,
  });

  factory BookingPoliOption.fromJson(Map<String, dynamic> json) {
    final dynamic rawDoctors = json['dokter_list'];
    final List<BookingDoctorOption> doctors = rawDoctors is List<dynamic>
        ? rawDoctors
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (Map<dynamic, dynamic> item) => BookingDoctorOption.fromJson(
                  item.map(
                    (dynamic key, dynamic value) =>
                        MapEntry<String, dynamic>(key.toString(), value),
                  ),
                ),
              )
              .toList()
        : <BookingDoctorOption>[];

    final List<BookingScheduleOption> schedules = _scheduleListFromJson(
      json['jadwal_list'],
    );

    return BookingPoliOption(
      data: json,
      doctors: doctors,
      schedules: schedules,
    );
  }

  final Map<String, dynamic> data;
  final List<BookingDoctorOption> doctors;
  final List<BookingScheduleOption> schedules;

  String get id => ApiResponseReader.stringValue(data, const <String>['id']);
  String get name =>
      ApiResponseReader.stringValue(data, const <String>['nama']);
  String get queueGroup => ApiResponseReader.stringValue(data, const <String>[
    'queue_group',
    'kelompok',
    'kode_ruangan',
    'nama',
  ], fallback: '');
  String get openTime =>
      ApiResponseReader.stringValue(data, const <String>['buka'], fallback: '');
  String get closeTime => ApiResponseReader.stringValue(data, const <String>[
    'tutup',
  ], fallback: '');
  String get practice => ApiResponseReader.stringValue(data, const <String>[
    'praktik',
  ], fallback: '');

  int get quota => _intValue(const <String>['kuota']);
  int get onlineQuota => _intValue(const <String>['kuota_online']);
  int get filled => _intValue(const <String>['terisi']);
  int get remaining {
    final int baseQuota = onlineQuota > 0 ? onlineQuota : quota;
    if (baseQuota <= 0) {
      return 0;
    }
    final int value = baseQuota - filled;
    return value < 0 ? 0 : value;
  }

  String get scheduleLabel {
    final List<String> parts = <String>[
      if (practice.trim().isNotEmpty && practice != '-') practice,
      if (openTime.trim().isNotEmpty || closeTime.trim().isNotEmpty)
        '$openTime - $closeTime'.replaceAll(RegExp(r'(^\s*-\s*|\s*-\s*$)'), ''),
    ];
    return parts.where((String value) => value.trim().isNotEmpty).join(' | ');
  }

  int _intValue(List<String> keys) {
    for (final String key in keys) {
      final dynamic rawValue = data[key];
      if (rawValue is int) {
        return rawValue;
      }
      if (rawValue is num) {
        return rawValue.toInt();
      }
      final int? parsed = int.tryParse(rawValue?.toString().trim() ?? '');
      if (parsed != null) {
        return parsed;
      }
    }
    return 0;
  }

  @override
  List<Object?> get props => <Object?>[data, doctors, schedules];
}

class BookingDoctorOption extends Equatable {
  const BookingDoctorOption({required this.data, required this.schedules});

  factory BookingDoctorOption.fromJson(Map<String, dynamic> json) {
    return BookingDoctorOption(
      data: json,
      schedules: _scheduleListFromJson(json['jadwal']),
    );
  }

  final Map<String, dynamic> data;
  final List<BookingScheduleOption> schedules;

  String get id => ApiResponseReader.stringValue(data, const <String>['id']);
  String get name =>
      ApiResponseReader.stringValue(data, const <String>['nama']);
  String get queueCode => ApiResponseReader.stringValue(data, const <String>[
    'kode_antrian',
    'general_code',
    'kode_bpjs',
  ], fallback: '');

  String get displayName {
    if (queueCode.trim().isEmpty || queueCode == '-') {
      return name;
    }
    return '$name ($queueCode)';
  }

  @override
  List<Object?> get props => <Object?>[data, schedules];
}

class BookingScheduleOption extends Equatable {
  const BookingScheduleOption({required this.data});

  factory BookingScheduleOption.fromJson(Map<String, dynamic> json) {
    return BookingScheduleOption(data: json);
  }

  final Map<String, dynamic> data;

  String get source => ApiResponseReader.stringValue(data, const <String>[
    'source',
  ], fallback: '');

  String get day =>
      ApiResponseReader.stringValue(data, const <String>['hari'], fallback: '');

  int get dayIndex => _intValue(const <String>['day_index']);

  String get openTime =>
      ApiResponseReader.stringValue(data, const <String>['buka'], fallback: '');

  String get closeTime => ApiResponseReader.stringValue(data, const <String>[
    'tutup',
  ], fallback: '');

  String get doctorId => ApiResponseReader.stringValue(data, const <String>[
    'dokter_id',
    'doctor_id',
  ], fallback: '');

  String get doctorName => ApiResponseReader.stringValue(data, const <String>[
    'nama_dokter',
    'doctor_name',
  ], fallback: '');

  int get quota => _intValue(const <String>['kuota']);

  bool get isPractice {
    final String value = ApiResponseReader.stringValue(data, const <String>[
      'praktik',
    ], fallback: '').toLowerCase();
    return value == 'true' || value == '1' || value == 'y';
  }

  String get timeLabel {
    final String start = _cleanTime(openTime);
    final String end = _cleanTime(closeTime);
    if (start.isEmpty && end.isEmpty) {
      return '';
    }
    if (start.isEmpty) {
      return 'Sampai $end';
    }
    if (end.isEmpty) {
      return 'Mulai $start';
    }
    return '$start - $end';
  }

  String get displayLabel {
    final List<String> parts = <String>[
      if (day.trim().isNotEmpty) day,
      if (timeLabel.trim().isNotEmpty) timeLabel,
      if (quota > 0) 'Kuota $quota',
    ];
    return parts.join(' | ');
  }

  int _intValue(List<String> keys) {
    for (final String key in keys) {
      final dynamic rawValue = data[key];
      if (rawValue is int) {
        return rawValue;
      }
      if (rawValue is num) {
        return rawValue.toInt();
      }
      final int? parsed = int.tryParse(rawValue?.toString().trim() ?? '');
      if (parsed != null) {
        return parsed;
      }
    }
    return 0;
  }

  String _cleanTime(String value) {
    final String normalizedValue = value.trim();
    if (normalizedValue.isEmpty ||
        normalizedValue == '-' ||
        normalizedValue == '00:00:00') {
      return '';
    }
    return normalizedValue.replaceAllMapped(
      RegExp(r'(?<!\d)(\d{2}):(\d{2}):(\d{2})(?!\d)'),
      (Match match) => '${match[1]}:${match[2]}',
    );
  }

  @override
  List<Object?> get props => <Object?>[data];
}

List<BookingScheduleOption> _scheduleListFromJson(dynamic rawValue) {
  if (rawValue is! List<dynamic>) {
    return <BookingScheduleOption>[];
  }

  return rawValue
      .whereType<Map<dynamic, dynamic>>()
      .map(
        (Map<dynamic, dynamic> item) => BookingScheduleOption.fromJson(
          item.map(
            (dynamic key, dynamic value) =>
                MapEntry<String, dynamic>(key.toString(), value),
          ),
        ),
      )
      .toList();
}
