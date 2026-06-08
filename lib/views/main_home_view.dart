import 'package:flutter/material.dart';
import 'designs/design_list_view.dart';
import 'wardrobe/wardrobe_view.dart';
import 'measurements/measurement_view.dart';
import 'orders/order_builder_view.dart';
import 'payments/payment_view.dart';

class MainHomeView extends StatefulWidget {
  const MainHomeView({super.key});

  @override
  State<MainHomeView> createState() => _MainHomeViewState();
}

class _MainHomeViewState extends State<MainHomeView> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    DesignListView(),
    WardrobeView(),
    OrderBuilderView(),
    MeasurementView(),
    PaymentView(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final useRail = width >= 760;

    return Scaffold(
      body: Row(
        children: [
          if (useRail)
            SafeArea(
              child: Container(
                width: 108,
                margin: EdgeInsets.fromLTRB(14, 14, 0, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colorScheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.07),
                      blurRadius: 22,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: NavigationRail(
                  backgroundColor: Colors.transparent,
                  selectedIndex: _selectedIndex,
                  minWidth: 108,
                  groupAlignment: -0.6,
                  labelType: NavigationRailLabelType.all,
                  indicatorColor: colorScheme.primary.withValues(alpha: 0.14),
                  onDestinationSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                  leading: Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 18),
                    child: Icon(
                      Icons.checkroom,
                      color: colorScheme.primary,
                      size: 32,
                    ),
                  ),
                  destinations: _destinations
                      .map(
                        (item) => NavigationRailDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: Text(item.label),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: useRail
          ? null
          : SafeArea(
              top: false,
              child: Container(
                margin: EdgeInsets.fromLTRB(12, 0, 12, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colorScheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: NavigationBar(
                    height: 66,
                    selectedIndex: _selectedIndex,
                    indicatorColor: colorScheme.primary.withValues(alpha: 0.14),
                    backgroundColor: Colors.white,
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysShow,
                    onDestinationSelected: (index) {
                      setState(() => _selectedIndex = index);
                    },
                    destinations: _destinations
                        .map(
                          (item) => NavigationDestination(
                            icon: Icon(item.icon),
                            selectedIcon: Icon(item.selectedIcon),
                            label: item.label,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
    );
  }
}

const _destinations = [
  _AppDestination(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    label: 'Home',
  ),
  _AppDestination(
    icon: Icons.checkroom_outlined,
    selectedIcon: Icons.checkroom,
    label: 'Wardrobe',
  ),
  _AppDestination(
    icon: Icons.assignment_outlined,
    selectedIcon: Icons.assignment,
    label: 'Orders',
  ),
  _AppDestination(
    icon: Icons.straighten_outlined,
    selectedIcon: Icons.straighten,
    label: 'Measure',
  ),
  _AppDestination(
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long,
    label: 'Payments',
  ),
];

class _AppDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _AppDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
