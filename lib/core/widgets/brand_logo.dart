import 'package:flutter/material.dart';

import '../constants/app_assets.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    required this.size,
    this.borderRadius = 14,
    this.backgroundColor = Colors.transparent,
    this.showShadow = true,
    super.key,
  });

  final double size;
  final double borderRadius;
  final Color backgroundColor;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        AppAssets.rsudFullLogo,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

class PartnerLogos extends StatelessWidget {
  const PartnerLogos({this.height = 44, this.compact = false, super.key});

  final double height;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _LogoImage(
          asset: AppAssets.rsudFullLogoTrimmed,
          width: compact ? height * 0.78 : height * 1.05,
          height: height,
        ),
        SizedBox(width: compact ? 10 : 14),
        _LogoImage(
          asset: AppAssets.rsudMark,
          width: compact ? height * 1.28 : height * 1.62,
          height: height,
        ),
      ],
    );
  }
}

class _LogoImage extends StatelessWidget {
  const _LogoImage({
    required this.asset,
    required this.width,
    required this.height,
  });

  final String asset;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Image.asset(asset, fit: BoxFit.contain),
    );
  }
}
