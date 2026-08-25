import 'package:equatable/equatable.dart';

import 'api_collection.dart';

class EmployeeRecord extends Equatable {
  const EmployeeRecord({required this.data});

  final Map<String, dynamic> data;

  factory EmployeeRecord.fromJson(Map<String, dynamic> json) {
    return EmployeeRecord(data: json);
  }

  String get id => ApiResponseReader.stringValue(data, const <String>[
    'id',
    'id_pegawai',
    'pegawai_id',
  ]);

  String get nama => ApiResponseReader.stringValue(data, const <String>[
    'nama',
    'nama_pegawai',
    'full_name',
    'name',
  ], fallback: 'Pegawai');

  String get jabatan => ApiResponseReader.stringValue(data, const <String>[
    'jabatan',
    'posisi',
    'position',
    'role',
  ]);

  String get unit => ApiResponseReader.stringValue(data, const <String>[
    'unit',
    'poli',
    'poli_type',
    'spesialis',
    'spesialisasi',
    'departemen',
    'subkelompok_pegawai',
    'smf',
  ]);

  String get poliId => ApiResponseReader.stringValue(data, const <String>[
    'poli_id',
    'poliklinik_id',
    'ruangan_id',
  ], fallback: '');

  String get poliType => ApiResponseReader.stringValue(data, const <String>[
    'poli_type',
    'politype',
  ], fallback: '');

  String get kuotaPoli => ApiResponseReader.stringValue(data, const <String>[
    'kuota_poli',
    'kuota',
  ], fallback: '');

  bool get isDoctorLike {
    final String flag = ApiResponseReader.stringValue(data, const <String>[
      'is_dokter',
    ], fallback: '').toLowerCase();
    if (<String>{'1', 'true', 'y', 'yes', 'dokter'}.contains(flag)) {
      return true;
    }

    final String text = '$nama $jabatan $unit'.toLowerCase();
    return text.contains('dokter') ||
        text.contains('dr.') ||
        text.contains('dr ');
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

    add('Nama', nama);
    add('Jabatan', jabatan);
    add('Unit/Poli', unit);
    add('Poli ID', poliId);
    add('Kuota Poli', kuotaPoli);

    return fields;
  }

  @override
  List<Object?> get props => <Object?>[data];
}
