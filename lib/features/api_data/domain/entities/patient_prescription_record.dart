import 'package:equatable/equatable.dart';

import 'api_collection.dart';

class PatientPrescriptionRecord extends Equatable {
  const PatientPrescriptionRecord({required this.data});

  final Map<String, dynamic> data;

  factory PatientPrescriptionRecord.fromJson(Map<String, dynamic> json) {
    return PatientPrescriptionRecord(data: json);
  }

  String get id => ApiResponseReader.stringValue(data, const <String>['id']);

  String get noResep =>
      ApiResponseReader.stringValue(data, const <String>['no_resep']);

  String get registration =>
      ApiResponseReader.stringValue(data, const <String>['reg_id']);

  String get visitDate =>
      ApiResponseReader.stringValue(data, const <String>['tanggal_kunjungan']);

  String get polyclinic =>
      ApiResponseReader.stringValue(data, const <String>['poli']);

  String get doctor =>
      ApiResponseReader.stringValue(data, const <String>['dokter']);

  String get createdAt =>
      ApiResponseReader.stringValue(data, const <String>['created_at']);

  String get status =>
      ApiResponseReader.stringValue(data, const <String>['status']);

  String get note =>
      ApiResponseReader.stringValue(data, const <String>['catatan']);

  List<PatientPrescriptionDetailRecord> get details {
    final dynamic rawDetails = data['rincian'];
    if (rawDetails is! List<dynamic>) {
      return const <PatientPrescriptionDetailRecord>[];
    }

    return rawDetails
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (Map<dynamic, dynamic> item) => PatientPrescriptionDetailRecord(
            data: item.map(
              (dynamic key, dynamic value) =>
                  MapEntry<String, dynamic>(key.toString(), value),
            ),
          ),
        )
        .toList();
  }

  String get title {
    if (_hasValue(noResep)) {
      return 'Resep $noResep';
    }
    return 'Resep Obat';
  }

  String get subtitle {
    return <String>[createdAt, polyclinic, doctor].where(_hasValue).join(' - ');
  }

  String get statusLabel {
    final String normalized = status.trim().toUpperCase();
    if (normalized == 'Y' || normalized == '1' || normalized == 'DONE') {
      return 'Selesai input';
    }
    if (normalized == 'N' || normalized == '0') {
      return 'Belum selesai';
    }
    return _hasValue(status) ? status : '-';
  }

  List<MapEntry<String, String>> get displayFields {
    final List<MapEntry<String, String>> fields = <MapEntry<String, String>>[];

    void add(String label, String value) {
      if (!_hasValue(value)) {
        return;
      }
      fields.add(MapEntry<String, String>(label, value.trim()));
    }

    add('No. Resep', noResep);
    add('No. Registrasi', registration);
    add('Tanggal Kunjungan', visitDate);
    add('Poli', polyclinic);
    add('Dokter', doctor);
    add('Tanggal Resep', createdAt);
    add('Status', statusLabel);
    add('Catatan', note);

    final List<PatientPrescriptionDetailRecord> detailItems = details;
    if (detailItems.isNotEmpty) {
      add('Jumlah Obat', '${detailItems.length} item');
      for (final PatientPrescriptionDetailRecord detail in detailItems.take(
        40,
      )) {
        add(detail.displayName, detail.summary);
      }
    }

    return fields;
  }

  @override
  List<Object?> get props => <Object?>[data];
}

class PatientPrescriptionDetailRecord extends Equatable {
  const PatientPrescriptionDetailRecord({required this.data});

  final Map<String, dynamic> data;

  String get drugName =>
      ApiResponseReader.stringValue(data, const <String>['nama_obat']);

  String get drugCode =>
      ApiResponseReader.stringValue(data, const <String>['kode_obat']);

  String get unit =>
      ApiResponseReader.stringValue(data, const <String>['satuan']);

  String get quantity =>
      ApiResponseReader.stringValue(data, const <String>['jumlah']);

  String get howToUse =>
      ApiResponseReader.stringValue(data, const <String>['cara_minum']);

  String get dose =>
      ApiResponseReader.stringValue(data, const <String>['takaran']);

  String get primaryInfo =>
      ApiResponseReader.stringValue(data, const <String>['informasi1']);

  String get extraInfo =>
      ApiResponseReader.stringValue(data, const <String>['informasi2']);

  String get note =>
      ApiResponseReader.stringValue(data, const <String>['catatan']);

  String get label =>
      ApiResponseReader.stringValue(data, const <String>['etiket']);

  String get compound =>
      ApiResponseReader.stringValue(data, const <String>['obat_racikan']);

  String get chronic =>
      ApiResponseReader.stringValue(data, const <String>['is_kronis']);

  String get displayName {
    if (_hasValue(drugName)) {
      return drugName;
    }
    if (_hasValue(drugCode)) {
      return drugCode;
    }
    return 'Obat';
  }

  String get summary {
    final List<String> parts = <String>[
      if (_hasValue(quantity)) 'Jumlah $quantity',
      if (_hasValue(unit)) unit,
      if (_hasValue(dose)) dose,
      if (_hasValue(howToUse)) howToUse,
      if (_hasValue(primaryInfo)) primaryInfo,
      if (_hasValue(extraInfo)) extraInfo,
      if (_hasValue(note)) note,
    ];

    return parts.isEmpty ? '-' : parts.join(' | ');
  }

  @override
  List<Object?> get props => <Object?>[data];
}

bool _hasValue(String value) {
  final String normalizedValue = value.trim();
  return normalizedValue.isNotEmpty &&
      normalizedValue != '-' &&
      normalizedValue != '0000-00-00';
}
