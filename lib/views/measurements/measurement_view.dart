import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tailor_order_model.dart';
import '../../utils/responsive.dart';
import '../../widgets/measurement_widgets.dart';
import 'package:tailor/viewmodels/measurement_viewmodel.dart';

class MeasurementView extends StatefulWidget {
  const MeasurementView({super.key});

  @override
  State<MeasurementView> createState() => _MeasurementViewState();
}

class _MeasurementViewState extends State<MeasurementView> {
  String _selectedKey = TailorCatalog.shirtKey;
  bool _fetched = false;
  String? _activeMeasurementId;

  late final TextEditingController _chestController;
  late final TextEditingController _waistController;
  late final TextEditingController _shoulderController;
  late final TextEditingController _armsController;
  late final TextEditingController _lengthController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _chestController = TextEditingController();
    _waistController = TextEditingController();
    _shoulderController = TextEditingController();
    _armsController = TextEditingController();
    _lengthController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _chestController.dispose();
    _waistController.dispose();
    _shoulderController.dispose();
    _armsController.dispose();
    _lengthController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fetched) {
      _fetched = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<MeasurementViewModel>(context, listen: false).fetchMeasurements('1');
      });
    }
  }

  void _syncControllers(MeasurementViewModel vm) {
    final measurement = vm.measurement;
    if (measurement == null || measurement.id == _activeMeasurementId) return;
    _activeMeasurementId = measurement.id;
    _chestController.text = measurement.chest.toString();
    _waistController.text = measurement.waist.toString();
    _shoulderController.text = measurement.shoulder.toString();
    _armsController.text = measurement.arms.toString();
    _lengthController.text = measurement.length.toString();
    _notesController.text = measurement.notes;
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppSpacing.pagePadding(context);
    final displayProducts = [
      TailorCatalog.productByKey(TailorCatalog.shirtKey),
      TailorCatalog.productByKey(TailorCatalog.pantKey),
      TailorCatalog.productByKey(TailorCatalog.coatKey),
      TailorCatalog.productByKey(TailorCatalog.waistcoatKey),
      TailorCatalog.productByKey(TailorCatalog.shalwarKameezKey),
      TailorCatalog.productByKey(TailorCatalog.twoPieceSuitKey),
      TailorCatalog.productByKey(TailorCatalog.threePieceSuitKey),
      TailorCatalog.productByKey(TailorCatalog.tieKey),
      TailorCatalog.productByKey(TailorCatalog.pocketSquareKey),
    ];
    final selectedProduct = TailorCatalog.productByKey(_selectedKey);
    final components = TailorCatalog.componentsFor(_selectedKey);

    return Scaffold(
      appBar: AppBar(title: const Text('Measurement Templates')),
      body: ResponsiveCenter(
        padding: EdgeInsets.fromLTRB(
          padding,
          0,
          padding,
          MediaQuery.paddingOf(context).bottom + 20,
        ),
            child: Consumer<MeasurementViewModel>(
          builder: (context, vm, child) {
            _syncControllers(vm);
            if (vm.isBusy && vm.measurement == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              children: [
                _buildHero(context),
                const SizedBox(height: 16),
                _buildProductSelector(context, displayProducts),
                const SizedBox(height: 16),
                _buildProductSummary(context, selectedProduct, components),
                const SizedBox(height: 12),
                if (vm.errorMessage.isNotEmpty)
                  _buildErrorCard(context, vm.errorMessage),
                _buildEditor(context, vm),
                const SizedBox(height: 12),
                ...components.map(
                  (component) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildComponentTemplate(context, vm, component),
                  ),
                ),
                const SizedBox(height: 20),
                _buildBottomSaveButton(context, vm),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEditor(BuildContext context, MeasurementViewModel vm) {
    final colorScheme = Theme.of(context).colorScheme;
    final busy = vm.isBusy;
    final updatedAt = vm.measurement?.updatedAt;
    final updatedBy = vm.updatedBy.isNotEmpty ? vm.updatedBy : 'Customer';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(builder: (context, constraint) {
              final compact = constraint.maxWidth < 520;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit_outlined, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Edit Measurements', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: colorScheme.onSurface)),
                      ),
                      if (busy) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  compact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FilledButton(
                              onPressed: busy ? null : () async {
                                final messenger = ScaffoldMessenger.of(context);
                                final ok = await vm.updateMeasurements('1', vm.updatedBy);
                                if (!mounted) return;
                                messenger.showSnackBar(
                                  SnackBar(content: Text(ok ? 'Measurements saved' : 'Save failed')),
                                );
                              },
                              child: const Text('Save changes'),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: busy ? null : () => vm.fetchMeasurements('1'),
                              child: const Text('Refresh'),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            FilledButton(
                              onPressed: busy ? null : () async {
                                final messenger = ScaffoldMessenger.of(context);
                                final ok = await vm.updateMeasurements('1', vm.updatedBy);
                                if (!mounted) return;
                                messenger.showSnackBar(
                                  SnackBar(content: Text(ok ? 'Measurements saved' : 'Save failed')),
                                );
                              },
                              child: const Text('Save changes'),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: busy ? null : () => vm.fetchMeasurements('1'),
                                child: const Text('Refresh'),
                              ),
                            ),
                          ],
                        ),
                ],
              );
            }),
            if (updatedAt != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Last saved by $updatedBy', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                  const SizedBox(width: 16),
                  Text('Updated ${_formatDateTime(updatedAt)}', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ],
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, constraints) {
              final twoCol = constraints.maxWidth > 600;
              final fieldWidth = twoCol ? (constraints.maxWidth - 36) / 2 : constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _measurementField('Chest', _chestController, (value) => vm.setChest(double.tryParse(value) ?? vm.chest), width: fieldWidth),
                  _measurementField('Waist', _waistController, (value) => vm.setWaist(double.tryParse(value) ?? vm.waist), width: fieldWidth),
                  _measurementField('Shoulder', _shoulderController, (value) => vm.setShoulder(double.tryParse(value) ?? vm.shoulder), width: fieldWidth),
                  _measurementField('Arms', _armsController, (value) => vm.setArms(double.tryParse(value) ?? vm.arms), width: fieldWidth),
                  _measurementField('Length', _lengthController, (value) => vm.setLength(double.tryParse(value) ?? vm.length), width: fieldWidth),
                  SizedBox(
                    width: fieldWidth,
                    child: TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                      maxLines: 3,
                      onChanged: vm.setNotes,
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 12),
            _buildUpdatedByRow(vm),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.error),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:''${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _measurementField(String label, TextEditingController controller, ValueChanged<String> onChanged, {required double width}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.straighten),
              border: const OutlineInputBorder(),
            ),
            controller: controller,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSaveButton(BuildContext context, MeasurementViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilledButton.icon(
        onPressed: vm.isBusy
            ? null
            : () async {
                final messenger = ScaffoldMessenger.of(context);
                final ok = await vm.updateMeasurements('1', vm.updatedBy);
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text(ok ? 'All measurements saved successfully' : 'Save failed. Please try again.')),
                );
              },
        icon: const Icon(Icons.save_outlined),
        label: const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text('Save all measurement templates'),
        ),
      ),
    );
  }

  Widget _buildUpdatedByRow(MeasurementViewModel vm) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text('Updated by', style: TextStyle(fontWeight: FontWeight.w700)),
        ChoiceChip(
          label: const Text('Customer'),
          selected: vm.updatedBy.toLowerCase() == 'customer',
          onSelected: (_) => vm.setUpdatedBy('Customer'),
        ),
        ChoiceChip(
          label: const Text('Tailor'),
          selected: vm.updatedBy.toLowerCase() == 'tailor',
          onSelected: (_) => vm.setUpdatedBy('Tailor'),
        ),
      ],
    );
  }

  Widget _buildHero(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.straighten, color: colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Separate forms by product',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  'Each product has its own measurements and styling, so shirt, coat, pant, waistcoat and traditional departments receive only their required form.',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSelector(
    BuildContext context,
    List<TailorProductSpec> products,
  ) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final product = products[index];
          return ChoiceChip(
            label: Text(product.name),
            selected: _selectedKey == product.key,
            onSelected: (_) => setState(() => _selectedKey = product.key),
            labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          );
        },
      ),
    );
  }

  Widget _buildProductSummary(
    BuildContext context,
    TailorProductSpec product,
    List<TailorProductSpec> components,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(product.description, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: components.map((component) {
              return Chip(
                avatar: const Icon(Icons.print_outlined, size: 16),
                label: Text('${component.name} → ${component.department}'),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentTemplate(BuildContext context, MeasurementViewModel vm, TailorProductSpec component) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedSize = vm.selectedSizeFor(component.key);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(component.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      Text(component.department, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _templateSectionTitle('Size selection'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: component.sizeOptions.map((size) {
                final selected = selectedSize == size;
                return ChoiceChip(
                  label: Text(size),
                  selected: selected,
                  onSelected: (_) => vm.setSizeFor(component.key, size),
                );
              }).toList(),
            ),
            if (component.measurementFields.isNotEmpty) ...[
              const SizedBox(height: 16),
              _templateSectionTitle('Measurement rows'),
              const SizedBox(height: 8),
              ...component.measurementFields.map((field) {
                final entry = vm.measurementEntry(component.key, field.label);
                return MeasurementInputRow(
                  label: field.label,
                  entry: entry,
                  onBodyChanged: (value) => vm.updateComponentMeasurement(
                    productKey: component.key,
                    fieldLabel: field.label,
                    body: value,
                  ),
                  onFinishedChanged: (value) => vm.updateComponentMeasurement(
                    productKey: component.key,
                    fieldLabel: field.label,
                    finished: value,
                  ),
                  onRemarksChanged: (value) => vm.updateComponentMeasurement(
                    productKey: component.key,
                    fieldLabel: field.label,
                    remarks: value,
                  ),
                );
              }),
            ],
            if (component.stylingSections.isNotEmpty) ...[
              const SizedBox(height: 16),
              _templateSectionTitle('Styling mapped to this product'),
              const SizedBox(height: 8),
              ...component.stylingSections.map((section) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: StylingSectionField(
                    section: section,
                    selectedValue: vm.stylingSelection(component.key, section.title),
                    note: vm.stylingNote(component.key, section.title),
                    onSelected: (value) => vm.updateStylingSelection(
                      productKey: component.key,
                      sectionTitle: section.title,
                      value: value,
                    ),
                    onNoteChanged: (value) => vm.updateStylingNote(
                      productKey: component.key,
                      sectionTitle: section.title,
                      value: value,
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _templateSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
    );
  }
}
