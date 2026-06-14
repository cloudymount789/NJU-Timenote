import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.backgroundColor = Colors.transparent,
    this.iconColor = AppColors.ink,
    this.size = 40,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size / 2),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: SizedBox(
            height: size,
            width: size,
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ),
      ),
    );
  }
}
