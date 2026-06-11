import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/gradient_page_scaffold.dart';

class NextThingPage extends StatelessWidget {
  const NextThingPage({super.key});

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
              title: '下一件事',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const Spacer(),
            const Icon(
              Icons.psychology_alt_outlined,
              size: 56,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              '你现在感觉怎么样？',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            const Text(
              '状态滑杆和推荐结果会在任务 4 完成。',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.subtle),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: null, child: const Text('推荐待办')),
            ),
          ],
        ),
      ),
    );
  }
}
