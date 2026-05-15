import 'package:equatable/equatable.dart';

import 'api_collection.dart';

class PatientRecord extends Equatable {
  const PatientRecord({required this.data});

  final Map<String, dynamic> data;

  factory PatientRecord.fromJson(Map<String, dynamic> json) {
    return PatientRecord(data: json);
  }

  String get id => ApiResponseReader.stringValue(data, const <String>[
    'id',
    'id_pasien',
    'pasien_id',
  ]);

  String get noRm => ApiResponseReader.stringValue(data, const <String>[
    'no_rm',
    'nomor_rm',
    'norm',
    'no_rekam_medis',
    'rm',
  ]);

  String get nama => ApiResponseReader.stringValue(data, const <String>[
    'nama',
    'nama_pasien',
    'full_name',
    'name',
  ], fallback: 'Pasien');

  String get gender => ApiResponseReader.stringValue(data, const <String>[
    'jenis_kelamin',
    'gender',
    'kelamin',
  ]);

  String get phone => ApiResponseReader.stringValue(data, const <String>[
    'no_hp',
    'phone',
    'telepon',
    'no_telp',
  ]);

  String get address =>
      ApiResponseReader.stringValue(data, const <String>['alamat', 'address']);

  List<MapEntry<String, String>> get displayFields {
    return ApiResponseReader.readableEntries(
      data,
      limit: 40,
      excludeSystemFields: true,
      priorityKeys: const <String>[
        'no_rm',
        'nama',
        'jenis_kelamin',
        'tgl_lahir',
        'tanggal_lahir',
        'nik',
        'no_hp',
        'alamat',
      ],
    );
  }

  @override
  List<Object?> get props => <Object?>[data];
}
