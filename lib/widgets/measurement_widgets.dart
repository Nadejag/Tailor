import 'package:flutter/material.dart';
import 'package:tailor/models/tailor_order_model.dart';

class MeasurementInputRow extends StatefulWidget {
  final String label;
  final MeasurementEntry entry;
  final ValueChanged<String> onBodyChanged;
  final ValueChanged<String> onFinishedChanged;
  final ValueChanged<String> onRemarksChanged;

  const MeasurementInputRow({
    super.key,
    required this.label,
    required this.entry,
    required this.onBodyChanged,
    required this.onFinishedChanged,
    required this.onRemarksChanged,
  });

  @override
  State<MeasurementInputRow> createState() => _MeasurementInputRowState();
}

class _MeasurementInputRowState extends State<MeasurementInputRow> {
  late final TextEditingController _bodyController;
  late final TextEditingController _finishedController;
  late final TextEditingController _remarksController;

  @override
  void initState() {
    super.initState();
    _bodyController = TextEditingController(text: widget.entry.body);
    _finishedController = TextEditingController(text: widget.entry.finished);
    _remarksController = TextEditingController(text: widget.entry.remarks);
  }

  @override
  void didUpdateWidget(covariant MeasurementInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_bodyController, widget.entry.body);
    _sync(_finishedController, widget.entry.finished);
    _sync(_remarksController, widget.entry.remarks);
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text != value) controller.text = value;
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _finishedController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 430;
    final label = SizedBox(
      width: narrow ? double.infinity : 86,
      child: Text(
        widget.label,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );

    final fields = [
      Expanded(
        child: TextField(
          controller: _bodyController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Body'),
          onChanged: widget.onBodyChanged,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: TextField(
          controller: _finishedController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Finished'),
          onChanged: widget.onFinishedChanged,
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (narrow) ...[
            label,
            const SizedBox(height: 6),
            Row(children: fields),
          ] else
            Row(children: [label, const SizedBox(width: 8), ...fields]),
          const SizedBox(height: 8),
          TextField(
            controller: _remarksController,
            decoration: InputDecoration(labelText: '${widget.label} remarks'),
            onChanged: widget.onRemarksChanged,
          ),
        ],
      ),
    );
  }
}

class StylingSectionField extends StatefulWidget {
  final StylingSectionSpec section;
  final String? selectedValue;
  final String note;
  final ValueChanged<String> onSelected;
  final ValueChanged<String> onNoteChanged;

  const StylingSectionField({
    super.key,
    required this.section,
    required this.selectedValue,
    required this.note,
    required this.onSelected,
    required this.onNoteChanged,
  });

  @override
  State<StylingSectionField> createState() => _StylingSectionFieldState();
}

class _StylingSectionFieldState extends State<StylingSectionField> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.note);
  }

  @override
  void didUpdateWidget(covariant StylingSectionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_noteController.text != widget.note) _noteController.text = widget.note;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final needsNote = widget.section.options.any(
      (option) => option.label == widget.selectedValue && option.needsText,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${widget.section.title}${widget.section.required ? ' *' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
              if (widget.selectedValue != null && widget.selectedValue!.isNotEmpty)
                Icon(Icons.check_circle, color: Colors.green, size: 18),
            ],
          ),
          if (widget.section.helper.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.section.helper,
              style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.section.options.map((option) {
              final selected = widget.selectedValue == option.label;
              return ChoiceChip(
                label: Text(option.label),
                selected: selected,
                onSelected: (_) => widget.onSelected(option.label),
              );
            }).toList(),
          ),
          if (needsNote) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: widget.section.options
                    .firstWhere((option) => option.label == widget.selectedValue)
                    .textHint,
              ),
              onChanged: widget.onNoteChanged,
            ),
          ],
        ],
      ),
    );
  }
}
