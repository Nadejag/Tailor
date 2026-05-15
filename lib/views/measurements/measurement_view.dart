import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/responsive.dart';
import '../../viewmodels/measurement_viewmodel.dart';
import '../../widgets/custom_button.dart';

class MeasurementView extends StatefulWidget {
  const MeasurementView({super.key});

  @override
  State<MeasurementView> createState() => _MeasurementViewState();
}

class _MeasurementViewState extends State<MeasurementView> {
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MeasurementViewModel>().fetchMeasurements('user1');
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gap = AppSpacing.cardGap(context);

    return Scaffold(
      appBar: AppBar(title: Text('My Measurements')),
      body: Consumer<MeasurementViewModel>(
        builder: (context, viewModel, child) {
          if (_notesController.text != viewModel.notes) {
            _notesController.text = viewModel.notes;
          }

          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ResponsiveCenter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Last Update Info
                  if (viewModel.measurement != null)
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Last Updated',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Updated by ${viewModel.measurement!.updatedBy}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      _formatDate(
                                        viewModel.measurement!.updatedAt,
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 24),
                  // Measurements Grid
                  Text(
                    'Body Measurements',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: AppSpacing.gridColumns(context),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    childAspectRatio: MediaQuery.sizeOf(context).width < 360
                        ? 1.2
                        : 1.05,
                    crossAxisSpacing: gap,
                    mainAxisSpacing: gap,
                    children: [
                      _buildMeasurementCard(
                        'Chest',
                        viewModel.chest,
                        'cm',
                        Icons.accessibility,
                        () {
                          _showMeasurementDialog(
                            context,
                            'Chest',
                            viewModel.chest,
                            (value) => viewModel.setChest(value),
                          );
                        },
                      ),
                      _buildMeasurementCard(
                        'Waist',
                        viewModel.waist,
                        'cm',
                        Icons.accessibility,
                        () {
                          _showMeasurementDialog(
                            context,
                            'Waist',
                            viewModel.waist,
                            (value) => viewModel.setWaist(value),
                          );
                        },
                      ),
                      _buildMeasurementCard(
                        'Shoulder',
                        viewModel.shoulder,
                        'cm',
                        Icons.accessibility,
                        () {
                          _showMeasurementDialog(
                            context,
                            'Shoulder',
                            viewModel.shoulder,
                            (value) => viewModel.setShoulder(value),
                          );
                        },
                      ),
                      _buildMeasurementCard(
                        'Arms',
                        viewModel.arms,
                        'cm',
                        Icons.accessibility,
                        () {
                          _showMeasurementDialog(
                            context,
                            'Arms',
                            viewModel.arms,
                            (value) => viewModel.setArms(value),
                          );
                        },
                      ),
                      _buildMeasurementCard(
                        'Length',
                        viewModel.length,
                        'cm',
                        Icons.accessibility,
                        () {
                          _showMeasurementDialog(
                            context,
                            'Length',
                            viewModel.length,
                            (value) => viewModel.setLength(value),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Notes Section
                  Text(
                    'Additional Notes',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    maxLines: 4,
                    controller: _notesController,
                    onChanged: (value) => viewModel.setNotes(value),
                    decoration: InputDecoration(
                      hintText: 'Add any special instructions...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                  SizedBox(height: 32),
                  CustomButton(
                    text: 'Update Measurements',
                    isLoading: viewModel.isBusy,
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final success = await viewModel.updateMeasurements(
                        'user1',
                        'Current Tailor',
                      );
                      if (success && mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Measurements updated successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(height: MediaQuery.paddingOf(context).bottom + 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMeasurementCard(
    String label,
    double value,
    String unit,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.deepPurple, size: 32),
            SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.deepPurple,
              ),
            ),
            Text(unit, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  void _showMeasurementDialog(
    BuildContext context,
    String label,
    double currentValue,
    Function(double) onSave,
  ) {
    final controller = TextEditingController(text: currentValue.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update $label'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Enter measurement in cm',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(controller.text) ?? 0;
                onSave(value);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
