import 'package:equatable/equatable.dart';

import 'api_collection.dart';

class PatientLabResultRecord extends Equatable {
  const PatientLabResultRecord({required this.data});

  final Map<String, dynamic> data;

  factory PatientLabResultRecord.fromJson(Map<String, dynamic> json) {
    return PatientLabResultRecord(data: json);
  }

  String get id => ApiResponseReader.stringValue(data, const <String>['id']);

  String get noLab =>
      ApiResponseReader.stringValue(data, const <String>['no_lab']);

  String get registration =>
      ApiResponseReader.stringValue(data, const <String>['reg_id']);

  String get visitDate =>
      ApiResponseReader.stringValue(data, const <String>['tanggal_kunjungan']);

  String get polyclinic =>
      ApiResponseReader.stringValue(data, const <String>['poli']);

  String get doctor =>
      ApiResponseReader.stringValue(data, const <String>['dokter']);

  String get responsible =>
      ApiResponseReader.stringValue(data, const <String>['penanggungjawab']);

  String get examDate =>
      ApiResponseReader.stringValue(data, const <String>['tgl_pemeriksaan']);

  String get receivedDate =>
      ApiResponseReader.stringValue(data, const <String>['tgl_bahanditerima']);

  String get resultDate =>
      ApiResponseReader.stringValue(data, const <String>['tgl_hasilselesai']);

  String get printDate =>
      ApiResponseReader.stringValue(data, const <String>['tgl_cetak']);

  String get startTime =>
      ApiResponseReader.stringValue(data, const <String>['jam']);

  String get finishTime =>
      ApiResponseReader.stringValue(data, const <String>['jamkeluar']);

  String get sample =>
      ApiResponseReader.stringValue(data, const <String>['sample']);

  String get message =>
      ApiResponseReader.stringValue(data, const <String>['pesan']);

  String get impression =>
      ApiResponseReader.stringValue(data, const <String>['kesan']);

  String get suggestion =>
      ApiResponseReader.stringValue(data, const <String>['saran']);

  String get orderExaminations =>
      ApiResponseReader.stringValue(data, const <String>['pemeriksaan_order']);

  String get labType =>
      ApiResponseReader.stringValue(data, const <String>['tipe_lab']);

  String get diagnosis =>
      ApiResponseReader.stringValue(data, const <String>['diagnosa']);

  List<PatientLabResultDetailRecord> get details {
    final dynamic rawDetails = data['rincian'];
    if (rawDetails is! List<dynamic>) {
      return const <PatientLabResultDetailRecord>[];
    }

    return rawDetails
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (Map<dynamic, dynamic> item) => PatientLabResultDetailRecord(
            data: item.map(
              (dynamic key, dynamic value) =>
                  MapEntry<String, dynamic>(key.toString(), value),
            ),
          ),
        )
        .toList();
  }

  String get title {
    if (_hasValue(noLab)) {
      return 'Lab $noLab';
    }
    if (_hasValue(orderExaminations)) {
      return orderExaminations;
    }
    return 'Hasil Laboratorium';
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

    add('No. Lab', noLab);
    add('No. Registrasi', registration);
    add('Tanggal Kunjungan', visitDate);
    add('Poli', polyclinic);
    add('Dokter', doctor);
    add('Penanggung Jawab', responsible);
    add('Tanggal Pemeriksaan', examDate);
    add('Bahan Diterima', receivedDate);
    add('Hasil Selesai', resultDate);
    add('Tanggal Cetak', printDate);
    add('Jam Masuk', startTime);
    add('Jam Keluar', finishTime);
    add('Sampel', sample);
    add('Pemeriksaan Order', orderExaminations);
    add('Jenis Lab', labType);
    add('Diagnosis Order', diagnosis);
    add('Pesan', message);
    add('Kesan', impression);
    add('Saran', suggestion);

    final List<PatientLabResultDetailRecord> detailItems = details;
    if (detailItems.isNotEmpty) {
      add('Jumlah Rincian', '${detailItems.length} pemeriksaan');
      for (final PatientLabResultDetailRecord detail in detailItems.take(30)) {
        add(detail.displayName, detail.resultSummary);
      }
    }

    return fields;
  }

  @override
  List<Object?> get props => <Object?>[data];
}

class PatientLabResultDetailRecord extends Equatable {
  const PatientLabResultDetailRecord({required this.data});

  final Map<String, dynamic> data;

  String get section =>
      ApiResponseReader.stringValue(data, const <String>['section']);

  String get category =>
      ApiResponseReader.stringValue(data, const <String>['kategori']);

  String get examination =>
      ApiResponseReader.stringValue(data, const <String>['pemeriksaan']);

  String get reference =>
      ApiResponseReader.stringValue(data, const <String>['rujukan']);

  String get referenceLow => ApiResponseReader.stringValue(data, const <String>[
    'nilai_rujukan_bawah',
  ]);

  String get referenceHigh =>
      ApiResponseReader.stringValue(data, const <String>['nilai_rujukan_atas']);

  String get unit =>
      ApiResponseReader.stringValue(data, const <String>['satuan']);

  String get resultText =>
      ApiResponseReader.stringValue(data, const <String>['hasil_text']);

  String get resultValue =>
      ApiResponseReader.stringValue(data, const <String>['hasil']);

  String get displayName {
    if (_hasValue(examination)) {
      return examination;
    }
    if (_hasValue(category)) {
      return category;
    }
    if (_hasValue(section)) {
      return section;
    }
    return 'Rincian Pemeriksaan';
  }

  String get resultSummary {
    final String result = _hasValue(resultText) ? resultText : resultValue;
    final String referenceValue = referenceSummary;
    final List<String> parts = <String>[
      if (_hasValue(result)) result,
      if (_hasValue(referenceValue)) 'Rujukan: $referenceValue',
    ];

    return parts.isEmpty ? '-' : parts.join(' | ');
  }

  String get referenceSummary {
    if (_hasValue(reference)) {
      return reference;
    }

    final bool hasRange = _hasValue(referenceLow) || _hasValue(referenceHigh);
    if (!hasRange) {
      return unit;
    }

    final String range = <String>[
      if (_hasValue(referenceLow)) referenceLow,
      if (_hasValue(referenceHigh)) referenceHigh,
    ].join(' - ');

    return <String>[range, if (_hasValue(unit)) unit].join(' ');
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


