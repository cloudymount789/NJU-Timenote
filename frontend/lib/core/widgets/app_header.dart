import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'app_icon_button.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final titleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );

    return Padding(
      padding: EdgeInsets.only(left: onBack == null ? 0 : 0),
      child: Row(
        children: [
          if (onBack != null) ...[
            AppIconButton(
              icon: Icons.chevron_left,
              tooltip: '返回',
              onPressed: onBack,
              size: 32,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(child: titleWidget),
          ?trailing,
        ],
      ),
    );
  }
}
