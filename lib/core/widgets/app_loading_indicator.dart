import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppLoadingIndicator extends StatefulWidget {
  const AppLoadingIndicator({super.key, this.message, this.size = 44});

  final String? message;
  final double size;

  @override
  State<AppLoadingIndicator> createState() => _AppLoadingIndicatorState();
}

class _AppLoadingIndicatorState extends State<AppLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size;

    final Widget indicator = SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double rotation = _controller.value * math.pi * 2;
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox.square(
                dimension: size,
                child: CircularProgressIndicator(
                  strokeWidth: size * 0.10,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryTeal.withValues(alpha: 0.20),
                  ),
                ),
              ),
              Transform.rotate(
                angle: rotation,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(
                    strokeWidth: size * 0.10,
                    strokeCap: StrokeCap.round,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryTeal,
                    ),
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.78 + (0.08 * math.sin(rotation)),
                child: Container(
                  width: size * 0.26,
                  height: size * 0.26,
                  decoration: BoxDecoration(
                    color: AppColors.deepTeal.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    if (widget.message == null) {
      return indicator;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        indicator,
        if (widget.message != null) ...<Widget>[
          const SizedBox(height: 10),
          Text(
            widget.message!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
