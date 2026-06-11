import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_shadows.dart';

class AppBottomInputBar extends StatelessWidget {
  const AppBottomInputBar({
    required this.onInputTap,
    required this.onSearchTap,
    required this.onQuickPickTap,
    super.key,
  });

  final VoidCallback onInputTap;
  final VoidCallback onSearchTap;
  final VoidCallback onQuickPickTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            _CircleButton(
              icon: Icons.auto_awesome,
              tooltip: '快速挑选',
              onTap: onQuickPickTap,
              foreground: AppColors.primary,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF5F8FF),
                  Color(0xFFF0F4FF),
                  Color(0xFFF5F0FF),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: InkWell(
                onTap: onInputTap,
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    '智能一句话添加待办...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.subtle, fontSize: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            _CircleButton(
              icon: Icons.search,
              tooltip: '搜索待办',
              onTap: onSearchTap,
              foreground: Colors.white,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.foreground,
    this.color,
    this.gradient,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color foreground;
  final Color? color;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            gradient: gradient,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x180062FF),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: foreground),
        ),
      ),
    );
  }
}
