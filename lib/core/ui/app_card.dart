import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius:
            Theme.of(context).cardTheme.shape is RoundedRectangleBorder
                ? (Theme.of(context).cardTheme.shape as RoundedRectangleBorder)
                    .borderRadius
                    .resolve(Directionality.of(context))
                : null,
        child: card,
      );
    }

    return card;
  }
}
