import 'package:equatable/equatable.dart';

import 'api_collection.dart';

class TableMetadata extends Equatable {
  const TableMetadata({
    required this.tableName,
    required this.columns,
    required this.raw,
  });

  final String tableName;
  final List<TableColumnInfo> columns;
  final dynamic raw;

  factory TableMetadata.fromResponse({
    required String tableName,
    required dynamic response,
  }) {
    final List<dynamic> rawColumns = ApiResponseReader.findList(response);
    final Map<String, dynamic> fallbackMap = ApiResponseReader.findMap(
      response,
    );
    final List<TableColumnInfo> parsedColumns = rawColumns
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> item) => TableColumnInfo.fromJson(item))
        .toList();

    return TableMetadata(
      tableName: ApiResponseReader.stringValue(fallbackMap, const <String>[
        'table',
        'table_name',
        'name',
      ], fallback: tableName),
      columns: parsedColumns,
      raw: response,
    );
  }

  @override
  List<Object?> get props => <Object?>[tableName, columns, raw];
}

class TableColumnInfo extends Equatable {
  const TableColumnInfo({required this.data});

  final Map<String, dynamic> data;

  factory TableColumnInfo.fromJson(Map<dynamic, dynamic> json) {
    return TableColumnInfo(
      data: json.map(
        (dynamic key, dynamic value) =>
            MapEntry<String, dynamic>(key.toString(), value),
      ),
    );
  }

  String get name => ApiResponseReader.stringValue(data, const <String>[
    'name',
    'column_name',
    'field',
    'Field',
  ], fallback: 'Kolom');

  String get type => ApiResponseReader.stringValue(data, const <String>[
    'type',
    'data_type',
    'Type',
  ]);

  String get nullable => ApiResponseReader.stringValue(data, const <String>[
    'nullable',
    'is_nullable',
    'Null',
  ]);

  String get keyType => ApiResponseReader.stringValue(data, const <String>[
    'key',
    'Key',
    'constraint',
  ]);

  List<MapEntry<String, String>> get displayFields {
    return ApiResponseReader.readableEntries(
      data,
      limit: 5,
      priorityKeys: const <String>[
        'name',
        'column_name',
        'type',
        'data_type',
        'nullable',
      ],
    );
  }

  @override
  List<Object?> get props => <Object?>[data];
}
