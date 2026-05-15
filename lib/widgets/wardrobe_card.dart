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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selected':
        return Colors.blue;
      case 'stitching':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 360;
    final imageWidth = isCompact ? 82.0 : 100.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Design Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: SizedBox(
                width: imageWidth,
                height: 120,
                child: AppNetworkImage(
                  imageUrl: wardrobe.design?.imageUrl ?? '',
                  width: imageWidth,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      wardrobe.design?.name ?? 'Design',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      wardrobe.design?.category ?? 'Category',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          wardrobe.status,
                        ).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        wardrobe.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(wardrobe.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Delete button
            if (onDelete != null)
              Padding(
                padding: EdgeInsets.only(right: 8),
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: onDelete,
                  icon: Icon(Icons.close, color: Colors.red, size: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
