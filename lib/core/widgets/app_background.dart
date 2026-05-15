import 'package:flutter/material.dart';

import '../constants/app_assets.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0xFFF9F4EB), Color(0xFFF3F7F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -70,
            right: -30,
            child: _GlowOrb(
              size: size.width * 0.50,
              colors: const <Color>[Color(0x33D5A021), Color(0x00D5A021)],
            ),
          ),
          Positioned(
            bottom: -90,
            left: -50,
            child: _GlowOrb(
              size: size.width * 0.62,
              colors: const <Color>[Color(0x26298361), Color(0x00298361)],
            ),
          ),
          Positioned(
            top: 32,
            right: -36,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.08,
                child: Image.asset(
                  AppAssets.hospitalPhoto2,
                  width: size.width * 0.74,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: -44,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.06,
                child: Image.asset(
                  AppAssets.hospitalPhoto4,
                  width: size.width * 0.90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.36,
            right: -10,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.05,
                child: Transform.rotate(
                  angle: -0.12,
                  child: Image.asset(
                    AppAssets.hospitalPhoto3,
                    width: size.width * 0.44,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}
