import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/design_model.dart';
import '../../utils/responsive.dart';
import '../../viewmodels/wardrobe_viewmodel.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/custom_button.dart';
import '../wardrobe/wardrobe_view.dart';

class DesignDetailView extends StatelessWidget {
  final Design design;

  const DesignDetailView({required this.design, super.key});

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
      appBar: AppBar(title: Text('Design Details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Design Image
            Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 220, maxHeight: 340),
              height: imageHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: design.id,
                    child: AppNetworkImage(
                      imageUrl: design.imageUrl,
                      width: double.infinity,
                      height: imageHeight,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.18),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.18),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        design.category,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.34),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Design Details
            ResponsiveCenter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Category
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              design.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                design.category,
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.favorite_outline,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Price
                  Text(
                    'Price',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Rs. ${design.price}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      _buildDetailBadge(
                        context,
                        icon: Icons.timer_outlined,
                        label: '2-3 days',
                      ),
                      SizedBox(width: 10),
                      _buildDetailBadge(
                        context,
                        icon: Icons.star_border,
                        label: 'Recommended',
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    design.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 24),
                  // Features
                  Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 12),
                  ...[
                    'Premium Quality Fabric',
                    'Expert Craftsmanship',
                    'Customizable Design',
                  ].map(
                    (feature) => Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text(
                            feature,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
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
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colorScheme.primary),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: isInWardrobe ? 'View Wardrobe' : 'Add to Wardrobe',
                  icon: Icons.checkroom_outlined,
                  backgroundColor: isInWardrobe
                      ? colorScheme.secondary
                      : null,
                  onPressed: () async {
                    if (isInWardrobe) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => WardrobeView()),
                      );
                      return;
                    }

                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    final added = await context
                        .read<WardrobeViewModel>()
                        .addDesignToWardrobe(design);

                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          added
                              ? '${design.name} added to wardrobe!'
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

  Widget _buildDetailBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
