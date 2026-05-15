import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class AppShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const AppShimmer({
    required this.child,
    this.duration = const Duration(milliseconds: 1300),
    super.key,
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant AppShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final base = colorScheme.outlineVariant.withValues(alpha: 0.52);
    final highlight = Colors.white.withValues(alpha: 0.9);

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final slide = _controller.value * 2.6 - 1.3;

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1 + slide, -0.3),
              end: Alignment(1 + slide, 0.3),
              colors: [base, highlight, base],
              stops: const [0.22, 0.5, 0.78],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;
  final EdgeInsetsGeometry? margin;

  const ShimmerBox({
    this.width,
    this.height,
    this.radius = 10,
    this.margin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class DesignGridShimmer extends StatelessWidget {
  const DesignGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final gap = AppSpacing.cardGap(context);
    final width = MediaQuery.sizeOf(context).width;

    return AppShimmer(
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppSpacing.gridColumns(context),
          childAspectRatio: width < 360 ? 0.82 : 0.72,
          crossAxisSpacing: gap,
          mainAxisSpacing: gap,
        ),
        itemCount: AppSpacing.gridColumns(context) * 3,
        itemBuilder: (context, index) => const _DesignCardSkeleton(),
      ),
    );
  }
}

class WardrobeListShimmer extends StatelessWidget {
  const WardrobeListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = AppSpacing.pagePadding(context);

    return AppShimmer(
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          0,
          horizontalPadding,
          MediaQuery.paddingOf(context).bottom + 20,
        ),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) => const _WardrobeCardSkeleton(),
      ),
    );
  }
}

class _DesignCardSkeleton extends StatelessWidget {
  const _DesignCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: ShimmerBox(width: double.infinity, radius: 0)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(width: double.infinity, height: 14, radius: 7),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: ShimmerBox(height: 14, radius: 7)),
                    SizedBox(width: 12),
                    ShimmerBox(width: 34, height: 32, radius: 9),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WardrobeCardSkeleton extends StatelessWidget {
  const _WardrobeCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 360;
    final imageWidth = isCompact ? 82.0 : 100.0;

    return Container(
      height: 120,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          ShimmerBox(width: imageWidth, height: 120, radius: 0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  ShimmerBox(width: double.infinity, height: 14, radius: 7),
                  SizedBox(height: 10),
                  ShimmerBox(width: 120, height: 12, radius: 6),
                  SizedBox(height: 12),
                  ShimmerBox(width: 86, height: 24, radius: 6),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: ShimmerBox(width: 28, height: 28, radius: 14),
          ),
        ],
      ),
    );
  }
}
