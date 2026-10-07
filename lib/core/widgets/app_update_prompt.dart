import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:upgrader/upgrader.dart';

class AppUpdatePrompt extends StatefulWidget {
  const AppUpdatePrompt({
    required this.child,
    this.enabled = kReleaseMode,
    this.upgrader,
    super.key,
  });

  final Widget child;
  final bool enabled;
  final Upgrader? upgrader;

  @override
  State<AppUpdatePrompt> createState() => _AppUpdatePromptState();
}

class _AppUpdatePromptState extends State<AppUpdatePrompt> {
  Upgrader? _ownedUpgrader;

  Upgrader get _upgrader =>
      widget.upgrader ??
      (_ownedUpgrader ??= Upgrader(
        countryCode: 'ID',
        languageCode: 'id',
        messages: UpgraderMessages(code: 'id'),
        checkOnResume: true,
        durationUntilAlertAgain: const Duration(hours: 12),
      ));

  @override
  void dispose() {
    _ownedUpgrader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return UpgradeAlert(
      upgrader: _upgrader,
      showIgnore: false,
      showLater: true,
      showReleaseNotes: true,
      child: widget.child,
    );
  }
}
