import 'package:flutter/material.dart';

import '../app.dart';
import '../controllers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class ScreenshotCourseScreen extends StatefulWidget {
  const ScreenshotCourseScreen({super.key});

  @override
  State<ScreenshotCourseScreen> createState() => _ScreenshotCourseScreenState();
}

class _ScreenshotCourseScreenState extends State<ScreenshotCourseScreen> {
  bool _isImporting = false;
  bool _hasSelectedMockImage = false;

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              children: [
                const StatusHeader(),
                PageTitleBar(
                  title: '截图添加课程',
                  onBack: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              children: [
                SoftCard(
                  child: Column(
                    children: [
                      InkWell(
                        key: const Key('mock-screenshot-picker'),
                        borderRadius: BorderRadius.circular(8),
                        onTap: () =>
                            setState(() => _hasSelectedMockImage = true),
                        child: Container(
                          height: 230,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _hasSelectedMockImage
                                      ? Icons.check_circle_outline
                                      : Icons.add_photo_alternate_outlined,
                                  size: 44,
                                  color: _hasSelectedMockImage
                                      ? AppColors.accent
                                      : AppColors.textMuted,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _hasSelectedMockImage ? '已选择课表截图' : '导入课表截图',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  '支持 JPG、PNG 格式',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _isImporting
                            ? '正在加载、识别并写入后端数据...'
                            : '上传后将自动识别课程信息并添加到课表',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: FilledButton(
                key: const Key('confirm-screenshot-import'),
                onPressed: _isImporting ? null : _import,
                child: Text(_isImporting ? '识别中...' : '确定'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _import() async {
    setState(() {
      _hasSelectedMockImage = true;
      _isImporting = true;
    });
    final state = TimenoteScope.of(context);
    await state.importCoursesFromScreenshot();
    if (!mounted) {
      return;
    }
    final navigator = Navigator.of(context);
    navigator.popUntil((route) => route.isFirst);
    await navigator.pushNamed(AppRoutes.timetable);
  }
}
