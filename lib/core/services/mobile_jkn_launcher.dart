import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class MobileJknLauncher {
  const MobileJknLauncher._();

  static const MethodChannel _channel = MethodChannel(
    'id.go.bandungkab.rsudotista.mobile/mobile_jkn',
  );

  static final Uri _playStoreMarketUri = Uri.parse(
    'market://details?id=app.bpjs.mobile',
  );

  static Future<void> open() async {
    try {
      await _channel.invokeMethod<void>('openMobileJkn');
      return;
    } on MissingPluginException {
      await _openPlayStoreFallback();
    } on PlatformException {
      await _openPlayStoreFallback();
    }
  }

  static Future<void> _openPlayStoreFallback() async {
    final bool openedMarket = await launchUrl(
      _playStoreMarketUri,
      mode: LaunchMode.externalApplication,
    );

    if (openedMarket) {
      return;
    }

    throw PlatformException(
      code: 'PLAY_STORE_NOT_FOUND',
      message: 'Google Play Store tidak tersedia di perangkat ini.',
    );
  }
}
