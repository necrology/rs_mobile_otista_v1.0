import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../../../core/utils/date_format_utils.dart';

class ApiCollection<T> extends Equatable {
  const ApiCollection({required this.items, this.total, this.raw});

  final List<T> items;
  final int? total;
  final dynamic raw;

  int? get totalPages => ApiResponseReader.findInt(raw, const <String>[
    'total_pages',
    'totalPages',
  ]);

  bool get hasNext {
    final dynamic pagination = raw is Map<dynamic, dynamic>
        ? (raw as Map<dynamic, dynamic>)['pagination']
        : null;

    if (pagination is Map<dynamic, dynamic>) {
      final dynamic value = pagination['has_next'];
      if (value is bool) {
        return value;
      }

      return value?.toString().toLowerCase() == 'true';
    }

    return false;
  }

  factory ApiCollection.fromResponse(
    dynamic response,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final List<dynamic> rawItems = ApiResponseReader.findList(response);
    final List<T> parsedItems = rawItems
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> item) => fromJson(_normalizeMap(item)))
        .toList();

    return ApiCollection<T>(
      items: parsedItems,
      total: ApiResponseReader.findInt(response, const <String>[
        'total',
        'count',
        'total_count',
        'total_rows',
        'records_total',
        'recordsTotal',
      ]),
      raw: response,
    );
  }

  @override
  List<Object?> get props => <Object?>[items, total, raw];
}

class ApiResponseReader {
  const ApiResponseReader._();

  static List<dynamic> findList(dynamic response) {
    if (response is List<dynamic>) {
      return response;
    }

    if (response is Map<dynamic, dynamic>) {
      for (final String key in <String>[
        'data',
        'items',
        'rows',
        'result',
        'results',
        'pasiens',
        'pegawais',
        'columns',
        'fields',
      ]) {
        final dynamic value = response[key];
        if (value is List<dynamic>) {
          return value;
        }

        if (value is Map<dynamic, dynamic>) {
          final List<dynamic> nestedList = findList(value);
          if (nestedList.isNotEmpty) {
            return nestedList;
          }
        }
      }
    }

    return const <dynamic>[];
  }

  static Map<String, dynamic> findMap(dynamic response) {
    if (response is Map<dynamic, dynamic>) {
      final dynamic data = response['data'];
      if (data is Map<dynamic, dynamic>) {
        return _normalizeMap(data);
      }

      return _normalizeMap(response);
    }

    return const <String, dynamic>{};
  }

  static int? findInt(dynamic response, List<String> keys) {
    if (response is Map<dynamic, dynamic>) {
      for (final String key in keys) {
        final dynamic value = response[key];
        final int? parsedValue = _parseInt(value);
        if (parsedValue != null) {
          return parsedValue;
        }
      }

      for (final dynamic value in response.values) {
        if (value is Map<dynamic, dynamic>) {
          final int? nestedValue = findInt(value, keys);
          if (nestedValue != null) {
            return nestedValue;
          }
        }
      }
    }

    return null;
  }

  static String stringValue(
    Map<String, dynamic> data,
    List<String> keys, {
    String fallback = '-',
  }) {
    for (final String key in keys) {
      final dynamic value = data[key];
      if (value == null) {
        continue;
      }

      final String normalizedValue = _normalizeDisplayValue(value.toString());
      if (normalizedValue.isNotEmpty && normalizedValue != 'null') {
        return normalizedValue;
      }
    }

    return fallback;
  }

  static List<MapEntry<String, String>> readableEntries(
    Map<String, dynamic> data, {
    int limit = 8,
    List<String> priorityKeys = const <String>[],
    bool excludeSystemFields = false,
  }) {
    final List<MapEntry<String, String>> entries = <MapEntry<String, String>>[];
    final Set<String> addedKeys = <String>{};

    for (final String key in priorityKeys) {
      if (excludeSystemFields && isSystemFieldKey(key)) {
        continue;
      }

      final dynamic value = data[key];
      if (value == null) {
        continue;
      }

      final String displayValue = _displayValue(value);
      if (displayValue.isEmpty) {
        continue;
      }

      entries.add(MapEntry<String, String>(_labelize(key), displayValue));
      addedKeys.add(key);
    }

    for (final MapEntry<String, dynamic> entry in data.entries) {
      if (entries.length >= limit || addedKeys.contains(entry.key)) {
        continue;
      }

      if (excludeSystemFields && isSystemFieldKey(entry.key)) {
        continue;
      }

      final String displayValue = _displayValue(entry.value);
      if (displayValue.isEmpty) {
        continue;
      }

      entries.add(MapEntry<String, String>(_labelize(entry.key), displayValue));
    }

    return entries;
  }

  static bool isSystemFieldKey(String key) {
    final String normalizedKey = key.trim().toLowerCase();

    return _systemFieldKeys.contains(normalizedKey) ||
        normalizedKey.startsWith('id_') ||
        normalizedKey.endsWith('_id');
  }

  static const Set<String> _systemFieldKeys = <String>{
    'id',
    'uuid',
    'guid',
    'created_at',
    'updated_at',
    'deleted_at',
    'created_by',
    'updated_by',
    'deleted_by',
    'createdby',
    'updatedby',
    'deletedby',
    'password',
    'token',
    'access_token',
    'refresh_token',
    'remember_token',
    'hidden',
    'status_lama',
    'statuslama',
  };

  static int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '');
  }

  static String _displayValue(dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is List<dynamic>) {
      return _normalizeDisplayValue(
        value.where((dynamic item) => item != null).join(', '),
      );
    }

    if (value is Map<dynamic, dynamic>) {
      return _normalizeDisplayValue(
        value.entries
            .take(3)
            .map(
              (MapEntry<dynamic, dynamic> entry) =>
                  '${entry.key}: ${entry.value}',
            )
            .join(', '),
      );
    }

    return _normalizeDisplayValue(value.toString());
  }

  static String _normalizeDisplayValue(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == 'null') {
      return '';
    }

    if (_isJsonPayload(trimmed)) {
      return '';
    }

    if (DateFormatUtils.isDateLike(trimmed)) {
      return DateFormatUtils.formatDisplayDate(trimmed);
    }

    return trimmed.replaceAllMapped(
      RegExp(r'(?<!\d)(\d{2}):(\d{2}):(\d{2})(?!\d)'),
      (Match match) => '${match[1]}:${match[2]}',
    );
  }

  static bool _isJsonPayload(String value) {
    if (value.length < 2) {
      return false;
    }

    final bool hasJsonShape =
        (value.startsWith('{') && value.endsWith('}')) ||
        (value.startsWith('[') && value.endsWith(']'));
    if (!hasJsonShape) {
      return false;
    }

    try {
      jsonDecode(value);
      return true;
    } on FormatException {
      return false;
    }
  }

  static String _labelize(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .where((String part) => part.isNotEmpty)
        .map(
          (String part) =>
              '${part[0].toUpperCase()}${part.length > 1 ? part.substring(1) : ''}',
        )
        .join(' ');
  }
}

Map<String, dynamic> _normalizeMap(Map<dynamic, dynamic> map) {
  return map.map(
    (dynamic key, dynamic value) =>
        MapEntry<String, dynamic>(key.toString(), value),
  );
}
