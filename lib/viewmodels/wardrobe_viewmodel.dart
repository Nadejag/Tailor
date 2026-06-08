import 'base_viewmodel.dart';
import '../models/design_model.dart';
import '../models/wardrobe_model.dart';

class WardrobeViewModel extends BaseViewModel {
  List<Wardrobe> _wardrobeItems = [];
  List<Wardrobe> _filteredItems = [];
  String _selectedFilter = 'All';

  List<Wardrobe> get wardrobeItems => _filteredItems;
  int get totalItems => _wardrobeItems.length;
  String get selectedFilter => _selectedFilter;
  double get totalBaseAmount =>
      _wardrobeItems.fold(0, (sum, item) => sum + item.basePrice);
  double get totalFabricCredit =>
      _wardrobeItems.fold(0, (sum, item) => sum + item.fabricCredit);
  double get totalAdjustedAmount =>
      _wardrobeItems.fold(0, (sum, item) => sum + item.adjustedPrice);

  // 'stitching' replaced with 'processing'
  List<String> get filters => ['All', 'Selected', 'Processing', 'Completed'];

  int countByStatus(String status) {
    if (status == 'All') return _wardrobeItems.length;
    return _wardrobeItems
        .where((item) => item.status == status.toLowerCase())
        .length;
  }

  Future<void> fetchWardrobeItems() async {
    if (_wardrobeItems.isNotEmpty) return;
    setBusy(true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      _wardrobeItems = [
        Wardrobe(
          id: '1',
          userId: 'user1',
          designId: '1',
          status: 'selected',
          createdAt: DateTime.now(),
          design: Design(
            id: '1',
            tailorId: 'tailor1',
            name: 'Business Shirt',
            imageUrl:
                'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?auto=format&fit=crop&w=700&q=80',
            category: 'Shirt',
            price: 2500,
            description: 'Premium formal white dress shirt.',
            status: 'selected',
          ),
        ),
        Wardrobe(
          id: '2',
          userId: 'user1',
          designId: '2',
          status: 'processing',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          design: Design(
            id: '2',
            tailorId: 'tailor1',
            name: 'Modern Suit',
            imageUrl:
                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=700&q=80',
            category: 'Suit',
            price: 5000,
            description: 'Contemporary slim-fit two-piece suit.',
            status: 'processing',
          ),
        ),
        Wardrobe(
          id: '3',
          userId: 'user1',
          designId: '3',
          status: 'completed',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          design: Design(
            id: '3',
            tailorId: 'tailor1',
            name: 'Formal Waistcoat',
            imageUrl:
                'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=700&q=80',
            category: 'Waistcoat',
            price: 1800,
            description: 'V-neck five-button waistcoat.',
            status: 'completed',
          ),
        ),
      ];
      _applyFilter();
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  void filterByStatus(String status) {
    _selectedFilter = status;
    _applyFilter();
    notifyListeners();
  }

  Future<bool> addDesignToWardrobe(
    Design design, {
    List<FabricComponentChoice>? fabricChoices,
  }) async {
    if (_wardrobeItems.any((item) => item.designId == design.id)) return false;
    _wardrobeItems.insert(
      0,
      Wardrobe(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'user1',
        designId: design.id,
        status: 'selected',
        createdAt: DateTime.now(),
        design: design.copyWith(status: 'selected'),
        fabricChoices: fabricChoices ?? fabricChoicesForDesign(design),
      ),
    );
    _applyFilter();
    notifyListeners();
    return true;
  }

  bool isInWardrobe(String designId) =>
      _wardrobeItems.any((item) => item.designId == designId);

  Future<void> removeFromWardrobe(String wardrobeId) async {
    _wardrobeItems.removeWhere((item) => item.id == wardrobeId);
    _applyFilter();
    notifyListeners();
  }

  Future<void> updateStatus(String wardrobeId, String newStatus) async {
    final index = _wardrobeItems.indexWhere((item) => item.id == wardrobeId);
    if (index == -1) return;
    _wardrobeItems[index] = _wardrobeItems[index].copyWith(status: newStatus);
    _applyFilter();
    notifyListeners();
  }

  Future<void> updateFabricChoices(
    String wardrobeId,
    List<FabricComponentChoice> choices,
  ) async {
    final index = _wardrobeItems.indexWhere((item) => item.id == wardrobeId);
    if (index == -1) return;
    _wardrobeItems[index] = _wardrobeItems[index].copyWith(
      fabricChoices: choices,
    );
    _applyFilter();
    notifyListeners();
  }

  List<FabricComponentChoice> fabricChoicesForDesign(Design design) {
    final components = fabricComponentsForDesign(design);
    final creditShare = estimatedFabricCredit(design) / components.length;
    return components
        .map(
          (component) => FabricComponentChoice(
            componentName: component,
            fabricCredit: creditShare,
          ),
        )
        .toList();
  }

  List<String> fabricComponentsForDesign(Design design) {
    final source = '${design.name} ${design.category}'.toLowerCase();
    if (source.contains('three-piece') || source.contains('three piece')) {
      return ['Coat', 'Trouser', 'Waistcoat'];
    }
    if (source.contains('two-piece') ||
        source.contains('two piece') ||
        source.contains('suit')) {
      return ['Coat', 'Trouser'];
    }
    if (source.contains('shalwar kameez')) {
      return ['Kameez', 'Shalwar'];
    }
    if (source.contains('shirt')) return ['Shirt'];
    if (source.contains('trouser') || source.contains('pant')) {
      return ['Trouser'];
    }
    if (source.contains('coat') || source.contains('blazer')) return ['Coat'];
    if (source.contains('waistcoat')) return ['Waistcoat'];
    return [design.category];
  }

  double estimatedFabricCredit(Design design) {
    final source = '${design.name} ${design.category}'.toLowerCase();
    final rate = source.contains('tie') || source.contains('pocket square')
        ? 0.18
        : source.contains('suit') ||
              source.contains('coat') ||
              source.contains('blazer')
        ? 0.38
        : 0.32;
    return design.price * rate;
  }

  void _applyFilter() {
    if (_selectedFilter == 'All') {
      _filteredItems = List.from(_wardrobeItems);
      return;
    }
    _filteredItems = _wardrobeItems
        .where((item) => item.status == _selectedFilter.toLowerCase())
        .toList();
  }
}
