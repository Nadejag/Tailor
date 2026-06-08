import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/design_model.dart';
import '../../models/wardrobe_model.dart';
import '../../utils/responsive.dart';
import '../../viewmodels/wardrobe_viewmodel.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/custom_button.dart';
import '../wardrobe/wardrobe_view.dart';

class DesignDetailView extends StatefulWidget {
  final Design design;

  const DesignDetailView({required this.design, super.key});

  @override
  State<DesignDetailView> createState() => _DesignDetailViewState();
}

class _DesignDetailViewState extends State<DesignDetailView> {
  late List<FabricComponentChoice> _fabricChoices;

  Design get design => widget.design;

  @override
  void initState() {
    super.initState();
    _fabricChoices = context.read<WardrobeViewModel>().fabricChoicesForDesign(
      widget.design,
    );
  }

  double get _fabricCredit => _fabricChoices.fold(
    0,
    (sum, choice) =>
        sum + (choice.customerProvidesFabric ? choice.fabricCredit : 0),
  );

  double get _adjustedPrice {
    final price = design.price - _fabricCredit;
    return price < 0 ? 0 : price;
  }

  bool get _hasCustomerFabric =>
      _fabricChoices.any((choice) => choice.customerProvidesFabric);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final wardrobeViewModel = context.watch<WardrobeViewModel>();
    final isInWardrobe = wardrobeViewModel.isInWardrobe(design.id);
    final statusLabel = design.status.isNotEmpty
        ? '${design.status[0].toUpperCase()}${design.status.substring(1)}'
        : 'Ready';
    final imageHeight = MediaQuery.sizeOf(context).height * 0.34;

    return Scaffold(
      appBar: AppBar(title: const Text('Design Details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: imageHeight.clamp(230, 350).toDouble(),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: design.id,
                    child: AppNetworkImage(
                      imageUrl: design.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.20),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.58),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: _heroChip(
                      context,
                      label: design.category,
                      icon: Icons.style_outlined,
                      dark: false,
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: _heroChip(
                      context,
                      label: statusLabel,
                      icon: Icons.verified_outlined,
                      dark: true,
                    ),
                  ),
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          design.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          design.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ResponsiveCenter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _pricePlanner(context),
                  const SizedBox(height: 16),
                  _fabricPlanner(context),
                  const SizedBox(height: 16),
                  _sectionCard(
                    context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(
                          context,
                          icon: Icons.auto_awesome_outlined,
                          title: 'Tailoring benefits',
                          subtitle:
                              'Fabric responsibility can be changed now and later stored from Firebase/admin rules.',
                        ),
                        const SizedBox(height: 14),
                        _featureRow(
                          context,
                          'Separate fabric control for each garment part',
                        ),
                        _featureRow(
                          context,
                          'Customer fabric automatically reduces payable amount',
                        ),
                        _featureRow(
                          context,
                          'Wardrobe and payments use the adjusted price',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pagePadding(context),
            12,
            AppSpacing.pagePadding(context),
            12,
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: isInWardrobe ? 'View Wardrobe' : 'Add to Wardrobe',
                  icon: Icons.checkroom_outlined,
                  backgroundColor: isInWardrobe ? colorScheme.secondary : null,
                  onPressed: () async {
                    if (isInWardrobe) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const WardrobeView()),
                      );
                      return;
                    }

                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    final added = await context
                        .read<WardrobeViewModel>()
                        .addDesignToWardrobe(
                          design,
                          fabricChoices: _fabricChoices,
                        );

                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          added
                              ? '${design.name} added with adjusted price Rs. ${_adjustedPrice.toStringAsFixed(0)}'
                              : '${design.name} is already in wardrobe',
                        ),
                        backgroundColor: added ? Colors.green : Colors.orange,
                      ),
                    );
                    if (added && navigator.mounted) navigator.pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pricePlanner(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return _sectionCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            context,
            icon: Icons.payments_outlined,
            title: 'Price planner',
            subtitle: _hasCustomerFabric
                ? 'Customer fabric selected. Payable amount is adjusted.'
                : 'Tailor fabric is included for all components.',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF17324D),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF17324D).withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _priceMetric(
                    label: 'Base',
                    value: 'Rs. ${design.price.toStringAsFixed(0)}',
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: Colors.white.withValues(alpha: 0.14),
                ),
                Expanded(
                  child: _priceMetric(
                    label: 'Fabric credit',
                    value: '- Rs. ${_fabricCredit.toStringAsFixed(0)}',
                    valueColor: const Color(0xFFD2B34C),
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: Colors.white.withValues(alpha: 0.14),
                ),
                Expanded(
                  child: _priceMetric(
                    label: 'Payable',
                    value: 'Rs. ${_adjustedPrice.toStringAsFixed(0)}',
                    valueColor: Colors.greenAccent.shade100,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Fabric credit is an editable estimate. Later this can come from Firebase package settings or admin-managed component pricing.',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fabricPlanner(BuildContext context) {
    return _sectionCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            context,
            icon: Icons.inventory_2_outlined,
            title: 'Fabric responsibility',
            subtitle:
                'Choose who provides fabric for each component before adding to wardrobe.',
          ),
          const SizedBox(height: 14),
          ...List.generate(_fabricChoices.length, (index) {
            final choice = _fabricChoices[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == _fabricChoices.length - 1 ? 0 : 10,
              ),
              child: _fabricChoiceTile(context, index, choice),
            );
          }),
        ],
      ),
    );
  }

  Widget _fabricChoiceTile(
    BuildContext context,
    int index,
    FabricComponentChoice choice,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final customer = choice.customerProvidesFabric;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: customer
            ? colorScheme.primary.withValues(alpha: 0.08)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: customer
              ? colorScheme.primary.withValues(alpha: 0.28)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: customer
                      ? colorScheme.primary.withValues(alpha: 0.12)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Icon(
                  _componentIcon(choice.componentName),
                  color: customer ? colorScheme.primary : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      choice.componentName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      customer
                          ? 'Customer cloth - credit Rs. ${choice.fabricCredit.toStringAsFixed(0)}'
                          : 'Tailor cloth included',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: customer,
                onChanged: (value) {
                  setState(() {
                    _fabricChoices[index] = choice.copyWith(
                      customerProvidesFabric: value,
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _supplyChip(
                  context,
                  label: 'Tailor fabric',
                  icon: Icons.storefront_outlined,
                  selected: !customer,
                  onTap: () {
                    setState(() {
                      _fabricChoices[index] = choice.copyWith(
                        customerProvidesFabric: false,
                      );
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _supplyChip(
                  context,
                  label: 'Customer fabric',
                  icon: Icons.person_outline,
                  selected: customer,
                  onTap: () {
                    setState(() {
                      _fabricChoices[index] = choice.copyWith(
                        customerProvidesFabric: true,
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _supplyChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _featureRow(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceMetric({
    required String label,
    required String value,
    Color valueColor = Colors.white,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: valueColor,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.62),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _heroChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool dark,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: dark
            ? Colors.black.withValues(alpha: 0.40)
            : Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: dark ? Colors.white : colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: dark ? Colors.white : colorScheme.primary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  IconData _componentIcon(String componentName) {
    final name = componentName.toLowerCase();
    if (name.contains('trouser') || name.contains('pant')) {
      return Icons.accessibility_new_outlined;
    }
    if (name.contains('coat') || name.contains('waistcoat')) {
      return Icons.checkroom_outlined;
    }
    if (name.contains('shirt') || name.contains('kameez')) {
      return Icons.dry_cleaning_outlined;
    }
    return Icons.inventory_2_outlined;
  }
}
