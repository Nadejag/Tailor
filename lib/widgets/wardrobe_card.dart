import 'dart:io';
import 'package:flutter/material.dart';
import '../models/wardrobe_model.dart';
import 'app_network_image.dart';

class WardrobeCard extends StatelessWidget {
  final Wardrobe wardrobe;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const WardrobeCard({
    required this.wardrobe,
    required this.onTap,
    this.onDelete,
    super.key,
  });

  static const _statuses = ['selected', 'processing', 'completed'];

  static _StatusStyle _style(String status) {
    switch (status.toLowerCase()) {
      case 'selected':
        return _StatusStyle(
          color: const Color(0xFF006D77),
          bg: const Color(0xFFE0F2F4),
          icon: Icons.bookmark_added_outlined,
          label: 'Selected',
        );
      case 'processing':
        return _StatusStyle(
          color: const Color(0xFFB45309),
          bg: const Color(0xFFFEF3C7),
          icon: Icons.content_cut_outlined,
          label: 'Processing',
        );
      case 'completed':
        return _StatusStyle(
          color: const Color(0xFF166534),
          bg: const Color(0xFFDCFCE7),
          icon: Icons.check_circle_outline,
          label: 'Completed',
        );
      default:
        return _StatusStyle(
          color: Colors.grey,
          bg: Colors.grey.shade100,
          icon: Icons.circle_outlined,
          label: status,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final st = _style(wardrobe.status);
    final imageUrl = wardrobe.design?.imageUrl ?? '';
    final isLocalFile = imageUrl.startsWith('/');
    final currentStep = _statuses.indexOf(wardrobe.status.toLowerCase());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image with overlays ────────────────────────────────────
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (isLocalFile)
                      Image.file(File(imageUrl), fit: BoxFit.cover)
                    else
                      AppNetworkImage(
                        imageUrl: imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    // gradient
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // category pill top-left
                    Positioned(
                      top: 10,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          wardrobe.design?.category ?? '',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    // status badge top-right
                    Positioned(
                      top: 10,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: st.bg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(st.icon, size: 13, color: st.color),
                            const SizedBox(width: 5),
                            Text(
                              st.label,
                              style: TextStyle(
                                  color: st.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // name + price bottom
                    Positioned(
                      bottom: 10,
                      left: 12,
                      right: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              wardrobe.design?.name ?? 'Design',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Rs. ${wardrobe.design?.price.toStringAsFixed(0) ?? '–'}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Progress stepper ───────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProgressStepper(currentStep: currentStep),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // date
                        Icon(Icons.calendar_today_outlined,
                            size: 13, color: cs.onSurfaceVariant),
                        const SizedBox(width: 5),
                        Text(
                          _formatDate(wardrobe.createdAt),
                          style: TextStyle(
                              fontSize: 12, color: cs.onSurfaceVariant),
                        ),
                        const Spacer(),
                        // action button
                        GestureDetector(
                          onTap: onTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Update',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        if (onDelete != null) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: onDelete,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.delete_outline,
                                  color: Colors.red, size: 17),
                            ),
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
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _ProgressStepper extends StatelessWidget {
  final int currentStep; // 0=selected, 1=processing, 2=completed

  const _ProgressStepper({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const labels = ['Selected', 'Processing', 'Completed'];
    const icons = [
      Icons.bookmark_added_outlined,
      Icons.content_cut_outlined,
      Icons.check_circle_outline,
    ];
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: List.generate(3, (i) {
        final done = i <= currentStep;
        final active = i == currentStep;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: active ? 32 : 26,
                      height: active ? 32 : 26,
                      decoration: BoxDecoration(
                        color: done ? cs.primary : Colors.grey.shade200,
                        shape: BoxShape.circle,
                        border: active
                            ? Border.all(
                                color: cs.primary.withValues(alpha: 0.3),
                                width: 3)
                            : null,
                      ),
                      child: Icon(
                        icons[i],
                        size: active ? 16 : 14,
                        color: done ? Colors.white : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: active
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: done ? cs.primary : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < 2)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: i < currentStep
                          ? cs.primary
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _StatusStyle {
  final Color color;
  final Color bg;
  final IconData icon;
  final String label;

  const _StatusStyle({
    required this.color,
    required this.bg,
    required this.icon,
    required this.label,
  });
}
