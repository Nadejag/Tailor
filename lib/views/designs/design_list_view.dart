import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/responsive.dart';
import '../../viewmodels/design_viewmodel.dart';
import '../../viewmodels/wardrobe_viewmodel.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/design_card.dart';
import '../../widgets/shimmer.dart';
import '../../models/design_model.dart';
import 'design_detail_view.dart';

class DesignListView extends StatefulWidget {
  const DesignListView({super.key});

  @override
  State<DesignListView> createState() => _DesignListViewState();
}

class _DesignListViewState extends State<DesignListView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DesignViewModel>().fetchDesigns();
      context.read<WardrobeViewModel>().fetchWardrobeItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hp = AppSpacing.pagePadding(context);
    final gap = AppSpacing.cardGap(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tailor App')),
      body: Consumer2<DesignViewModel, WardrobeViewModel>(
        builder: (context, vm, wardrobeVm, _) {
          return ResponsiveCenter(
            padding: EdgeInsets.fromLTRB(
              hp,
              0,
              hp,
              MediaQuery.paddingOf(context).bottom,
            ),
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: gap)),

                SliverToBoxAdapter(
                  child: _CompactBanner(
                    designCount: vm.designs.length,
                    wardrobeCount: wardrobeVm.totalItems,
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: gap)),

                SliverToBoxAdapter(
                  child: TextField(
                    controller: _searchController,
                    onChanged: vm.searchDesigns,
                    decoration: InputDecoration(
                      hintText: 'Search designs, categories…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _searchController.clear();
                                vm.searchDesigns('');
                              },
                            ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: gap)),

                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: vm.categories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final cat = vm.categories[i];
                        final selected = vm.selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: selected,
                          onSelected: (_) => vm.filterByCategory(cat),
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: selected
                                  ? Colors.transparent
                                  : Colors.grey[300]!,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: gap)),

                if (!vm.isBusy &&
                    vm.designs.isNotEmpty &&
                    vm.searchQuery.isEmpty) ...[
                  SliverToBoxAdapter(
                    child: _SectionLabel(
                      title: 'Featured',
                      subtitle: 'Top picks for you',
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 200,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        itemCount: vm.designs.take(4).length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (_, i) {
                          final design = vm.designs[i];
                          final inWardrobe = wardrobeVm.isInWardrobe(design.id);
                          return _FeaturedCard(
                            design: design,
                            isInWardrobe: inWardrobe,
                            onTap: () => _openDetail(context, design),
                            onAdd: () =>
                                _addToWardrobe(context, wardrobeVm, design),
                          );
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: gap)),
                ],

                SliverToBoxAdapter(
                  child: _SectionLabel(
                    title: vm.searchQuery.isEmpty ? 'All Designs' : 'Results',
                    subtitle: vm.searchQuery.isEmpty
                        ? '${vm.designs.length} styles available'
                        : 'Matching "${vm.searchQuery}"',
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 10)),

                if (vm.isBusy)
                  const SliverFillRemaining(child: DesignGridShimmer())
                else if (vm.designs.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.checkroom_outlined,
                            size: 56,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No designs found',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverGrid(
                    delegate: SliverChildBuilderDelegate((_, i) {
                      final design = vm.designs[i];
                      final inWardrobe = wardrobeVm.isInWardrobe(design.id);
                      return DesignCard(
                        design: design,
                        isInWardrobe: inWardrobe,
                        onTap: () => _openDetail(context, design),
                        onAddToWardrobe: () =>
                            _addToWardrobe(context, wardrobeVm, design),
                      );
                    }, childCount: vm.designs.length),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: AppSpacing.gridColumns(context),
                      childAspectRatio: 0.72,
                      crossAxisSpacing: gap,
                      mainAxisSpacing: gap,
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openDetail(BuildContext context, Design design) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => DesignDetailView(design: design)));
  }

  Future<void> _addToWardrobe(
    BuildContext context,
    WardrobeViewModel vm,
    Design design,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final added = await vm.addDesignToWardrobe(design);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '${design.name} added to wardrobe'
              : '${design.name} already in wardrobe',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ─── Compact banner ───────────────────────────────────────────────────────────

class _CompactBanner extends StatelessWidget {
  final int designCount;
  final int wardrobeCount;

  const _CompactBanner({
    required this.designCount,
    required this.wardrobeCount,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.22),
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
                Text(
                  'Find your next\nstitched look',
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _StatPill(
                      icon: Icons.style_outlined,
                      label: '$designCount Designs',
                      cs: cs,
                    ),
                    const SizedBox(width: 8),
                    _StatPill(
                      icon: Icons.checkroom_outlined,
                      label: '$wardrobeCount Saved',
                      cs: cs,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.auto_awesome, color: cs.onPrimary, size: 26),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme cs;

  const _StatPill({required this.icon, required this.label, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: cs.onPrimary, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: cs.onPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Featured horizontal card ─────────────────────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  final Design design;
  final bool isInWardrobe;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _FeaturedCard({
    required this.design,
    required this.isInWardrobe,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLocal = design.imageUrl.startsWith('/');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 148,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: design.id,
                      child: isLocal
                          ? Image.file(File(design.imageUrl), fit: BoxFit.cover)
                          : AppNetworkImage(
                              imageUrl: design.imageUrl,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.28),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 7,
                      right: 7,
                      child: GestureDetector(
                        onTap: onAdd,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isInWardrobe ? Colors.green : cs.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isInWardrobe ? Icons.check : Icons.add,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      design.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rs. ${design.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                      ),
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
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionLabel({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 1),
        Text(
          subtitle,
          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}
