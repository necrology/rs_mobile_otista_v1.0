import 'package:equatable/equatable.dart';

import 'api_collection.dart';

class ResourceRecord extends Equatable {
  const ResourceRecord({required this.data});

  final Map<String, dynamic> data;

  factory ResourceRecord.fromJson(Map<String, dynamic> json) {
    return ResourceRecord(data: json);
  }

  String get id => ApiResponseReader.stringValue(data, const <String>['id']);

  String get name => ApiResponseReader.stringValue(data, const <String>[
    'nama',
    'name',
    'kode',
  ], fallback: 'Data');

  String value(List<String> keys, {String fallback = '-'}) {
    return ApiResponseReader.stringValue(data, keys, fallback: fallback);
  }

  List<MapEntry<String, String>> displayFields({
    int limit = 8,
    List<String> priorityKeys = const <String>[],
  }) {
    return ApiResponseReader.readableEntries(
      data,
      limit: limit,
      excludeSystemFields: true,
      priorityKeys: priorityKeys,
    );
  }

  @override
  List<Object?> get props => <Object?>[data];
}
