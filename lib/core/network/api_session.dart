class SessionTokenPair {
  const SessionTokenPair({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    this.accessExpiresAt,
    this.refreshExpiresAt,
  });

  final String tokenType;
  final String accessToken;
  final DateTime? accessExpiresAt;
  final String refreshToken;
  final DateTime? refreshExpiresAt;

  factory SessionTokenPair.fromJson(Map<String, dynamic> json) {
    final String accessToken = (json['access_token'] ?? '').toString().trim();
    final String refreshToken = (json['refresh_token'] ?? '').toString().trim();
    if (accessToken.isEmpty || refreshToken.isEmpty) {
      throw const FormatException('Pasangan token sesi tidak lengkap.');
    }

    final String rawTokenType = (json['token_type'] ?? 'Bearer')
        .toString()
        .trim();
    if (rawTokenType.toLowerCase() != 'bearer') {
      throw const FormatException('Tipe token sesi tidak didukung.');
    }

    return SessionTokenPair(
      tokenType: 'Bearer',
      accessToken: accessToken,
      accessExpiresAt: _parseDateTime(json['access_expires_at']),
      refreshToken: refreshToken,
      refreshExpiresAt: _parseDateTime(json['refresh_expires_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'token_type': tokenType,
      'access_token': accessToken,
      'access_expires_at': accessExpiresAt?.toUtc().toIso8601String(),
      'refresh_token': refreshToken,
      'refresh_expires_at': refreshExpiresAt?.toUtc().toIso8601String(),
    };
  }

  bool accessNeedsRefresh(
    DateTime now, {
    Duration leeway = const Duration(seconds: 30),
  }) {
    final DateTime? expiresAt = accessExpiresAt;
    return expiresAt != null && !expiresAt.isAfter(now.toUtc().add(leeway));
  }

  bool refreshIsExpired(DateTime now) {
    final DateTime? expiresAt = refreshExpiresAt;
    return expiresAt != null && !expiresAt.isAfter(now.toUtc());
  }

  static DateTime? _parseDateTime(Object? value) {
    final String rawValue = value?.toString().trim() ?? '';
    if (rawValue.isEmpty) {
      return null;
    }
    return DateTime.tryParse(rawValue)?.toUtc();
  }
}

abstract interface class ApiSessionStore {
  Future<SessionTokenPair?> readTokenPair();

  Future<void> saveTokenPair(SessionTokenPair tokenPair);

  Future<void> clearSession();
}
