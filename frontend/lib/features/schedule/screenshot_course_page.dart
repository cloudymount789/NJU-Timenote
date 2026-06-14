import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/gradient_page_scaffold.dart';

class ScreenshotCoursePage extends StatefulWidget {
  const ScreenshotCoursePage({super.key});

  @override
  State<ScreenshotCoursePage> createState() => _ScreenshotCoursePageState();
}

class _ScreenshotCoursePageState extends State<ScreenshotCoursePage> {
  bool _selected = false;

  Future<void> _confirm() async {
    if (!_selected) {
      showAppSnackBar(context, '请先选择一张课表截图。');
      return;
    }
    await showAppConfirmDialog(
      context: context,
      title: '识别服务未接入',
      message: '当前只保留截图导入流程壳。真实识别服务接入后，识别结果会先展示给你确认，不会直接写入课表。',
      confirmText: '知道了',
      cancelText: '返回',
    );
  }

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
              title: '截图添加课程',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 28),
            AppCard(
              radius: 12,
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => setState(() => _selected = true),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 260,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selected
                                ? Icons.image_outlined
                                : Icons.add_photo_alternate_outlined,
                            color: AppColors.primary,
                            size: 42,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _selected ? '已选择截图（流程占位）' : '选择课表截图',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '上传后将进入识别与结果确认流程。当前真实识别服务未接入，不会自动写入课程。',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(onPressed: _confirm, child: const Text('确定')),
            ),
          ],
        ),
      ),
    );
  }
}
