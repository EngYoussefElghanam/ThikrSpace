import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;

  const EmptyState({
    super.key,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 48, color: colorScheme.onSurface.withOpacity(0.5)),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(
            message,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: colorScheme.error),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.error),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ]
        ],
      ),
    );
  }
}
