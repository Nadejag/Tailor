import 'dart:io';
import 'package:flutter/material.dart';
import 'shimmer.dart';

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const AppNetworkImage({
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Widget img = imageUrl.startsWith('/')
        ? Image.file(
            File(imageUrl),
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) =>
                _ImagePlaceholder(width: width, height: height),
          )
        : Image.network(
            imageUrl,
            width: width,
            height: height,
            fit: fit,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : _ImagePlaceholder(width: width, height: height),
            errorBuilder: (context, error, stackTrace) =>
                _ImagePlaceholder(width: width, height: height),
          );

    if (borderRadius == null) return img;
    return ClipRRect(borderRadius: borderRadius!, child: img);
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final double? width;
  final double? height;

  const _ImagePlaceholder({this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primary.withValues(alpha: 0.14),
              cs.secondary.withValues(alpha: 0.12),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.checkroom_outlined,
            size: 42,
            color: cs.primary.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}
