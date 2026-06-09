import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class AppGradientScaffold extends StatelessWidget {
  const AppGradientScaffold({required this.child, this.bottomBar, super.key});

  final Widget child;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [Color(0xFFEAF4FF), Color(0xFFF0E8FF), Colors.white],
              stops: [0, 0.42, 0.78],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: child,
            ),
          ),
        ),
        bottomNavigationBar: bottomBar,
      ),
    );
  }
}

class PageTitleBar extends StatelessWidget {
  const PageTitleBar({
    required this.title,
    this.onBack,
    this.trailing,
    super.key,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: '返回',
          icon: const Icon(Icons.chevron_left),
          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
        ),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        trailing ?? const SizedBox(width: 48),
      ],
    );
  }
}

class SoftCard extends StatelessWidget {
  const SoftCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.onLongPress,
    this.color = Colors.white,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: softCardDecoration(color: color),
      child: child,
    );

    if (onTap == null && onLongPress == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: onTap,
        onLongPress: onLongPress,
        child: content,
      ),
    );
  }
}

class CircleIcon extends StatelessWidget {
  const CircleIcon({
    required this.icon,
    this.background = const Color(0xFFEAF2FF),
    this.foreground = AppColors.accent,
    this.size = 42,
    super.key,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, color: foreground, size: size * 0.48),
    );
  }
}
