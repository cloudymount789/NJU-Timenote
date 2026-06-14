import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    super.key,
  });

  final String title;
  final String? message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 34, color: AppColors.subtle),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 6),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.subtle, fontSize: 13),
          ),
        ],
      ],
    );
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline,
      title: '暂时无法加载',
      message: message,
    );
  }
}

class DisabledState extends StatelessWidget {
  const DisabledState({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.45,
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, color: AppColors.muted),
      ),
    );
  }
}
