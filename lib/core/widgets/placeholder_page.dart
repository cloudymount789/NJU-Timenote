import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import 'app_header.dart';
import 'gradient_page_scaffold.dart';
import 'state_views.dart';

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    required this.title,
    required this.message,
    this.extra,
    super.key,
  });

  final String title;
  final String message;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return GradientPageScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageX,
          AppSpacing.xl,
          AppSpacing.pageX,
          AppSpacing.pageBottom,
        ),
        child: Column(
          children: [
            AppHeader(
              title: title,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 72),
            Expanded(
              child: Center(
                child: EmptyState(
                  title: '当前是页面入口壳',
                  message: message,
                  icon: Icons.layers_outlined,
                ),
              ),
            ),
            if (extra != null) ...[
              const SizedBox(height: 16),
              DefaultTextStyle(
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
                child: extra!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
