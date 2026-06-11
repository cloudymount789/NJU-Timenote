import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_shell.dart';
import '../models/settings.dart';

class PeriodEditorScreen extends ConsumerStatefulWidget {
  const PeriodEditorScreen({super.key});

  @override
  ConsumerState<PeriodEditorScreen> createState() => _PeriodEditorScreenState();
}

class _PeriodEditorScreenState extends ConsumerState<PeriodEditorScreen> {
  late List<_PeriodEditing> _periods;
  bool _initialized = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(semesterSettingsProvider).value;

    if (settings != null && !_initialized) {
      _initialized = true;
      _periods = settings.periods.map((p) => _PeriodEditing(p)).toList();
    }

    if (!_initialized) {
      return const AppGradientScaffold(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return AppGradientScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          children: [
            PageTitleBar(title: '编辑节次时间'),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: SoftCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < _periods.length; i++) ...[
                        _PeriodRow(
                          period: _periods[i],
                          onStart: () => _pickTime(i, true),
                          onEnd: () => _pickTime(i, false),
                        ),
                        if (i < _periods.length - 1)
                          const Divider(height: 1, color: AppColors.border),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? '保存中...' : '保存'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime(int index, bool isStart) async {
    final current = _periods[index];
    final initial = isStart ? current.start : current.end;
    final parts = initial.split(':');
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      ),
    );
    if (time == null) return;
    setState(() {
      final formatted =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      if (isStart) {
        _periods[index] = _PeriodEditing(PeriodTime(
          period: current.period.period, start: formatted, end: current.end));
      } else {
        _periods[index] = _PeriodEditing(PeriodTime(
          period: current.period.period, start: current.start, end: formatted));
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref.read(settingsRepositoryProvider).updatePeriodTimes(
      _periods.map((p) => p.period).toList(),
    );
    ref.invalidate(semesterSettingsProvider);
    if (mounted) Navigator.of(context).pop();
  }
}

class _PeriodEditing {
  _PeriodEditing(this.period);
  final PeriodTime period;
  String get start => period.start;
  String get end => period.end;
}

class _PeriodRow extends StatelessWidget {
  const _PeriodRow({
    required this.period,
    required this.onStart,
    required this.onEnd,
  });

  final _PeriodEditing period;
  final VoidCallback onStart;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Text(
              '第 ${period.period.period} 节',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onStart,
              child: Text(
                period.start,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Text(' – ', style: TextStyle(color: AppColors.textSecondary)),
            GestureDetector(
              onTap: onEnd,
              child: Text(
                period.end,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
