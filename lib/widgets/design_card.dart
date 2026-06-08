import 'dart:io';
import 'package:flutter/material.dart';
import '../models/design_model.dart';
import 'app_network_image.dart';

class DesignCard extends StatelessWidget {
  final Design design;
  final VoidCallback onTap;
  final VoidCallback? onAddToWardrobe;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isInWardrobe;

  const DesignCard({
    required this.design,
    required this.onTap,
    this.onAddToWardrobe,
    this.onEdit,
    this.onDelete,
    this.isInWardrobe = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey[200]!),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image ────────────────────────────────────────────────
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: design.id,
                        child: design.imageUrl.startsWith('/')
                            ? Image.file(File(design.imageUrl),
                                width: double.infinity, fit: BoxFit.cover)
                            : AppNetworkImage(
                                imageUrl: design.imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      ),
                      // subtle bottom gradient
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.22),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // category pill
                      Positioned(
                        top: 7,
                        left: 7,
                        child: _Pill(
                          label: design.category,
                          color: Colors.black.withValues(alpha: 0.52),
                          textColor: Colors.white,
                        ),
                      ),
                      // wardrobe action button
                      if (onAddToWardrobe != null)
                        Positioned(
                          top: 7,
                          right: 7,
                          child: _CircleAction(
                            icon: isInWardrobe ? Icons.check : Icons.add,
                            tooltip: isInWardrobe
                                ? 'Already in wardrobe'
                                : 'Add to wardrobe',
                            color:
                                isInWardrobe ? Colors.green : cs.primary,
                            onPressed: onAddToWardrobe!,
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Info ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        design.name,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Rs. ${design.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: cs.primary,
                              ),
                            ),
                          ),
                          if (onEdit != null)
                            _MiniAction(
                              icon: Icons.edit_outlined,
                              tooltip: 'Edit',
                              onPressed: onEdit!,
                            ),
                          if (onDelete != null) ...[
                            const SizedBox(width: 4),
                            _MiniAction(
                              icon: Icons.delete_outline,
                              tooltip: 'Delete',
                              color: Colors.red,
                              onPressed: onDelete!,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _Pill({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: textColor, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onPressed;

  const _CircleAction({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 30,
            height: 30,
            child: Icon(icon, size: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  const _MiniAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 30,
            height: 28,
            child: Icon(icon, size: 15, color: c),
          ),
        ),
      ),
    );
  }
}
