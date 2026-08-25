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

  String get gender => _normalizeGender(
    ApiResponseReader.stringValue(data, const <String>[
      'jenis_kelamin',
      'gender',
      'kelamin',
    ]),
  );

  String get phone => ApiResponseReader.stringValue(data, const <String>[
    'no_hp',
    'nohp',
    'phone',
    'telepon',
    'no_telp',
    'notlp',
  ]);

  String get address =>
      ApiResponseReader.stringValue(data, const <String>['alamat', 'address']);

  String get birthPlace => ApiResponseReader.stringValue(data, const <String>[
    'tempat_lahir',
    'tmplahir',
  ]);

  String get birthDate => ApiResponseReader.stringValue(data, const <String>[
    'tanggal_lahir',
    'tgl_lahir',
    'tgllahir',
  ]);

  String get bloodType => ApiResponseReader.stringValue(data, const <String>[
    'golongan_darah',
    'goldar',
    'golda',
  ]);

  List<MapEntry<String, String>> get safeProfileFields {
    final List<MapEntry<String, String>> fields = <MapEntry<String, String>>[];

    void add(String label, String value) {
      final String normalizedValue = value.trim();
      if (normalizedValue.isEmpty || normalizedValue == '-') {
        return;
      }
      fields.add(MapEntry<String, String>(label, normalizedValue));
    }

    add('No. RM', noRm);
    add('Nama', nama);
    add('Jenis Kelamin', gender);
    add('Tempat Lahir', birthPlace);
    add('Tanggal Lahir', birthDate);
    add('No. HP', phone);
    add('Alamat', address);
    add('Golongan Darah', bloodType);

    return fields;
  }

  List<MapEntry<String, String>> get displayFields {
    return ApiResponseReader.readableEntries(
      data,
      limit: 40,
      excludeSystemFields: true,
      priorityKeys: const <String>[
        'no_rm',
        'nama',
        'jenis_kelamin',
        'kelamin',
        'tgl_lahir',
        'tanggal_lahir',
        'tgllahir',
        'nik',
        'no_hp',
        'nohp',
        'notlp',
        'alamat',
      ],
    );
  }

  @override
  List<Object?> get props => <Object?>[data];
}

String _normalizeGender(String value) {
  final String normalized = value.trim().toLowerCase();
  switch (normalized) {
    case 'l':
    case '1':
    case 'm':
    case 'male':
    case 'laki':
    case 'laki-laki':
    case 'laki laki':
      return 'Laki-laki';
    case 'p':
    case '2':
    case 'f':
    case 'female':
    case 'perempuan':
      return 'Perempuan';
    default:
      return value;
  }
}
