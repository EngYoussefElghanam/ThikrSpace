import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final bool useSafeArea;
  final EdgeInsetsGeometry? padding;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.useSafeArea = true,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = body;

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      appBar: appBar,
      body: content,
      floatingActionButton: floatingActionButton,
    );
  }
}
