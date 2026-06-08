import 'base_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tailor_order_model.dart';

class OrderViewModel extends BaseViewModel {
  static const _prefsKey = 'selected_wardrobe_package';

  WardrobePackageSpec _package = TailorCatalog.premiumPackage;
  WardrobePackageSpec get package => _package;
  final List<TailorOrderItem> _items = [];
  String _customerName = '';
  String _contactNumber = '';
  String _invoiceNumber = '1168';
  DateTime _orderDate = DateTime.now();
  DateTime? _tryDate;
  DateTime? _promiseDate;
  String _errorMessage = '';

  List<TailorOrderItem> get items => List.unmodifiable(_items);
  String get customerName => _customerName;
  String get contactNumber => _contactNumber;
  String get invoiceNumber => _invoiceNumber;
  DateTime get orderDate => _orderDate;
  DateTime? get tryDate => _tryDate;
  DateTime? get promiseDate => _promiseDate;
  String get errorMessage => _errorMessage;

  int get totalPackageQuantity =>
      package.allocations.fold(0, (sum, allocation) => sum + allocation.quantity);

  int get selectedQuantity => _items.length;

  int get completedItems =>
      _items.where((item) => TailorCatalog.isItemComplete(item)).length;

  bool get canForwardOrder =>
      _items.isNotEmpty && _items.every(TailorCatalog.isItemComplete);

  List<TailorProductSpec> get packageProducts => TailorCatalog.productsForPackage(_package);

  List<TailorProductSpec> productsForSelectedPackage() => TailorCatalog.productsForPackage(_package);

  OrderViewModel() {
    _loadSelectedPackage();
  }

  Future<void> _loadSelectedPackage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(_prefsKey) ?? TailorCatalog.premiumPackage.id;
      _package = TailorCatalog.wardrobePackagesMap()[id] ?? TailorCatalog.premiumPackage;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setPackageById(String id) async {
    _package = TailorCatalog.wardrobePackagesMap()[id] ?? TailorCatalog.premiumPackage;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, _package.id);
    } catch (_) {}
  }

  void setCustomerName(String value) {
    _customerName = value;
    notifyListeners();
  }

  void setContactNumber(String value) {
    _contactNumber = value;
    notifyListeners();
  }

  void setInvoiceNumber(String value) {
    _invoiceNumber = value;
    notifyListeners();
  }

  void setOrderDate(DateTime value) {
    _orderDate = value;
    notifyListeners();
  }

  void setTryDate(DateTime? value) {
    _tryDate = value;
    notifyListeners();
  }

  void setPromiseDate(DateTime? value) {
    _promiseDate = value;
    notifyListeners();
  }

  int allocationFor(String productKey) {
    return package.allocations
        .firstWhere((allocation) => allocation.productKey == productKey)
        .quantity;
  }

  int usedFor(String productKey) {
    return _items.where((item) => item.productKey == productKey).length;
  }

  int remainingFor(String productKey) {
    return allocationFor(productKey) - usedFor(productKey);
  }

  bool canAddProduct(String productKey) {
    return remainingFor(productKey) > 0;
  }

  bool addPackageProduct(String productKey) {
    if (!canAddProduct(productKey)) {
      _errorMessage = '${TailorCatalog.productByKey(productKey).name} quantity is finished.';
      notifyListeners();
      return false;
    }

    final product = TailorCatalog.productByKey(productKey);
    _items.insert(0, TailorOrderItem.empty(product));
    _errorMessage = '';
    notifyListeners();
    return true;
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void clearItems() {
    _items.clear();
    notifyListeners();
  }

  TailorOrderItem? itemById(String itemId) {
    try {
      return _items.firstWhere((item) => item.id == itemId);
    } catch (_) {
      return null;
    }
  }

  void updateSize(String itemId, String componentKey, String value) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1) return;

    final sizes = Map<String, String>.from(_items[index].sizes);
    sizes[componentKey] = value;
    _items[index] = _items[index].copyWith(sizes: sizes);
    notifyListeners();
  }

  void updateMeasurement({
    required String itemId,
    required String componentKey,
    required String fieldLabel,
    String? body,
    String? finished,
    String? remarks,
  }) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1) return;

    final key = TailorCatalog.measurementKey(componentKey, fieldLabel);
    final measurements = Map<String, MeasurementEntry>.from(
      _items[index].measurements,
    );
    final current = measurements[key] ?? const MeasurementEntry();
    measurements[key] = current.copyWith(
      body: body,
      finished: finished,
      remarks: remarks,
    );
    _items[index] = _items[index].copyWith(measurements: measurements);
    notifyListeners();
  }

  void updateStyling({
    required String itemId,
    required String componentKey,
    required String sectionTitle,
    required String value,
  }) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1) return;

    final key = TailorCatalog.styleKey(componentKey, sectionTitle);
    final stylingSelections = Map<String, String>.from(
      _items[index].stylingSelections,
    );
    stylingSelections[key] = value;
    _items[index] = _items[index].copyWith(
      stylingSelections: stylingSelections,
    );
    notifyListeners();
  }

  void updateStylingNote({
    required String itemId,
    required String componentKey,
    required String sectionTitle,
    required String value,
  }) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1) return;

    final key = TailorCatalog.styleKey(componentKey, sectionTitle);
    final stylingNotes = Map<String, String>.from(_items[index].stylingNotes);
    stylingNotes[key] = value;
    _items[index] = _items[index].copyWith(stylingNotes: stylingNotes);
    notifyListeners();
  }

  void updateItemNotes(String itemId, String value) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(notes: value);
    notifyListeners();
  }

  List<String> missingForItem(TailorOrderItem item) {
    return TailorCatalog.missingRequirements(item);
  }

  List<DepartmentPrintForm> printableForms() {
    final forms = <DepartmentPrintForm>[];
    for (final item in _items) {
      final parent = TailorCatalog.productByKey(item.productKey);
      for (final component in TailorCatalog.componentsFor(item.productKey)) {
        forms.add(DepartmentPrintForm(item: item, component: component, parent: parent));
      }
    }
    return forms;
  }

  Future<bool> forwardOrder() async {
    setBusy(true);
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!canForwardOrder) {
        _errorMessage = 'Complete every measurement and styling section before forwarding.';
        notifyListeners();
        return false;
      }
      _errorMessage = '';
      notifyListeners();
      return true;
    } finally {
      setBusy(false);
    }
  }
}
