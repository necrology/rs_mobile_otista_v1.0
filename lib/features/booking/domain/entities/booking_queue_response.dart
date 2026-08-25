class BookingQueueResponse {
  const BookingQueueResponse({
    required this.registrationId,
    required this.dummyId,
    required this.queueId,
    required this.registrationCode,
    required this.queueNumber,
    required this.queueCode,
    required this.queueGroup,
    required this.poliId,
    required this.poliName,
    required this.queueDate,
    required this.serviceMode,
    required this.source,
    required this.existing,
  });

  factory BookingQueueResponse.fromJson(Map<String, dynamic> json) {
    return BookingQueueResponse(
      registrationId: _toInt(json['registration_id']),
      dummyId: _toInt(json['dummy_id']),
      queueId: _toInt(json['queue_id']),
      registrationCode: json['registration_code']?.toString() ?? '',
      queueNumber: json['queue_number']?.toString() ?? '',
      queueCode: json['queue_code']?.toString() ?? '',
      queueGroup: json['queue_group']?.toString() ?? '',
      poliId: _toInt(json['poli_id']),
      poliName: json['poli_name']?.toString() ?? '',
      queueDate: json['queue_date']?.toString() ?? '',
      serviceMode: json['service_mode']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      existing: _toBool(json['existing']),
    );
  }

  final int registrationId;
  final int dummyId;
  final int queueId;
  final String registrationCode;
  final String queueNumber;
  final String queueCode;
  final String queueGroup;
  final int poliId;
  final String poliName;
  final String queueDate;
  final String serviceMode;
  final String source;
  final bool existing;

  String get displayQueueNumber =>
      queueCode.trim().isNotEmpty ? queueCode : queueNumber;

  static int _toInt(Object? value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(Object? value) {
    if (value is bool) {
      return value;
    }

    final String normalized = value?.toString().trim().toLowerCase() ?? '';
    return normalized == 'true' || normalized == '1' || normalized == 'y';
  }
}
