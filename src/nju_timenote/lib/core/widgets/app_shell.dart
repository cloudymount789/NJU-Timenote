import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppGradientScaffold extends StatelessWidget {
  const AppGradientScaffold({required this.child, this.bottomBar, super.key});

  final Widget child;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [Color(0xFFEAF4FF), Color(0xFFF0E8FF), Colors.white],
            stops: [0, 0.42, 0.78],
          ),
        ),
        child: SafeArea(bottom: false, child: child),
      ),
      bottomNavigationBar: bottomBar,
    );
  }
}

class StatusHeader extends StatefulWidget {
  const StatusHeader({this.leading, this.trailing, super.key});

  final Widget? leading;
  final Widget? trailing;

  @override
  State<StatusHeader> createState() => _StatusHeaderState();
}

class _StatusHeaderState extends State<StatusHeader> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _scheduleNextMinuteTick();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _scheduleNextMinuteTick() {
    _timer?.cancel();
    final nextMinute = DateTime(
      _now.year,
      _now.month,
      _now.day,
      _now.hour,
      _now.minute + 1,
    );
    final delay = nextMinute.difference(DateTime.now());
    _timer = Timer(delay.isNegative ? Duration.zero : delay, () {
      if (!mounted) {
        return;
      }
      setState(() => _now = DateTime.now());
      _scheduleNextMinuteTick();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Row(
        children: [
          widget.leading ??
              Text(
                _formatStatusTime(_now),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
          const Spacer(),
          widget.trailing ??
              const Row(
                children: [
                  Icon(Icons.signal_cellular_alt, size: 15),
                  SizedBox(width: 5),
                  Icon(Icons.wifi, size: 15),
                  SizedBox(width: 5),
                  Icon(Icons.battery_full, size: 18),
                ],
              ),
        ],
      ),
    );
  }

  String _formatStatusTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
        borderRadius: BorderRadius.circular(8),
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

class BottomQuickInput extends StatelessWidget {
  const BottomQuickInput({
    required this.onSearch,
    required this.onInput,
    super.key,
  });

  final VoidCallback onSearch;
  final VoidCallback onInput;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: AppColors.background,
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
        child: Row(
          children: [
            IconButton.filled(
              tooltip: '待办搜索',
              onPressed: onSearch,
              icon: const Icon(Icons.add, color: Colors.white),
              style: IconButton.styleFrom(backgroundColor: AppColors.accent),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                elevation: 3,
                shadowColor: AppColors.cardShadow,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: onInput,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    child: Text(
                      '智能一句话添加待办...',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: '语音输入',
              onPressed: onInput,
              icon: const Icon(Icons.mic_none, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
