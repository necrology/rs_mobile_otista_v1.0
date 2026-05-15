import 'package:flutter/material.dart';

import '../../../navigation/presentation/pages/main_shell_page.dart';
import 'splash_page.dart';

class SplashGatePage extends StatefulWidget {
  const SplashGatePage({super.key});

  @override
  State<SplashGatePage> createState() => _SplashGatePageState();
}

class _SplashGatePageState extends State<SplashGatePage> {
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _bootstrapApplication();
  }

  Future<void> _bootstrapApplication() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) {
      return;
    }
    setState(() {
      _isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      child: _isReady ? const MainShellPage() : const SplashPage(),
    );
  }
}
