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
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
            color: Colors.white,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppNetworkImage(
                        imageUrl: design.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: _Pill(
                          label: design.category,
                          color: Colors.black.withValues(alpha: 0.58),
                          textColor: Colors.white,
                        ),
                      ),
                      if (onAddToWardrobe != null)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: _CircleAction(
                            icon: isInWardrobe ? Icons.check : Icons.add,
                            tooltip: isInWardrobe
                                ? 'Already in wardrobe'
                                : 'Add to wardrobe',
                            color: isInWardrobe
                                ? Colors.green
                                : colorScheme.primary,
                            onPressed: onAddToWardrobe!,
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        design.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Rs. ${design.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (onEdit != null || onDelete != null) ...[
                            if (onEdit != null)
                              _MiniAction(
                                icon: Icons.edit_outlined,
                                tooltip: 'Edit',
                                onPressed: onEdit!,
                              ),
                            if (onDelete != null) ...[
                              SizedBox(width: 6),
                              _MiniAction(
                                icon: Icons.delete_outline,
                                tooltip: 'Delete',
                                color: Colors.red,
                                onPressed: onDelete!,
                              ),
                            ],
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
      padding: EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
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
        shape: CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: CircleBorder(),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, size: 20, color: Colors.white),
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
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: effectiveColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(9),
          child: SizedBox(
            width: 34,
            height: 32,
            child: Icon(icon, size: 17, color: effectiveColor),
          ),
        ),
      ),
    );
  }
}
