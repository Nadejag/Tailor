import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tailor_order_model.dart';
import '../../utils/responsive.dart';
import '../../viewmodels/order_viewmodel.dart';
import 'package:tailor/widgets/measurement_widgets.dart';

class OrderBuilderView extends StatefulWidget {
  const OrderBuilderView({super.key});

  @override
  State<OrderBuilderView> createState() => _OrderBuilderViewState();
}

class _OrderBuilderViewState extends State<OrderBuilderView> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final padding = AppSpacing.pagePadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders & Package'),
        actions: [
          Consumer<OrderViewModel>(
            builder: (context, viewModel, child) {
              final spec = _presentationFor(viewModel.package.id);
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilledButton.icon(
                  onPressed: () => _showPackageSelector(viewModel),
                  icon: const Icon(Icons.workspace_premium_outlined, size: 17),
                  label: Text(viewModel.package.name),
                  style: FilledButton.styleFrom(
                    backgroundColor: spec.accent,
                    foregroundColor: spec.onAccent,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<OrderViewModel>(
        builder: (context, viewModel, child) {
          return ResponsiveCenter(
            padding: EdgeInsets.fromLTRB(
              padding,
              0,
              padding,
              MediaQuery.paddingOf(context).bottom + 18,
            ),
            child: Column(
              children: [
                _buildTabSwitcher(context, viewModel),
                const SizedBox(height: 14),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _selectedTab == 0
                        ? _buildPackageTab(context, viewModel)
                        : _selectedTab == 1
                        ? _buildOrderTab(context, viewModel)
                        : _buildPrintTab(context, viewModel),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabSwitcher(BuildContext context, OrderViewModel viewModel) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabButton(
            context,
            index: 0,
            icon: Icons.inventory_2_outlined,
            label: 'Package',
          ),
          _buildTabButton(
            context,
            index: 1,
            icon: Icons.assignment_outlined,
            label: 'Order (${viewModel.items.length})',
          ),
          _buildTabButton(
            context,
            index: 2,
            icon: Icons.print_outlined,
            label: 'Print (${viewModel.printableForms().length})',
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
  }) {
    final selected = _selectedTab == index;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: selected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageTab(BuildContext context, OrderViewModel viewModel) {
    return ListView(
      key: const ValueKey('package-tab'),
      children: [
        _buildPackageHero(context, viewModel),
        const SizedBox(height: 16),
        if (viewModel.errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _sectionCard(
              context,
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      viewModel.errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        _buildCustomerPanel(context, viewModel),
        const SizedBox(height: 16),
        Text(
          'Select ${viewModel.package.name} package items',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        ...viewModel.productsForSelectedPackage().map(
          (product) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildPackageItemCard(context, viewModel, product),
          ),
        ),
      ],
    );
  }

  void _showPackageSelector(OrderViewModel viewModel) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final packages = TailorCatalog.wardrobePackagesMap().values.toList();

        return DraggableScrollableSheet(
          initialChildSize: 0.82,
          maxChildSize: 0.95,
          minChildSize: 0.55,
          builder: (context, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: ListView(
                controller: controller,
                padding: EdgeInsets.fromLTRB(
                  18,
                  10,
                  18,
                  MediaQuery.paddingOf(context).bottom + 18,
                ),
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _packageSelectorHeader(context),
                  const SizedBox(height: 16),
                  ...packages.map(
                    (package) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _packageChoiceCard(
                        context,
                        package: package,
                        selected: viewModel.package.id == package.id,
                        onSelected: () async {
                          final navigator = Navigator.of(context);
                          final packageChanged =
                              viewModel.package.id != package.id;
                          await viewModel.setPackageById(package.id);
                          if (packageChanged) {
                            viewModel.clearItems();
                          }
                          if (!mounted) return;
                          navigator.pop();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _packageSelectorHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF162A46),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF162A46).withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFD2B34C).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD2B34C).withValues(alpha: 0.34),
              ),
            ),
            child: const Icon(Icons.diamond_outlined, color: Color(0xFFD2B34C)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Strategic Wardrobe Packages',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Choose the package that matches the customer wardrobe plan.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.keyboard_arrow_down_rounded, color: colorScheme.onPrimary),
        ],
      ),
    );
  }

  Widget _packageChoiceCard(
    BuildContext context, {
    required WardrobePackageSpec package,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    final spec = _presentationFor(package.id);
    final products = TailorCatalog.productsForPackage(package);
    final isPremium = package.id == TailorCatalog.premiumPackage.id;

    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: spec.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? spec.accent : spec.border,
            width: selected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: spec.accent.withValues(alpha: selected ? 0.20 : 0.10),
              blurRadius: selected ? 24 : 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: spec.accent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(spec.icon, color: spec.onAccent, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              package.name.toUpperCase(),
                              style: TextStyle(
                                color: spec.title,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (isPremium)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD2B34C),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Premium',
                                style: TextStyle(
                                  color: Color(0xFF1A2437),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        package.priceLabel,
                        style: TextStyle(
                          color: spec.accent,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: selected ? spec.accent : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: spec.accent, width: 1.5),
                  ),
                  child: selected
                      ? Icon(Icons.check, size: 18, color: spec.onAccent)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              package.description,
              style: TextStyle(
                color: spec.body,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? spec.accent.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.70),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: spec.border),
              ),
              child: Column(
                children: [
                  Text(
                    spec.combinations,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: spec.title,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    spec.valueLine,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: spec.body.withValues(alpha: 0.78),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13),
            Text(
              _allocationSummary(package),
              style: TextStyle(
                color: spec.body,
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _packageMetaPill(
                  context,
                  spec: spec,
                  icon: Icons.checkroom_outlined,
                  label: '${package.allocations.length} categories',
                ),
                _packageMetaPill(
                  context,
                  spec: spec,
                  icon: Icons.inventory_2_outlined,
                  label:
                      '${package.allocations.fold<int>(0, (sum, item) => sum + item.quantity)} items',
                ),
                _packageMetaPill(
                  context,
                  spec: spec,
                  icon: Icons.auto_awesome_outlined,
                  label: products.length == 1 ? 'Custom items' : 'Admin-ready',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _packageMetaPill(
    BuildContext context, {
    required _PackagePresentation spec,
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: spec.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: spec.accent, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: spec.title,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  String _allocationSummary(WardrobePackageSpec package) {
    final entries = package.allocations.map((allocation) {
      final product = TailorCatalog.productByKey(allocation.productKey);
      final name = allocation.quantity == 1
          ? product.name
          : _pluralProductName(product.name);
      return '${allocation.quantity} $name';
    }).toList();

    return entries.join('  |  ');
  }

  String _pluralProductName(String name) {
    if (name.endsWith('Square')) return '${name}s';
    if (name.endsWith('Suit')) return '${name}s';
    if (name.endsWith('Trouser')) return '${name}s';
    if (name.endsWith('Blazer')) return '${name}s';
    if (name.endsWith('Waistcoat')) return '${name}s';
    if (name.endsWith('Tie')) return '${name}s';
    if (name == 'Shirt') return 'Shirts';
    return name;
  }

  Widget _buildPackageHero(BuildContext context, OrderViewModel viewModel) {
    final spec = _presentationFor(viewModel.package.id);
    final progress = viewModel.totalPackageQuantity == 0
        ? 0.0
        : viewModel.selectedQuantity / viewModel.totalPackageQuantity;
    final progressLabel = '${(progress.clamp(0.0, 1.0) * 100).round()}%';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      decoration: BoxDecoration(
        color: spec.hero,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: spec.accent.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: spec.accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: spec.accent.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Icon(spec.icon, color: spec.accent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewModel.package.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        viewModel.package.subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.74),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Text(
                    viewModel.package.priceLabel,
                    style: TextStyle(
                      color: spec.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              viewModel.package.description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 10,
                      backgroundColor: Colors.white.withValues(alpha: 0.14),
                      valueColor: AlwaysStoppedAnimation(spec.accent),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  progressLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _heroStat(
                  icon: Icons.checkroom_outlined,
                  label: 'Package Qty',
                  value: '${viewModel.totalPackageQuantity}',
                ),
                _heroStat(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Selected',
                  value: '${viewModel.selectedQuantity}',
                ),
                _heroStat(
                  icon: Icons.verified_outlined,
                  label: 'Complete',
                  value: '${viewModel.completedItems}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerPanel(BuildContext context, OrderViewModel viewModel) {
    return _sectionCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            context,
            title: 'Order details',
            subtitle:
                'These details appear on every separate department print form.',
            icon: Icons.receipt_long_outlined,
          ),
          const SizedBox(height: 14),
          TextFormField(
            initialValue: viewModel.customerName,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Customer name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: viewModel.setCustomerName,
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: viewModel.contactNumber,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Contact number',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            onChanged: viewModel.setContactNumber,
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: viewModel.invoiceNumber,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Invoice number',
              prefixIcon: Icon(Icons.numbers_outlined),
            ),
            onChanged: viewModel.setInvoiceNumber,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _dateButton(
                context,
                label: 'Order Date',
                value: _formatDate(viewModel.orderDate),
                onTap: () async {
                  final date = await _pickDate(context, viewModel.orderDate);
                  if (date != null) viewModel.setOrderDate(date);
                },
              ),
              _dateButton(
                context,
                label: 'Try Date',
                value: viewModel.tryDate == null
                    ? 'Select'
                    : _formatDate(viewModel.tryDate!),
                onTap: () async {
                  final date = await _pickDate(
                    context,
                    viewModel.tryDate ?? DateTime.now(),
                  );
                  viewModel.setTryDate(date);
                },
              ),
              _dateButton(
                context,
                label: 'Promise Date',
                value: viewModel.promiseDate == null
                    ? 'Select'
                    : _formatDate(viewModel.promiseDate!),
                onTap: () async {
                  final date = await _pickDate(
                    context,
                    viewModel.promiseDate ??
                        DateTime.now().add(const Duration(days: 7)),
                  );
                  viewModel.setPromiseDate(date);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateButton(
    BuildContext context, {
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        constraints: const BoxConstraints(minWidth: 145),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month_outlined, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime initialDate) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
  }

  Widget _buildPackageItemCard(
    BuildContext context,
    OrderViewModel viewModel,
    TailorProductSpec product,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final allocation = viewModel.allocationFor(product.key);
    final used = viewModel.usedFor(product.key);
    final remaining = viewModel.remainingFor(product.key);
    final components = TailorCatalog.componentsFor(product.key);
    final isFull = remaining <= 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFull
              ? Colors.green.withValues(alpha: 0.34)
              : colorScheme.outlineVariant,
          width: isFull ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: isFull ? 0.09 : 0.05),
            blurRadius: isFull ? 20 : 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: isFull
                      ? Colors.green.withValues(alpha: 0.12)
                      : colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isFull ? Icons.done_all : _iconForProduct(product.key),
                  color: isFull ? Colors.green : colorScheme.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    if (components.length > 1) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Separate forms: ${components.map((e) => e.name).join(' + ')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isFull
                      ? Colors.green.withValues(alpha: 0.10)
                      : colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$used/$allocation',
                  style: TextStyle(
                    color: isFull ? Colors.green : colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Package slots',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _packageSlotDots(
                        context,
                        total: allocation,
                        filled: used,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: isFull
                      ? null
                      : () {
                          viewModel.addPackageProduct(product.key);
                          setState(() => _selectedTab = 1);
                        },
                  child: Text(isFull ? 'Full' : 'Add to order'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _smallPill(context, label: 'Selected $used'),
              if (remaining == 0)
                _smallPill(context, label: 'Package full', strong: true),
              if (allocation > 1)
                _smallPill(context, label: '${components.length} forms'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _packageSlotDots(
    BuildContext context, {
    required int total,
    required int filled,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    const activeColors = [
      Color(0xFF006D77),
      Color(0xFF7C3AED),
      Color(0xFFE76F51),
      Color(0xFF16A34A),
      Color(0xFFD2B34C),
      Color(0xFF2563EB),
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(total, (index) {
        final isFilled = index < filled;
        final activeColor = activeColors[index % activeColors.length];

        return TweenAnimationBuilder<double>(
          key: ValueKey('$total-$filled-$index'),
          tween: Tween<double>(begin: 0, end: isFilled ? 1 : 0),
          duration: Duration(milliseconds: 260 + (index % 6) * 45),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            final color = Color.lerp(
              colorScheme.outlineVariant.withValues(alpha: 0.55),
              activeColor,
              value,
            )!;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: value == 0
                    ? null
                    : [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.28),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildOrderTab(BuildContext context, OrderViewModel viewModel) {
    return ListView(
      key: const ValueKey('order-tab'),
      children: [
        if (viewModel.items.isEmpty)
          _emptyState(
            context,
            icon: Icons.assignment_add,
            title: 'No order item selected yet',
            message:
                'Open the Package tab and add items from the selected wardrobe package.',
          )
        else ...[
          _buildOrderActions(context, viewModel),
          const SizedBox(height: 14),
          _buildOrderProgressCard(context, viewModel),
          const SizedBox(height: 14),
          ...viewModel.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOrderItemCard(context, viewModel, item),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: viewModel.isBusy
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final ok = await viewModel.forwardOrder();
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? 'Order is ready. Separate department forms are generated.'
                              : viewModel.errorMessage,
                        ),
                        backgroundColor: ok ? Colors.green : Colors.red,
                      ),
                    );
                    if (ok) setState(() => _selectedTab = 2);
                  },
            icon: viewModel.isBusy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_outlined),
            label: const Text('Forward order to departments'),
          ),
        ],
      ],
    );
  }

  Widget _buildOrderActions(BuildContext context, OrderViewModel viewModel) {
    return _sectionCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orders ready for stitching',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Review the selected items, then forward the completed order to the departments.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: viewModel.items.isEmpty
                    ? null
                    : () => setState(() => _selectedTab = 2),
                icon: const Icon(Icons.print_outlined),
                label: const Text('Preview queue'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _smallPill(
                context,
                label: 'Items ${viewModel.items.length}',
                strong: true,
              ),
              _smallPill(
                context,
                label: 'Complete ${viewModel.completedItems}',
              ),
              _smallPill(
                context,
                label:
                    'Forwardable ${viewModel.canForwardOrder ? 'Yes' : 'No'}',
                strong: viewModel.canForwardOrder,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: viewModel.items.isEmpty
                      ? null
                      : viewModel.clearItems,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Clear all items'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: viewModel.items.isEmpty
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final ok = await viewModel.forwardOrder();
                          if (!mounted) return;
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? 'Order forwarded to department queue.'
                                    : viewModel.errorMessage,
                              ),
                              backgroundColor: ok ? Colors.green : Colors.red,
                            ),
                          );
                          if (ok) setState(() => _selectedTab = 2);
                        },
                  icon: viewModel.isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_outlined),
                  label: const Text('Forward order'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderProgressCard(
    BuildContext context,
    OrderViewModel viewModel,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final total = viewModel.items.length;
    final progress = total == 0 ? 0.0 : viewModel.completedItems / total;
    final statusColor = viewModel.canForwardOrder
        ? Colors.green
        : colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 54,
                height: 54,
                child: CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: 5,
                  backgroundColor: statusColor.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(statusColor),
                ),
              ),
              Icon(
                viewModel.canForwardOrder ? Icons.verified : Icons.rule,
                color: statusColor,
                size: 24,
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.canForwardOrder
                      ? 'Order complete'
                      : 'Complete measurements and styling',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Completed ${viewModel.completedItems} of ${viewModel.items.length} selected package items.',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 7,
                    backgroundColor: statusColor.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(statusColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemCard(
    BuildContext context,
    OrderViewModel viewModel,
    TailorOrderItem item,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final complete = TailorCatalog.isItemComplete(item);
    final missing = viewModel.missingForItem(item);
    final components = TailorCatalog.componentsFor(item.productKey);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: complete
              ? Colors.green.withValues(alpha: 0.28)
              : colorScheme.outlineVariant,
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: viewModel.items.first.id == item.id,
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        leading: CircleAvatar(
          backgroundColor: complete
              ? Colors.green.withValues(alpha: 0.12)
              : colorScheme.tertiary.withValues(alpha: 0.12),
          child: Icon(
            complete ? Icons.done_all : _iconForProduct(item.productKey),
            color: complete ? Colors.green : colorScheme.tertiary,
          ),
        ),
        title: Text(
          item.productName,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          complete
              ? 'Ready for department print'
              : 'Missing ${missing.length} requirement group${missing.length == 1 ? '' : 's'}',
        ),
        trailing: IconButton(
          tooltip: 'Remove',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => viewModel.removeItem(item.id),
        ),
        children: [
          if (missing.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: colorScheme.tertiary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.tertiary.withValues(alpha: 0.18),
                ),
              ),
              child: Text(
                'Required before forwarding: ${missing.take(6).join(' • ')}${missing.length > 6 ? ' ...' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ...components.map(
            (component) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildComponentForm(context, viewModel, item, component),
            ),
          ),
          TextFormField(
            initialValue: item.notes,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'General item notes',
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            onChanged: (value) => viewModel.updateItemNotes(item.id, value),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentForm(
    BuildContext context,
    OrderViewModel viewModel,
    TailorOrderItem item,
    TailorProductSpec component,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_iconForProduct(component.key), color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      component.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      component.department,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizeSelectorField(
            key: ValueKey('size-${item.id}-${component.key}'),
            label: component.sizeLabel,
            value: item.sizes[component.key] ?? '',
            suggestions: (query) =>
                TailorCatalog.sizeSuggestions(component.key, query),
            onChanged: (value) =>
                viewModel.updateSize(item.id, component.key, value),
          ),
          if (component.measurementFields.isNotEmpty) ...[
            const SizedBox(height: 14),
            _subSectionLabel(context, 'Measurements'),
            const SizedBox(height: 8),
            ...component.measurementFields.map((field) {
              final entry =
                  item.measurements[TailorCatalog.measurementKey(
                    component.key,
                    field.label,
                  )] ??
                  const MeasurementEntry();
              return MeasurementInputRow(
                key: ValueKey(
                  'measurement-${item.id}-${component.key}-${field.label}',
                ),
                label: field.label,
                entry: entry,
                onBodyChanged: (value) => viewModel.updateMeasurement(
                  itemId: item.id,
                  componentKey: component.key,
                  fieldLabel: field.label,
                  body: value,
                ),
                onFinishedChanged: (value) => viewModel.updateMeasurement(
                  itemId: item.id,
                  componentKey: component.key,
                  fieldLabel: field.label,
                  finished: value,
                ),
                onRemarksChanged: (value) => viewModel.updateMeasurement(
                  itemId: item.id,
                  componentKey: component.key,
                  fieldLabel: field.label,
                  remarks: value,
                ),
              );
            }),
          ],
          if (component.stylingSections.isNotEmpty) ...[
            const SizedBox(height: 14),
            _subSectionLabel(context, 'Styling information'),
            const SizedBox(height: 8),
            ...component.stylingSections.map(
              (section) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: StylingSectionField(
                  key: ValueKey(
                    'style-${item.id}-${component.key}-${section.title}',
                  ),
                  section: section,
                  selectedValue:
                      item.stylingSelections[TailorCatalog.styleKey(
                        component.key,
                        section.title,
                      )],
                  note:
                      item.stylingNotes[TailorCatalog.styleKey(
                        component.key,
                        section.title,
                      )] ??
                      '',
                  onSelected: (value) => viewModel.updateStyling(
                    itemId: item.id,
                    componentKey: component.key,
                    sectionTitle: section.title,
                    value: value,
                  ),
                  onNoteChanged: (value) => viewModel.updateStylingNote(
                    itemId: item.id,
                    componentKey: component.key,
                    sectionTitle: section.title,
                    value: value,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrintTab(BuildContext context, OrderViewModel viewModel) {
    final forms = viewModel.printableForms();

    return ListView(
      key: const ValueKey('print-tab'),
      children: [
        if (forms.isEmpty)
          _emptyState(
            context,
            icon: Icons.print_disabled_outlined,
            title: 'No printable forms yet',
            message:
                'Add package items first. Every item will create a separate printable form for the relevant department.',
          )
        else ...[
          _sectionCard(
            context,
            child: _sectionTitle(
              context,
              title: 'Department print queue',
              subtitle:
                  'Each card opens one separate form: shirt to shirt department, coat to coat department, pant to pant department, and so on.',
              icon: Icons.print_outlined,
            ),
          ),
          const SizedBox(height: 12),
          ...forms.map(
            (form) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildPrintQueueCard(context, viewModel, form),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPrintQueueCard(
    BuildContext context,
    OrderViewModel viewModel,
    DepartmentPrintForm form,
  ) {
    final complete = TailorCatalog.isItemComplete(form.item);
    final colorScheme = Theme.of(context).colorScheme;

    return _sectionCard(
      context,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: complete
                  ? Colors.green.withValues(alpha: 0.1)
                  : colorScheme.tertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              _iconForProduct(form.component.key),
              color: complete ? Colors.green : colorScheme.tertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  form.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  form.department,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (!complete)
                  Text(
                    'Incomplete: fill measurements and styling first',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.tertiary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Preview'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PrintableFormPreviewView(
                    form: form,
                    customerName: viewModel.customerName,
                    contactNumber: viewModel.contactNumber,
                    invoiceNumber: viewModel.invoiceNumber,
                    orderDate: viewModel.orderDate,
                    tryDate: viewModel.tryDate,
                    promiseDate: viewModel.promiseDate,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary),
        const SizedBox(width: 10),
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
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _subSectionLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _smallPill(
    BuildContext context, {
    required String label,
    bool strong = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: strong
            ? colorScheme.primary.withValues(alpha: 0.1)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: strong ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _emptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 68,
              color: colorScheme.primary.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackagePresentation {
  final Color accent;
  final Color onAccent;
  final Color hero;
  final Color surface;
  final Color border;
  final Color title;
  final Color body;
  final IconData icon;
  final String combinations;
  final String valueLine;

  const _PackagePresentation({
    required this.accent,
    required this.onAccent,
    required this.hero,
    required this.surface,
    required this.border,
    required this.title,
    required this.body,
    required this.icon,
    required this.combinations,
    required this.valueLine,
  });
}

const _packagePresentations = {
  'introductory_wardrobe': _PackagePresentation(
    accent: Color(0xFF2563EB),
    onAccent: Colors.white,
    hero: Color(0xFF213E6A),
    surface: Color(0xFFF4F8FF),
    border: Color(0xFFC9D9F8),
    title: Color(0xFF17345F),
    body: Color(0xFF435979),
    icon: Icons.school_outlined,
    combinations: '58 Unique Outfit Combinations',
    valueLine: 'PKR 2,586 per outfit',
  ),
  'deluxe_wardrobe': _PackagePresentation(
    accent: Color(0xFF7C3AED),
    onAccent: Colors.white,
    hero: Color(0xFF34235D),
    surface: Color(0xFFF8F4FF),
    border: Color(0xFFDCCCF8),
    title: Color(0xFF30204F),
    body: Color(0xFF5B4C74),
    icon: Icons.style_outlined,
    combinations: '464 Unique Outfit Combinations',
    valueLine: 'PKR 647 per outfit',
  ),
  'premium_wardrobe': _PackagePresentation(
    accent: Color(0xFFD2B34C),
    onAccent: Color(0xFF1A2437),
    hero: Color(0xFF16243A),
    surface: Color(0xFFFFFAE8),
    border: Color(0xFFE6CA69),
    title: Color(0xFF172238),
    body: Color(0xFF5D5130),
    icon: Icons.workspace_premium_outlined,
    combinations: '3,648 Unique Outfit Combinations',
    valueLine: 'PKR 164 per outfit over 5 years',
  ),
};

_PackagePresentation _presentationFor(String packageId) {
  return _packagePresentations[packageId] ??
      _packagePresentations[TailorCatalog.premiumPackage.id]!;
}

class SizeSelectorField extends StatefulWidget {
  final String label;
  final String value;
  final List<String> Function(String query) suggestions;
  final ValueChanged<String> onChanged;

  const SizeSelectorField({
    super.key,
    required this.label,
    required this.value,
    required this.suggestions,
    required this.onChanged,
  });

  @override
  State<SizeSelectorField> createState() => _SizeSelectorFieldState();
}

class _SizeSelectorFieldState extends State<SizeSelectorField> {
  late final TextEditingController _controller;
  late List<String> _suggestions;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _suggestions = widget.suggestions(widget.value);
  }

  @override
  void didUpdateWidget(covariant SizeSelectorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
      _suggestions = widget.suggestions(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.label,
            helperText: 'Type a value; matching size options appear below.',
            prefixIcon: const Icon(Icons.arrow_drop_down_circle_outlined),
          ),
          onChanged: (value) {
            widget.onChanged(value);
            setState(() => _suggestions = widget.suggestions(value));
          },
        ),
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions.map((suggestion) {
              final selected = suggestion == _controller.text;
              return ChoiceChip(
                label: Text(suggestion),
                selected: selected,
                onSelected: (_) {
                  _controller.text = suggestion;
                  widget.onChanged(suggestion);
                  setState(() => _suggestions = widget.suggestions(suggestion));
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

// MeasurementInputRow and StylingSectionField moved to lib/widgets/measurement_widgets.dart

class PrintableFormPreviewView extends StatelessWidget {
  final DepartmentPrintForm form;
  final String customerName;
  final String contactNumber;
  final String invoiceNumber;
  final DateTime orderDate;
  final DateTime? tryDate;
  final DateTime? promiseDate;

  const PrintableFormPreviewView({
    super.key,
    required this.form,
    required this.customerName,
    required this.contactNumber,
    required this.invoiceNumber,
    required this.orderDate,
    this.tryDate,
    this.promiseDate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('${form.component.name} Print Form')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'This ${form.component.name} form is separated for ${form.department}.',
              ),
            ),
          );
        },
        icon: const Icon(Icons.print_outlined),
        label: const Text('Print Ready'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: SelectionArea(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _iconForProduct(form.component.key),
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MEASUREMENTS FORM',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: colorScheme.primary,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                form.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                form.department,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _printInfoGrid(context),
                    const SizedBox(height: 20),
                    _printBlockTitle('Measurements'),
                    const SizedBox(height: 8),
                    _printMeasurementTable(context),
                    const SizedBox(height: 20),
                    _printBlockTitle('Styling'),
                    const SizedBox(height: 8),
                    _printStylingList(context),
                    if (form.item.notes.trim().isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _printBlockTitle('General Notes'),
                      const SizedBox(height: 8),
                      Text(form.item.notes),
                    ],
                    const SizedBox(height: 40),
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        SizedBox(width: 20),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Expanded(child: Text('Customer Signature')),
                        SizedBox(width: 20),
                        Expanded(child: Text('Tailor Signature')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _printInfoGrid(BuildContext context) {
    final size = form.item.sizes[form.component.key] ?? '';
    final data = <MapEntry<String, String>>[
      MapEntry(
        'Name',
        customerName.trim().isEmpty ? '________________' : customerName,
      ),
      MapEntry(
        'Contact',
        contactNumber.trim().isEmpty ? '________________' : contactNumber,
      ),
      MapEntry(
        'Invoice #',
        invoiceNumber.trim().isEmpty ? '________________' : invoiceNumber,
      ),
      MapEntry('Order Date', _formatDate(orderDate)),
      MapEntry(
        'Try Date',
        tryDate == null ? '________________' : _formatDate(tryDate!),
      ),
      MapEntry(
        'Promise Date',
        promiseDate == null ? '________________' : _formatDate(promiseDate!),
      ),
      MapEntry('Size', size.trim().isEmpty ? '________________' : size),
      MapEntry('Department', form.department),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: data.map((entry) {
        return Container(
          width: MediaQuery.sizeOf(context).width < 520 ? double.infinity : 180,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                entry.value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _printMeasurementTable(BuildContext context) {
    if (form.component.measurementFields.isEmpty) {
      return Text('No measurements required for this accessory.');
    }

    return Table(
      border: TableBorder.all(
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
      columnWidths: const {
        0: FlexColumnWidth(1.2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1.4),
      },
      children: [
        _tableRow(['Measurement', 'Body', 'Finished', 'Remarks'], header: true),
        ...form.component.measurementFields.map((field) {
          final entry =
              form.item.measurements[TailorCatalog.measurementKey(
                form.component.key,
                field.label,
              )] ??
              const MeasurementEntry();
          return _tableRow([
            field.label,
            entry.body,
            entry.finished,
            entry.remarks,
          ]);
        }),
      ],
    );
  }

  TableRow _tableRow(List<String> values, {bool header = false}) {
    return TableRow(
      children: values.map((value) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            value.trim().isEmpty ? '—' : value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: header ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _printStylingList(BuildContext context) {
    if (form.component.stylingSections.isEmpty) {
      return const Text('No styling sections required.');
    }

    return Column(
      children: form.component.stylingSections.map((section) {
        final key = TailorCatalog.styleKey(form.component.key, section.title);
        final selected = form.item.stylingSelections[key] ?? '';
        final note = form.item.stylingNotes[key] ?? '';
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 3),
              Text(selected.trim().isEmpty ? 'Not selected' : selected),
              if (note.trim().isNotEmpty) ...[
                const SizedBox(height: 3),
                Text('Note: $note'),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _printBlockTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
      ),
    );
  }
}

IconData _iconForProduct(String productKey) {
  switch (productKey) {
    case TailorCatalog.shirtKey:
      return Icons.checkroom_outlined;
    case TailorCatalog.coatKey:
    case TailorCatalog.blazerKey:
      return Icons.business_center_outlined;
    case TailorCatalog.pantKey:
    case TailorCatalog.trouserKey:
      return Icons.line_weight_outlined;
    case TailorCatalog.waistcoatKey:
      return Icons.account_balance_wallet_outlined;
    case TailorCatalog.kameezKey:
    case TailorCatalog.shalwarKey:
    case TailorCatalog.shalwarKameezKey:
      return Icons.accessibility_new_outlined;
    case TailorCatalog.tieKey:
      return Icons.linear_scale_outlined;
    case TailorCatalog.pocketSquareKey:
      return Icons.crop_square_outlined;
    case TailorCatalog.twoPieceSuitKey:
    case TailorCatalog.threePieceSuitKey:
      return Icons.military_tech_outlined;
    default:
      return Icons.checkroom_outlined;
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
