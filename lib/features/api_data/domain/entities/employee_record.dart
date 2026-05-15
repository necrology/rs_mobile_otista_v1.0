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
    'spesialis',
    'spesialisasi',
    'departemen',
  ]);

  List<MapEntry<String, String>> get displayFields {
    return ApiResponseReader.readableEntries(
      data,
      limit: 40,
      excludeSystemFields: true,
      priorityKeys: const <String>[
        'nama',
        'jabatan',
        'unit',
        'poli',
        'spesialisasi',
      ],
    );
  }

  @override
  List<Object?> get props => <Object?>[data];
}
