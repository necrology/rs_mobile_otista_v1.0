import 'package:equatable/equatable.dart';

import 'api_collection.dart';

class PatientVisitRecord extends Equatable {
  const PatientVisitRecord({required this.data});

  final Map<String, dynamic> data;

  factory PatientVisitRecord.fromJson(Map<String, dynamic> json) {
    return PatientVisitRecord(data: json);
  }

  String get id => ApiResponseReader.stringValue(data, const <String>['id']);

  String get registrationId => id;

  String get registration => ApiResponseReader.stringValue(data, const <String>[
    'reg_id',
    'registration',
  ]);

  String get queueNumber => ApiResponseReader.stringValue(data, const <String>[
    'nomorantrian',
    'queue_number',
  ]);

  String get visitDate => ApiResponseReader.stringValue(data, const <String>[
    'tanggal_kunjungan',
    'visit_date',
    'tgl_order',
    'created_at',
  ]);

  String get createdAt =>
      ApiResponseReader.stringValue(data, const <String>['created_at']);

  String get finishedAt => ApiResponseReader.stringValue(data, const <String>[
    'tgl_pulang',
    'finished_at',
  ]);

  String get patientType => _normalizePatientType(
    ApiResponseReader.stringValue(data, const <String>[
      'jenis_pasien',
      'patient_type',
    ]),
  );

  String get paymentType => _normalizePaymentType(
    ApiResponseReader.stringValue(data, const <String>[
      'bayar',
      'payment_type',
    ]),
  );

  String get serviceType => ApiResponseReader.stringValue(data, const <String>[
    'tipe_rawat',
    'service_type',
  ]);

  String get status => _normalizeVisitStatus(
    ApiResponseReader.stringValue(data, const <String>['status']),
  );

  String get polyclinic =>
      ApiResponseReader.stringValue(data, const <String>['poli', 'polyclinic']);

  String get doctor =>
      ApiResponseReader.stringValue(data, const <String>['dokter', 'doctor']);

  String get queueGroup => ApiResponseReader.stringValue(data, const <String>[
    'kelompok_antrian',
    'queue_group',
  ]);

  String get classGroup => ApiResponseReader.stringValue(data, const <String>[
    'kelas_rawat',
    'class_group',
  ]);

  String get roomName =>
      ApiResponseReader.stringValue(data, const <String>['kamar', 'room']);

  String get bedName =>
      ApiResponseReader.stringValue(data, const <String>['bed']);

  String get inpatientSince => ApiResponseReader.stringValue(
    data,
    const <String>['tgl_masuk_rawat_inap', 'inpatient_since'],
  );

  bool get isInpatient {
    final String aggregate = '$serviceType $classGroup $roomName $bedName'
        .toLowerCase();
    return aggregate.contains('inap') ||
        classGroup != '-' ||
        roomName != '-' ||
        bedName != '-';
  }

  String get title {
    if (polyclinic != '-') {
      return polyclinic;
    }
    if (serviceType != '-') {
      return serviceType;
    }
    return 'Kunjungan Pasien';
  }

  String get subtitle {
    return <String>[visitDate, doctor == '-' ? '' : doctor]
        .where((String value) {
          final String normalizedValue = value.trim();
          return normalizedValue.isNotEmpty && normalizedValue != '-';
        })
        .join(' - ');
  }

  List<MapEntry<String, String>> get displayFields {
    final List<MapEntry<String, String>> fields = <MapEntry<String, String>>[];

    void add(String label, String value) {
      final String normalizedValue = value.trim();
      if (normalizedValue.isEmpty || normalizedValue == '-') {
        return;
      }
      fields.add(MapEntry<String, String>(label, normalizedValue));
    }

    add('Tanggal Kunjungan', visitDate);
    add('No. Registrasi', registration);
    add('No. Antrian', queueNumber);
    add('Kelompok Antrian', queueGroup);
    add('Poli', polyclinic);
    add('Dokter', doctor);
    add('Tipe Rawat', serviceType);
    add('Kelas Rawat Inap', classGroup);
    add('Kamar', roomName);
    add('Bed', bedName);
    add('Masuk Rawat Inap', inpatientSince);
    add('Jenis Pasien', patientType);
    add('Cara Bayar', paymentType);
    add('Status', status);
    add('Waktu Daftar', createdAt);
    add('Waktu Pulang', finishedAt);

    return fields;
  }

  @override
  List<Object?> get props => <Object?>[data];
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

String _normalizeVisitStatus(String value) {
  final String normalized = value.trim().toLowerCase();
  switch (normalized) {
    case 'baru':
      return 'Baru';
    case 'selesai':
      return 'Selesai';
    case 'batal':
      return 'Batal';
    default:
      return value;
  }
}
