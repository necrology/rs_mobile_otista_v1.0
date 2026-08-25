import 'package:equatable/equatable.dart';

import 'api_collection.dart';

class PatientMedicalSummaryRecord extends Equatable {
  const PatientMedicalSummaryRecord({required this.data});

  final Map<String, dynamic> data;

  factory PatientMedicalSummaryRecord.fromJson(Map<String, dynamic> json) {
    return PatientMedicalSummaryRecord(data: json);
  }

  String get id => ApiResponseReader.stringValue(data, const <String>['id']);

  String get registrationId => ApiResponseReader.stringValue(
    data,
    const <String>['registrasi_id', 'registration_id'],
    fallback: id,
  );

  String get registration => ApiResponseReader.stringValue(data, const <String>[
    'reg_id',
    'registration',
  ]);

  String get visitDate => ApiResponseReader.stringValue(data, const <String>[
    'tanggal_kunjungan',
    'visit_date',
  ]);

  String get polyclinic =>
      ApiResponseReader.stringValue(data, const <String>['poli', 'polyclinic']);

  String get doctor =>
      ApiResponseReader.stringValue(data, const <String>['dokter', 'doctor']);

  String get diagnosis => ApiResponseReader.stringValue(data, const <String>[
    'diagnosa',
    'diagnosis',
  ]);

  String get action =>
      ApiResponseReader.stringValue(data, const <String>['tindakan', 'action']);

  String get note =>
      ApiResponseReader.stringValue(data, const <String>['keterangan', 'note']);

  String get title {
    if (diagnosis != '-') {
      return diagnosis;
    }
    return 'Diagnosis & Tindakan';
  }

  String get subtitle {
    return <String>[visitDate, polyclinic == '-' ? '' : polyclinic]
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
    add('Poli', polyclinic);
    add('Dokter', doctor);
    add('Diagnosis (ICD-10)', diagnosis);
    add('Tindakan (ICD-9)', action);
    add('Keterangan', note);

    return fields;
  }

  @override
  List<Object?> get props => <Object?>[data];
}
