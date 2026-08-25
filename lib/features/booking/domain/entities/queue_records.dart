import 'package:equatable/equatable.dart';

import '../../../../core/utils/date_format_utils.dart';
import '../../../api_data/domain/entities/api_collection.dart';

class QueueRegistrationRecord extends Equatable {
  const QueueRegistrationRecord({required this.data});

  final Map<String, dynamic> data;

  factory QueueRegistrationRecord.fromJson(Map<String, dynamic> json) {
    return QueueRegistrationRecord(data: json);
  }

  String get id => ApiResponseReader.stringValue(data, const <String>['id']);

  String get bookingCode => ApiResponseReader.stringValue(data, const <String>[
    'kodebooking',
    'kode_booking',
    'registration_code',
    'reg_id',
  ]);

  String get queueNumber => ApiResponseReader.stringValue(data, const <String>[
    'nomorantrian',
    'nomor_antrian',
    'queue_number',
  ]);

  String get noRm => ApiResponseReader.stringValue(data, const <String>[
    'no_rm',
    'norm',
    'rekam_medis',
  ]);

  String get patientName => ApiResponseReader.stringValue(data, const <String>[
    'nama',
    'nama_pasien',
    'patient_name',
  ]);

  String get visitDate => ApiResponseReader.stringValue(data, const <String>[
    'tglperiksa',
    'tanggal_kunjungan',
    'queue_date',
    'created_at',
  ]);

  String get poliCode => ApiResponseReader.stringValue(data, const <String>[
    'kode_poli',
    'poli_code',
  ]);

  String get doctorCode => ApiResponseReader.stringValue(data, const <String>[
    'kode_dokter',
    'doctor_code',
  ]);

  String get status =>
      ApiResponseReader.stringValue(data, const <String>['status']);

  String get requestType => ApiResponseReader.stringValue(data, const <String>[
    'jenisrequest',
    'jenis_request',
    'request_type',
  ]);

  String get request =>
      ApiResponseReader.stringValue(data, const <String>['request']);

  String get title {
    if (_hasValue(patientName)) {
      return patientName;
    }
    if (_hasValue(bookingCode)) {
      return bookingCode;
    }
    return 'Antrian Registrasi';
  }

  String get subtitle {
    final List<String> parts = <String>[
      if (_hasValue(queueNumber)) queueNumber,
      if (_hasValue(visitDate)) DateFormatUtils.formatDisplay(visitDate),
    ];
    return parts.join(' - ');
  }

  List<MapEntry<String, String>> get displayFields {
    final List<MapEntry<String, String>> fields = <MapEntry<String, String>>[];

    void add(String label, String value) {
      if (!_hasValue(value)) {
        return;
      }
      fields.add(MapEntry<String, String>(label, value.trim()));
    }

    add('Kode Booking', bookingCode);
    add('No. Antrian', queueNumber);
    add('No. RM', noRm);
    add('Nama Pasien', patientName);
    add('Tanggal Periksa', DateFormatUtils.formatDisplay(visitDate));
    add('Kode Poli', poliCode);
    add('Kode Dokter', doctorCode);
    add('Status', status);
    add('Jenis Request', requestType);
    add('Request', request);

    return fields;
  }

  bool get isJkn {
    final String normalizedRequest = request.toLowerCase();
    final String normalizedType = requestType.toLowerCase();
    return normalizedType == '1' ||
        normalizedType == '2' ||
        normalizedRequest.contains('mobile_jkn');
  }

  @override
  List<Object?> get props => <Object?>[data];
}

class LocalQueueRecord extends Equatable {
  const LocalQueueRecord({required this.data});

  final Map<String, dynamic> data;

  factory LocalQueueRecord.fromJson(Map<String, dynamic> json) {
    return LocalQueueRecord(data: json);
  }

  String get id => ApiResponseReader.stringValue(data, const <String>['id']);
  String get bagian =>
      ApiResponseReader.stringValue(data, const <String>['bagian']);
  String get antrian =>
      ApiResponseReader.stringValue(data, const <String>['antrian']);
  String get tanggal =>
      ApiResponseReader.stringValue(data, const <String>['tanggal']);
  String get status =>
      ApiResponseReader.stringValue(data, const <String>['status']);
  String get createdAt =>
      ApiResponseReader.stringValue(data, const <String>['created_at']);
  String get updatedAt =>
      ApiResponseReader.stringValue(data, const <String>['updated_at']);

  String get subtitle =>
      <String>[antrian, DateFormatUtils.formatDisplay(tanggal)]
          .where((String value) => value.trim().isNotEmpty && value != '-')
          .join(' - ');

  List<MapEntry<String, String>> get displayFields {
    final List<MapEntry<String, String>> fields = <MapEntry<String, String>>[];

    void add(String label, String value) {
      final String normalized = value.trim();
      if (normalized.isEmpty || normalized == '-') {
        return;
      }
      fields.add(MapEntry<String, String>(label, normalized));
    }

    add('Bagian', bagian);
    add('Antrian', antrian);
    add('Tanggal', DateFormatUtils.formatDisplay(tanggal));
    add('Status', status);
    add('Created', DateFormatUtils.formatDisplay(createdAt));
    add('Updated', DateFormatUtils.formatDisplay(updatedAt));

    return fields;
  }

  @override
  List<Object?> get props => <Object?>[data];
}

class GeneralBookingRecord extends Equatable {
  const GeneralBookingRecord({required this.data});

  final Map<String, dynamic> data;

  factory GeneralBookingRecord.fromJson(Map<String, dynamic> json) {
    return GeneralBookingRecord(data: json);
  }

  String get registrationId =>
      ApiResponseReader.stringValue(data, const <String>['registration_id']);

  String get dummyId =>
      ApiResponseReader.stringValue(data, const <String>['dummy_id']);

  String get source => ApiResponseReader.stringValue(data, const <String>[
    'source',
    'input_from',
  ]);

  String get registrationCode =>
      ApiResponseReader.stringValue(data, const <String>['registration_code']);

  String get queueNumber => ApiResponseReader.stringValue(data, const <String>[
    'queue_code',
    'queue_number',
  ]);

  String get queueGroup =>
      ApiResponseReader.stringValue(data, const <String>['queue_group']);

  String get queueDate =>
      ApiResponseReader.stringValue(data, const <String>['queue_date']);

  String get createdAt =>
      ApiResponseReader.stringValue(data, const <String>['created_at']);

  String get status => _normalizeBookingStatus(
    ApiResponseReader.stringValue(data, const <String>[
      'queue_status_label',
      'status_reg',
      'registration_status',
    ]),
  );

  String get noRm =>
      ApiResponseReader.stringValue(data, const <String>['no_rm']);

  String get patientName =>
      ApiResponseReader.stringValue(data, const <String>['nama_pasien']);

  String get polyclinic =>
      ApiResponseReader.stringValue(data, const <String>['poli_name']);

  String get doctor =>
      ApiResponseReader.stringValue(data, const <String>['nama_dokter']);

  String get patientType => _normalizePatientType(
    ApiResponseReader.stringValue(data, const <String>['jenis_pasien']),
  );

  String get paymentType => _normalizePaymentType(
    ApiResponseReader.stringValue(data, const <String>['bayar']),
  );

  String get note =>
      ApiResponseReader.stringValue(data, const <String>['keterangan']);

  String get title {
    if (_hasValue(queueNumber)) {
      return queueNumber;
    }
    return 'Antrian Umum';
  }

  String get subtitle {
    return <String>[patientName, noRm, polyclinic].where(_hasValue).join(' - ');
  }

  List<MapEntry<String, String>> get displayFields {
    final List<MapEntry<String, String>> fields = <MapEntry<String, String>>[];

    void add(String label, String value) {
      if (!_hasValue(value)) {
        return;
      }
      fields.add(MapEntry<String, String>(label, value.trim()));
    }

    add('No. Antrian', queueNumber);
    add('Kode Registrasi', registrationCode);
    add('No. RM', noRm);
    add('Nama Pasien', patientName);
    add('Tanggal', DateFormatUtils.formatDisplay(queueDate));
    add('Poli', polyclinic);
    add('Dokter', doctor);
    add('Kelompok', queueGroup);
    add('Jenis Pasien', patientType);
    add('Status', status);
    add('Cara Bayar', paymentType);
    add('Sumber', _normalizeBookingSource(source));
    add('Catatan', note);
    add('Dibuat', DateFormatUtils.formatDisplay(createdAt));

    return fields;
  }

  ColorRole get colorRole {
    switch (status.toLowerCase()) {
      case 'dipanggil':
        return ColorRole.blue;
      case 'selesai':
        return ColorRole.green;
      case 'batal':
        return ColorRole.red;
      default:
        return ColorRole.orange;
    }
  }

  @override
  List<Object?> get props => <Object?>[data];
}

enum ColorRole { blue, green, orange, red }

bool _hasValue(String value) {
  final String normalized = value.trim();
  return normalized.isNotEmpty &&
      normalized != '-' &&
      normalized != '0000-00-00';
}

String _normalizePatientType(String value) {
  final String normalized = value.trim().toLowerCase();
  switch (normalized) {
    case 'umum':
    case 'u':
    case '2':
      return 'Umum';
    case 'jkn':
    case 'bpjs':
    case '1':
      return 'JKN/BPJS';
    default:
      return value;
  }
}

String _normalizePaymentType(String value) {
  final String normalized = value.trim().toLowerCase();
  switch (normalized) {
    case '1':
    case 'bpjs':
    case 'jkn':
      return 'JKN/BPJS';
    case '2':
    case 'umum':
      return 'Umum';
    default:
      return value;
  }
}

String _normalizeBookingStatus(String value) {
  final String normalized = value.trim().toLowerCase();
  switch (normalized) {
    case 'menunggu':
    case 'baru':
    case 'pending':
    case 'terdaftar':
    case 'checkin':
    case '0':
      return 'Menunggu';
    case 'dipanggil':
    case 'dilayani':
    case '1':
      return 'Dipanggil';
    case 'selesai':
    case 'selesai_dilayani':
    case '2':
      return 'Selesai';
    case 'batal':
    case 'dibatalkan':
      return 'Batal';
    default:
      return value;
  }
}

String _normalizeBookingSource(String value) {
  final String normalized = value.trim().toLowerCase();
  switch (normalized) {
    case 'mobile_umum':
      return 'Mobile Umum';
    case 'mobile':
      return 'Mobile';
    default:
      return value;
  }
}
