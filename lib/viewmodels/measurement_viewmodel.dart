import 'base_viewmodel.dart';
import '../models/measurement_model.dart';
import '../models/tailor_order_model.dart';

class MeasurementViewModel extends BaseViewModel {
  Measurement? _measurement;
  String _errorMessage = '';

  Measurement? get measurement => _measurement;
  String get errorMessage => _errorMessage;

  // Controllers for generic form fields
  double chest = 0;
  double waist = 0;
  double shoulder = 0;
  double arms = 0;
  double length = 0;
  String notes = '';
  String updatedBy = 'Customer';

  final Map<String, String> sizeSelections = {};
  final Map<String, Map<String, MeasurementEntry>> componentMeasurements = {};
  final Map<String, Map<String, String>> stylingSelections = {};
  final Map<String, Map<String, String>> stylingNotes = {};

  Future<void> fetchMeasurements(String userId) async {
    setBusy(true);
    try {
      // Simulating API call
      await Future.delayed(Duration(seconds: 1));

      _measurement = Measurement(
        id: '1',
        userId: userId,
        chest: 40,
        waist: 34,
        shoulder: 18,
        arms: 24,
        length: 42,
        notes: 'Standard measurements',
        updatedBy: 'Tailor John',
        updatedAt: DateTime.now().subtract(Duration(days: 2)),
      );

      chest = _measurement!.chest;
      waist = _measurement!.waist;
      shoulder = _measurement!.shoulder;
      arms = _measurement!.arms;
      length = _measurement!.length;
      notes = _measurement!.notes;
      updatedBy = _measurement!.updatedBy.toLowerCase().contains('tailor')
          ? 'Tailor'
          : 'Customer';

      for (final product in TailorCatalog.productSpecs) {
        if (product.sizeOptions.isNotEmpty) {
          sizeSelections[product.key] = product.sizeOptions.first;
        }

        componentMeasurements[product.key] = {
          for (final field in product.measurementFields)
            TailorCatalog.measurementKey(product.key, field.label): const MeasurementEntry(),
        };

        stylingSelections[product.key] = {
          for (final section in product.stylingSections)
            TailorCatalog.styleKey(product.key, section.title): '',
        };

        stylingNotes[product.key] = {};
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  Future<bool> updateMeasurements(String userId, String updatedByName) async {
    setBusy(true);
    try {
      // Simulating API call
      await Future.delayed(Duration(seconds: 1));

      _measurement = Measurement(
        id: _measurement?.id ?? '1',
        userId: userId,
        chest: chest,
        waist: waist,
        shoulder: shoulder,
        arms: arms,
        length: length,
        notes: notes,
        updatedBy: updatedByName,
        updatedAt: DateTime.now(),
      );

      _errorMessage = '';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      setBusy(false);
    }
  }

  String selectedSizeFor(String productKey) => sizeSelections[productKey] ?? '';

  void setSizeFor(String productKey, String value) {
    sizeSelections[productKey] = value;
    notifyListeners();
  }

  MeasurementEntry measurementEntry(String productKey, String fieldLabel) {
    return componentMeasurements[productKey]?[TailorCatalog.measurementKey(productKey, fieldLabel)] ?? const MeasurementEntry();
  }

  void updateComponentMeasurement({
    required String productKey,
    required String fieldLabel,
    String? body,
    String? finished,
    String? remarks,
  }) {
    final entries = Map<String, MeasurementEntry>.from(componentMeasurements[productKey] ?? {});
    final key = TailorCatalog.measurementKey(productKey, fieldLabel);
    final current = entries[key] ?? const MeasurementEntry();
    entries[key] = current.copyWith(body: body, finished: finished, remarks: remarks);
    componentMeasurements[productKey] = entries;
    notifyListeners();
  }

  String stylingSelection(String productKey, String sectionTitle) {
    return stylingSelections[productKey]?[TailorCatalog.styleKey(productKey, sectionTitle)] ?? '';
  }

  void updateStylingSelection({
    required String productKey,
    required String sectionTitle,
    required String value,
  }) {
    final selections = Map<String, String>.from(stylingSelections[productKey] ?? {});
    selections[TailorCatalog.styleKey(productKey, sectionTitle)] = value;
    stylingSelections[productKey] = selections;
    notifyListeners();
  }

  String stylingNote(String productKey, String sectionTitle) {
    return stylingNotes[productKey]?[TailorCatalog.styleKey(productKey, sectionTitle)] ?? '';
  }

  void updateStylingNote({
    required String productKey,
    required String sectionTitle,
    required String value,
  }) {
    final notesMap = Map<String, String>.from(stylingNotes[productKey] ?? {});
    notesMap[TailorCatalog.styleKey(productKey, sectionTitle)] = value;
    stylingNotes[productKey] = notesMap;
    notifyListeners();
  }

  void setChest(double value) {
    chest = value;
    notifyListeners();
  }

  void setWaist(double value) {
    waist = value;
    notifyListeners();
  }

  void setShoulder(double value) {
    shoulder = value;
    notifyListeners();
  }

  void setArms(double value) {
    arms = value;
    notifyListeners();
  }

  void setLength(double value) {
    length = value;
    notifyListeners();
  }

  void setNotes(String value) {
    notes = value;
    notifyListeners();
  }

  void setUpdatedBy(String value) {
    updatedBy = value;
    notifyListeners();
  }
}
