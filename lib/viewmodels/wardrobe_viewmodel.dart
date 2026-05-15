import 'base_viewmodel.dart';
import '../models/design_model.dart';
import '../models/wardrobe_model.dart';

class WardrobeViewModel extends BaseViewModel {
  List<Wardrobe> _wardrobeItems = [];
  List<Wardrobe> _filteredItems = [];
  String _selectedFilter = 'All';

  List<Wardrobe> get wardrobeItems => _filteredItems;
  String get selectedFilter => _selectedFilter;
  List<String> get filters => ['All', 'Selected', 'Stitching', 'Completed'];

  Future<void> fetchWardrobeItems() async {
    if (_wardrobeItems.isNotEmpty) return;

    setBusy(true);
    try {
      await Future.delayed(Duration(seconds: 1));

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
            name: 'Classic Kurta',
            imageUrl:
                'https://images.unsplash.com/photo-1603252109303-2751441dd157?auto=format&fit=crop&w=700&q=80',
            category: 'Kurta',
            price: 2500,
            description: 'Traditional classic kurta design',
            status: 'selected',
          ),
        ),
        Wardrobe(
          id: '2',
          userId: 'user1',
          designId: '2',
          status: 'stitching',
          createdAt: DateTime.now().subtract(Duration(days: 5)),
          design: Design(
            id: '2',
            tailorId: 'tailor1',
            name: 'Modern Suit',
            imageUrl:
                'https://images.unsplash.com/photo-1593032465175-481ac7f401a0?auto=format&fit=crop&w=700&q=80',
            category: 'Suit',
            price: 5000,
            description: 'Contemporary suit design',
            status: 'stitching',
          ),
        ),
        Wardrobe(
          id: '3',
          userId: 'user1',
          designId: '3',
          status: 'completed',
          createdAt: DateTime.now().subtract(Duration(days: 10)),
          design: Design(
            id: '3',
            tailorId: 'tailor1',
            name: 'Formal Waistcoat',
            imageUrl:
                'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=700&q=80',
            category: 'Waistcoat',
            price: 1500,
            description: 'Stylish waistcoat',
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

  Future<bool> addDesignToWardrobe(Design design) async {
    if (_wardrobeItems.any((item) => item.designId == design.id)) {
      return false;
    }

    _wardrobeItems.insert(
      0,
      Wardrobe(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'user1',
        designId: design.id,
        status: 'selected',
        createdAt: DateTime.now(),
        design: design.copyWith(status: 'selected'),
      ),
    );

    _applyFilter();
    notifyListeners();
    return true;
  }

  bool isInWardrobe(String designId) {
    return _wardrobeItems.any((item) => item.designId == designId);
  }

  Future<void> addToWardrobe(String designId) async {
    final design = Design(
      id: designId,
      tailorId: 'tailor1',
      name: 'Selected Design',
      imageUrl:
          'https://images.unsplash.com/photo-1603252109303-2751441dd157?auto=format&fit=crop&w=700&q=80',
      category: 'Custom',
      price: 0,
      description: 'Selected customer design',
      status: 'selected',
    );
    await addDesignToWardrobe(design);
  }

  Future<void> removeFromWardrobe(String wardrobeId) async {
    setBusy(true);
    try {
      await Future.delayed(Duration(seconds: 1));
      _wardrobeItems.removeWhere((item) => item.id == wardrobeId);
      _applyFilter();
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  Future<void> updateStatus(String wardrobeId, String newStatus) async {
    setBusy(true);
    try {
      await Future.delayed(Duration(seconds: 1));
      final index = _wardrobeItems.indexWhere((item) => item.id == wardrobeId);
      if (index != -1) {
        _wardrobeItems[index] = Wardrobe(
          id: _wardrobeItems[index].id,
          userId: _wardrobeItems[index].userId,
          designId: _wardrobeItems[index].designId,
          status: newStatus,
          createdAt: _wardrobeItems[index].createdAt,
          design: _wardrobeItems[index].design,
        );
      }
      _applyFilter();
      notifyListeners();
    } finally {
      setBusy(false);
    }
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
