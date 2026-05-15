import 'package:flutter/material.dart';

class AppSpacing {
  static const double radius = 12;
  static const double compactRadius = 8;
  static const double maxContentWidth = 680;

  static double pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) return 14;
    if (width < 430) return 16;
    if (width < 600) return 20;
    return 24;
  }

  static double cardGap(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) return 10;
    if (width < 600) return 12;
    return 16;
  }

  static int gridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 340) return 1;
    if (width < 700) return 2;
    return 3;
  }

  static EdgeInsets pageInsets(BuildContext context) {
    final padding = pagePadding(context);
    return EdgeInsets.fromLTRB(padding, padding, padding, padding);
  }
}

class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double maxWidth;

  const ResponsiveCenter({
    required this.child,
    this.padding,
    this.maxWidth = AppSpacing.maxContentWidth,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? AppSpacing.pageInsets(context),
          child: child,
        ),
      ),
    );
  }
}

class AppSurface extends StatelessWidget {
  final Widget child;

  const AppSurface({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }
}
