class ApiConfig {
  const ApiConfig._();

  // static const String _defaultBaseUrl =
  //     'https://api-mobile.rsudotista.my.id/api/v1';
  static const String _defaultBaseUrl =
      'https://otista.maulana-gandawijaya.my.id/api/v1';

  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static const String _overrideBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const String _devBaseUrl = String.fromEnvironment(
    'DEV_API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  static const String _prodBaseUrl = String.fromEnvironment(
    'PROD_API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  static bool get isProd => appEnv.toLowerCase() == 'prod';

  static String get label => isProd ? 'Prod' : 'Dev';

  static String get baseUrl {
    final String configuredUrl = _overrideBaseUrl.trim().isNotEmpty
        ? _overrideBaseUrl.trim()
        : isProd
        ? _prodBaseUrl.trim()
        : _devBaseUrl.trim();

    if (configuredUrl.endsWith('/')) {
      return configuredUrl.substring(0, configuredUrl.length - 1);
    }

    return configuredUrl;
  }

  static bool get isConfigured => baseUrl.isNotEmpty;

  static Uri endpoint(
    String path, {
    Map<String, Object?> queryParameters = const <String, Object?>{},
  }) {
    if (!isConfigured) {
      throw const ApiConfigException(
        'Base URL layanan data belum dikonfigurasi untuk environment ini.',
      );
    }

    final String normalizedPath = path.startsWith('/')
        ? path.substring(1)
        : path;
    final Uri uri = Uri.parse('$baseUrl/$normalizedPath');
    final Map<String, String> filteredQuery = <String, String>{};

    queryParameters.forEach((String key, Object? value) {
      if (value == null) {
        return;
      }

      final String normalizedValue = value.toString().trim();
      if (normalizedValue.isEmpty) {
        return;
      }

      filteredQuery[key] = normalizedValue;
    });

    if (filteredQuery.isEmpty) {
      return uri;
    }

    return uri.replace(queryParameters: filteredQuery);
  }
}

class ApiConfigException implements Exception {
  const ApiConfigException(this.message);

  final String message;

  @override
  String toString() => message;
}
