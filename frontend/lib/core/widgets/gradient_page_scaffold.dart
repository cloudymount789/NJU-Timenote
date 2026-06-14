import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class GradientPageScaffold extends StatelessWidget {
  const GradientPageScaffold({
    required this.child,
    this.safeTop = true,
    super.key,
  });

  final Widget child;
  final bool safeTop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: AppColors.surface)),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: MediaQuery.sizeOf(context).height * 0.38,
            child: const _TopGradientBackground(),
          ),
          SafeArea(top: safeTop, child: child),
        ],
      ),
    );
  }
}

class _TopGradientBackground extends StatelessWidget {
  const _TopGradientBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.gradientBlue.withValues(alpha: 0.36),
                  AppColors.gradientPurple.withValues(alpha: 0.28),
                  AppColors.gradientPink.withValues(alpha: 0.24),
                  Colors.white.withValues(alpha: 0.98),
                ],
                stops: const [0, 0.38, 0.66, 1],
              ),
            ),
          ),
        ),
        const Positioned(
          left: -64,
          top: -52,
          width: 260,
          height: 200,
          child: _SoftBlob(color: AppColors.gradientBlue, blur: 56),
        ),
        const Positioned(
          right: -12,
          top: -44,
          width: 240,
          height: 190,
          child: _SoftBlob(color: AppColors.gradientPurple, blur: 62),
        ),
        const Positioned(
          left: 88,
          top: 40,
          width: 200,
          height: 170,
          child: _SoftBlob(color: AppColors.gradientPink, blur: 54),
        ),
        const Positioned(
          left: 36,
          top: 128,
          right: 36,
          height: 150,
          child: _SoftBlob(color: Color(0xEEFFFFFF), blur: 42),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 150,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00FFFFFF),
                  Color(0xCCFFFFFF),
                  Color(0xFFFFFFFF),
                ],
                stops: [0, 0.64, 1],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SoftBlob extends StatelessWidget {
  const _SoftBlob({required this.color, required this.blur});

  final Color color;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color, blurRadius: blur, spreadRadius: blur / 4),
        ],
      ),
    );
  }
}
