import 'package:equatable/equatable.dart';

import 'api_collection.dart';

class PatientRadiologyResultRecord extends Equatable {
  const PatientRadiologyResultRecord({required this.data});

  final Map<String, dynamic> data;

  factory PatientRadiologyResultRecord.fromJson(Map<String, dynamic> json) {
    return PatientRadiologyResultRecord(data: json);
  }

  String get id => ApiResponseReader.stringValue(data, const <String>['id']);

  String get registration =>
      ApiResponseReader.stringValue(data, const <String>['reg_id']);

  String get visitDate =>
      ApiResponseReader.stringValue(data, const <String>['tanggal_kunjungan']);

  String get polyclinic =>
      ApiResponseReader.stringValue(data, const <String>['poli']);

  String get doctor =>
      ApiResponseReader.stringValue(data, const <String>['dokter']);

  String get documentNumber =>
      ApiResponseReader.stringValue(data, const <String>['no_dokument']);

  String get examDate =>
      ApiResponseReader.stringValue(data, const <String>['tanggal_periksa']);

  String get resultDate =>
      ApiResponseReader.stringValue(data, const <String>['tanggal_ekspertise']);

  String get examination =>
      ApiResponseReader.stringValue(data, const <String>['pemeriksaan']);

  String get orderType =>
      ApiResponseReader.stringValue(data, const <String>['jenis_order']);

  String get status =>
      ApiResponseReader.stringValue(data, const <String>['status']);

  String get source =>
      ApiResponseReader.stringValue(data, const <String>['source']);

  String get clinicalNote =>
      ApiResponseReader.stringValue(data, const <String>['klinis']);

  String get resultSummary =>
      ApiResponseReader.stringValue(data, const <String>['resume']);

  String get expertise =>
      ApiResponseReader.stringValue(data, const <String>['ekspertise']);

  String get orderCreatedAt =>
      ApiResponseReader.stringValue(data, const <String>['order_created_at']);

  String get resultCreatedAt =>
      ApiResponseReader.stringValue(data, const <String>['result_created_at']);

  String get statusLabel {
    switch (status.trim().toUpperCase()) {
      case 'Y':
        return 'Selesai';
      case 'N':
        return 'Belum selesai';
      case 'D':
        return 'Dalam proses';
      default:
        return _hasValue(status) ? status : '-';
    }
  }

  String get title {
    if (_hasValue(examination)) {
      return examination;
    }
    if (_hasValue(documentNumber)) {
      return 'Radiologi $documentNumber';
    }
    return 'Hasil Radiologi';
  }

  String get subtitle {
    return <String>[
      resultDate,
      examDate,
      polyclinic,
    ].where(_hasValue).join(' - ');
  }

  List<MapEntry<String, String>> get displayFields {
    final List<MapEntry<String, String>> fields = <MapEntry<String, String>>[];

    void add(String label, String value) {
      if (!_hasValue(value)) {
        return;
      }
      fields.add(MapEntry<String, String>(label, value.trim()));
    }

    add('No. Dokumen', documentNumber);
    add('No. Registrasi', registration);
    add('Tanggal Kunjungan', visitDate);
    add('Poli', polyclinic);
    add('Dokter', doctor);
    add('Tanggal Periksa', examDate);
    add('Tanggal Ekspertise', resultDate);
    add('Pemeriksaan', examination);
    add('Jenis Order', orderType);
    add('Status', statusLabel);
    add('Sumber Order', source);
    add('Keterangan Klinis', clinicalNote);
    add('Resume Radiologi', resultSummary);
    add('Ekspertise', expertise);
    add('Waktu Order', orderCreatedAt);
    add('Waktu Hasil', resultCreatedAt);

    return fields;
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


