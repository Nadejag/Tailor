import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/responsive.dart';
import '../../viewmodels/wardrobe_viewmodel.dart';
import '../../widgets/shimmer.dart';
import '../../widgets/wardrobe_card.dart';

class WardrobeView extends StatefulWidget {
  const WardrobeView({super.key});

  @override
  State<WardrobeView> createState() => _WardrobeViewState();
}

class _WardrobeViewState extends State<WardrobeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WardrobeViewModel>().fetchWardrobeItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hp = AppSpacing.pagePadding(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('My Wardrobe')),
      body: Consumer<WardrobeViewModel>(
        builder: (context, vm, _) {
          return ResponsiveCenter(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // ── Stats banner ─────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(hp, 0, hp, 0),
                  child: _WardrobeBanner(vm: vm),
                ),
                const SizedBox(height: 10),

                // ── Filter chips ─────────────────────────────────────────
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: hp, vertical: 6),
                    itemCount: vm.filters.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final f = vm.filters[i];
                      final count = vm.countByStatus(f);
                      final selected = vm.selectedFilter == f;
                      return ChoiceChip(
                        label: Text('$f  $count'),
                        selected: selected,
                        onSelected: (_) => vm.filterByStatus(f),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: selected ? Colors.white : cs.onSurface,
                        ),
                        selectedColor: cs.primary,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: selected
                                ? Colors.transparent
                                : cs.outlineVariant,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // ── List ─────────────────────────────────────────────────
                if (vm.isBusy)
                  const Expanded(child: WardrobeListShimmer())
                else if (vm.wardrobeItems.isEmpty)
                  Expanded(child: _EmptyState(filter: vm.selectedFilter))
                else
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        hp, 0, hp,
                        MediaQuery.paddingOf(context).bottom + 20,
                      ),
                      itemCount: vm.wardrobeItems.length,
                      itemBuilder: (_, i) {
                        final item = vm.wardrobeItems[i];
                        return WardrobeCard(
                          wardrobe: item,
                          onTap: () => _showStatusSheet(context, vm, item.id,
                              item.status, item.design?.name ?? 'Design'),
                          onDelete: () => vm.removeFromWardrobe(item.id),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showStatusSheet(
    BuildContext context,
    WardrobeViewModel vm,
    String wardrobeId,
    String currentStatus,
    String designName,
  ) {
    const statuses = [
      _StatusOption(
        value: 'selected',
        label: 'Selected',
        subtitle: 'Design has been chosen',
        icon: Icons.bookmark_added_outlined,
        color: Color(0xFF006D77),
        bg: Color(0xFFE0F2F4),
      ),
      _StatusOption(
        value: 'processing',
        label: 'Processing',
        subtitle: 'Currently being stitched',
        icon: Icons.content_cut_outlined,
        color: Color(0xFFB45309),
        bg: Color(0xFFFEF3C7),
      ),
      _StatusOption(
        value: 'completed',
        label: 'Completed',
        subtitle: 'Ready for collection',
        icon: Icons.check_circle_outline,
        color: Color(0xFF166534),
        bg: Color(0xFFDCFCE7),
      ),
    ];

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        final cs = Theme.of(context).colorScheme;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20, 0, 20,
            MediaQuery.paddingOf(context).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(designName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Update status',
                  style: TextStyle(
                      fontSize: 13, color: cs.onSurfaceVariant)),
              const SizedBox(height: 16),
              ...statuses.map((opt) {
                final isCurrent = currentStatus == opt.value;
                return GestureDetector(
                  onTap: isCurrent
                      ? null
                      : () {
                          vm.updateStatus(wardrobeId, opt.value);
                          Navigator.pop(context);
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isCurrent ? opt.bg : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCurrent ? opt.color : cs.outlineVariant,
                        width: isCurrent ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: opt.bg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(opt.icon, color: opt.color, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(opt.label,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isCurrent
                                        ? opt.color
                                        : cs.onSurface,
                                  )),
                              Text(opt.subtitle,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: cs.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        if (isCurrent)
                          Icon(Icons.check_circle,
                              color: opt.color, size: 20),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    vm.removeFromWardrobe(wardrobeId);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Remove from Wardrobe',
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side:
                        BorderSide(color: Colors.red.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Banner ───────────────────────────────────────────────────────────────────

class _WardrobeBanner extends StatelessWidget {
  final WardrobeViewModel vm;
  const _WardrobeBanner({required this.vm});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.secondary, cs.secondary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: cs.secondary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${vm.totalItems} Saved Designs',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _MiniStat(
                        label: 'Selected',
                        value: vm.countByStatus('Selected')),
                    const SizedBox(width: 8),
                    _MiniStat(
                        label: 'Processing',
                        value: vm.countByStatus('Processing')),
                    const SizedBox(width: 8),
                    _MiniStat(
                        label: 'Done',
                        value: vm.countByStatus('Completed')),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.checkroom, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$value $label',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.checkroom_outlined,
                size: 40, color: cs.primary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 16),
          Text(
            filter == 'All' ? 'Wardrobe is empty' : 'No $filter items',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Add designs from the Home tab',
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ─── Status option model ──────────────────────────────────────────────────────

class _StatusOption {
  final String value;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bg;

  const _StatusOption({
    required this.value,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bg,
  });
}
