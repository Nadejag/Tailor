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
    final gap = AppSpacing.cardGap(context);
    final horizontalPadding = AppSpacing.pagePadding(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Designs'),
        actions: [
          IconButton(
            tooltip: 'Add Design',
            icon: Icon(Icons.add_circle_outline),
            onPressed: () => _showDesignForm(context),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Consumer<DesignViewModel>(
        builder: (context, viewModel, child) {
          return ResponsiveCenter(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              0,
              horizontalPadding,
              0,
            ),
            child: Column(
              children: [
                SizedBox(height: gap),
                TextField(
                  controller: _searchController,
                  onChanged: viewModel.searchDesigns,
                  decoration: InputDecoration(
                    hintText: 'Search designs, categories...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              viewModel.searchDesigns('');
                            },
                          ),
                  ),
                ),
                SizedBox(height: gap),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: viewModel.categories.length,
                    separatorBuilder: (context, index) => SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = viewModel.categories[index];
                      return ChoiceChip(
                        label: Text(category),
                        selected: viewModel.selectedCategory == category,
                        onSelected: (_) => viewModel.filterByCategory(category),
                        labelStyle: TextStyle(fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: viewModel.selectedCategory == category
                                ? Colors.transparent
                                : Colors.grey[300]!,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: gap),
                if (viewModel.isBusy)
                  Expanded(child: DesignGridShimmer())
                else if (viewModel.designs.isEmpty)
                  Expanded(
                    child: Center(
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
                            'No designs found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.only(bottom: 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: AppSpacing.gridColumns(context),
                        childAspectRatio: MediaQuery.sizeOf(context).width < 360
                            ? 0.82
                            : 0.72,
                        crossAxisSpacing: gap,
                        mainAxisSpacing: gap,
                      ),
                      itemCount: viewModel.designs.length,
                      itemBuilder: (context, index) {
                        final design = viewModel.designs[index];
                        return Consumer<WardrobeViewModel>(
                          builder: (context, wardrobeViewModel, child) {
                            final isInWardrobe = wardrobeViewModel.isInWardrobe(
                              design.id,
                            );

                            return DesignCard(
                              design: design,
                              isInWardrobe: isInWardrobe,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DesignDetailView(design: design),
                                  ),
                                );
                              },
                              onAddToWardrobe: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                final added = await wardrobeViewModel
                                    .addDesignToWardrobe(design);

                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      added
                                          ? '${design.name} added to wardrobe'
                                          : '${design.name} is already in wardrobe',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              onEdit: () =>
                                  _showDesignForm(context, design: design),
                              onDelete: () =>
                                  _confirmDeleteDesign(context, design),
                            );
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

  Future<void> _confirmDeleteDesign(BuildContext context, Design design) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete design?'),
          content: Text('${design.name} will be removed from the collection.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && context.mounted) {
      context.read<DesignViewModel>().deleteDesign(design.id);
    }
  }

  void _showDesignForm(BuildContext context, {Design? design}) {
    final nameController = TextEditingController(text: design?.name ?? '');
    final imageController = TextEditingController(text: design?.imageUrl ?? '');
    final priceController = TextEditingController(
      text: design == null ? '' : design.price.toStringAsFixed(0),
    );
    final descriptionController = TextEditingController(
      text: design?.description ?? '',
    );
    final formKey = GlobalKey<FormState>();
    String selectedCategory = design?.category ?? 'Kurta';
    String previewUrl = imageController.text.trim();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                MediaQuery.viewInsetsOf(context).bottom +
                    MediaQuery.paddingOf(context).bottom +
                    20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      design == null ? 'Add Design' : 'Edit Design',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Design Name',
                        prefixIcon: Icon(Icons.checkroom_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter design name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: context
                          .read<DesignViewModel>()
                          .categories
                          .where((category) => category != 'All')
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setSheetState(() {
                          selectedCategory = value ?? selectedCategory;
                        });
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        prefixText: 'Rs. ',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter price or 0';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: imageController,
                      decoration: InputDecoration(
                        labelText: 'Image URL',
                        prefixIcon: Icon(Icons.image_outlined),
                        helperText: 'Paste a direct image URL, or leave empty.',
                      ),
                      onChanged: (value) {
                        setSheetState(() => previewUrl = value.trim());
                      },
                    ),
                    if (previewUrl.isNotEmpty) ...[
                      SizedBox(height: 12),
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: AppNetworkImage(
                          imageUrl: previewUrl,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ],
                    SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.notes_outlined),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;

                          final viewModel = sheetContext
                              .read<DesignViewModel>();
                          final price =
                              double.tryParse(priceController.text) ?? 0;

                          if (design == null) {
                            viewModel.addDesign(
                              name: nameController.text.trim(),
                              imageUrl: imageController.text.trim(),
                              category: selectedCategory,
                              price: price,
                              description: descriptionController.text.trim(),
                            );
                          } else {
                            viewModel.updateDesign(
                              design.copyWith(
                                name: nameController.text.trim(),
                                imageUrl: imageController.text.trim(),
                                category: selectedCategory,
                                price: price,
                                description: descriptionController.text.trim(),
                              ),
                            );
                          }
                          Navigator.pop(sheetContext);
                        },
                        icon: Icon(
                          design == null
                              ? Icons.add_circle_outline
                              : Icons.save_outlined,
                        ),
                        label: Text(
                          design == null ? 'Add Design' : 'Save Changes',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
