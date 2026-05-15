import 'base_viewmodel.dart';
import '../models/measurement_model.dart';

class MeasurementViewModel extends BaseViewModel {
  Measurement? _measurement;
  String _errorMessage = '';

  Measurement? get measurement => _measurement;
  String get errorMessage => _errorMessage;

  // Controllers for form fields
  double chest = 0;
  double waist = 0;
  double shoulder = 0;
  double arms = 0;
  double length = 0;
  String notes = '';

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

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  Future<bool> updateMeasurements(String userId, String tailorName) async {
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
        updatedBy: tailorName,
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
}