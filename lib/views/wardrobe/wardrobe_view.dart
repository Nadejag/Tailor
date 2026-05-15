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
    final horizontalPadding = AppSpacing.pagePadding(context);

    return Scaffold(
      appBar: AppBar(title: Text('My Wardrobe')),
      body: Consumer<WardrobeViewModel>(
        builder: (context, viewModel, child) {
          return ResponsiveCenter(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SizedBox(
                  height: 56,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 10,
                    ),
                    itemCount: viewModel.filters.length,
                    separatorBuilder: (context, index) => SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = viewModel.filters[index];
                      return ChoiceChip(
                        label: Text(filter),
                        selected: viewModel.selectedFilter == filter,
                        onSelected: (_) => viewModel.filterByStatus(filter),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: viewModel.selectedFilter == filter
                                ? Colors.transparent
                                : Colors.grey[300]!,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (viewModel.isBusy)
                  Expanded(child: WardrobeListShimmer())
                else if (viewModel.wardrobeItems.isEmpty)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: AppSpacing.pageInsets(context),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.checkroom_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Your wardrobe is empty',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add designs from the shop',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        MediaQuery.paddingOf(context).bottom + 20,
                      ),
                      itemCount: viewModel.wardrobeItems.length,
                      itemBuilder: (context, index) {
                        final wardrobe = viewModel.wardrobeItems[index];
                        return WardrobeCard(
                          wardrobe: wardrobe,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              showDragHandle: true,
                              isScrollControlled: true,
                              builder: (context) {
                                return SingleChildScrollView(
                                  padding: EdgeInsets.fromLTRB(
                                    20,
                                    0,
                                    20,
                                    MediaQuery.paddingOf(context).bottom + 20,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Design name
                                      Text(
                                        wardrobe.design?.name ?? 'Design',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      // Status info
                                      Text(
                                        'Current Status',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              wardrobe.status.toUpperCase(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      // Actions
                                      Text(
                                        'Actions',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      ...['Selected', 'Stitching', 'Completed']
                                          .where(
                                            (status) =>
                                                status.toLowerCase() !=
                                                wardrobe.status,
                                          )
                                          .map(
                                            (status) => GestureDetector(
                                              onTap: () {
                                                viewModel.updateStatus(
                                                  wardrobe.id,
                                                  status.toLowerCase(),
                                                );
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                  bottom: 8,
                                                ),
                                                padding: EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey[300]!,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.update,
                                                      color: Colors.deepPurple,
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      'Mark as $status',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                      SizedBox(height: 12),
                                      GestureDetector(
                                        onTap: () {
                                          viewModel.removeFromWardrobe(
                                            wardrobe.id,
                                          );
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.red.withValues(
                                                alpha: 0.3,
                                              ),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Remove from Wardrobe',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          onDelete: () {
                            viewModel.removeFromWardrobe(wardrobe.id);
                          },
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
}
