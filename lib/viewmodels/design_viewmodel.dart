import 'base_viewmodel.dart';
import '../models/design_model.dart';

class DesignViewModel extends BaseViewModel {
  List<Design> _designs = [];
  List<Design> _filteredDesigns = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<Design> get designs => _filteredDesigns;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<String> get categories => ['All', 'Kurta', 'Suit', 'Waistcoat', 'Coat'];

  Future<void> fetchDesigns() async {
    setBusy(true);
    try {
      // Simulating API call
      await Future.delayed(Duration(seconds: 1));

      _designs = [
        Design(
          id: '1',
          tailorId: 'tailor1',
          name: 'Classic Kurta',
          imageUrl:
              'https://images.unsplash.com/photo-1603252109303-2751441dd157?auto=format&fit=crop&w=700&q=80',
          category: 'Kurta',
          price: 2500,
          description: 'Traditional classic kurta design with elegant patterns',
          status: 'selected',
        ),
        Design(
          id: '2',
          tailorId: 'tailor1',
          name: 'Modern Suit',
          imageUrl:
              'https://images.unsplash.com/photo-1593032465175-481ac7f401a0?auto=format&fit=crop&w=700&q=80',
          category: 'Suit',
          price: 5000,
          description: 'Contemporary suit design for formal occasions',
          status: 'selected',
        ),
        Design(
          id: '3',
          tailorId: 'tailor1',
          name: 'Formal Waistcoat',
          imageUrl:
              'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=700&q=80',
          category: 'Waistcoat',
          price: 1500,
          description: 'Stylish waistcoat for traditional wear',
          status: 'selected',
        ),
        Design(
          id: '4',
          tailorId: 'tailor1',
          name: 'Premium Coat',
          imageUrl:
              'https://images.unsplash.com/photo-1539533113208-f6df8cc8b543?auto=format&fit=crop&w=700&q=80',
          category: 'Coat',
          price: 8000,
          description: 'Premium winter coat with fine details',
          status: 'selected',
        ),
        Design(
          id: '5',
          tailorId: 'tailor1',
          name: 'Designer Kurta',
          imageUrl:
              'https://images.unsplash.com/photo-1583391733956-6c78276477e2?auto=format&fit=crop&w=700&q=80',
          category: 'Kurta',
          price: 3500,
          description: 'Designer kurta with exclusive embroidery',
          status: 'selected',
        ),
      ];
      _filteredDesigns = List.from(_designs);
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void searchDesigns(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void addDesign({
    required String name,
    required String imageUrl,
    required String category,
    required double price,
    required String description,
  }) {
    final design = Design(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tailorId: 'tailor1',
      name: name,
      imageUrl: imageUrl.isEmpty
          ? 'https://images.unsplash.com/photo-1603252109303-2751441dd157?auto=format&fit=crop&w=700&q=80'
          : imageUrl,
      category: category,
      price: price,
      description: description,
      status: 'selected',
    );

    _designs.insert(0, design);
    _applyFilters();
    notifyListeners();
  }

  void updateDesign(Design updatedDesign) {
    final index = _designs.indexWhere(
      (design) => design.id == updatedDesign.id,
    );
    if (index == -1) return;

    _designs[index] = updatedDesign;
    _applyFilters();
    notifyListeners();
  }

  void deleteDesign(String designId) {
    _designs.removeWhere((design) => design.id == designId);
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    final normalizedQuery = _searchQuery.trim().toLowerCase();

    _filteredDesigns = _designs.where((design) {
      final matchesCategory =
          _selectedCategory == 'All' || design.category == _selectedCategory;
      final matchesSearch =
          normalizedQuery.isEmpty ||
          design.name.toLowerCase().contains(normalizedQuery) ||
          design.category.toLowerCase().contains(normalizedQuery);

      return matchesCategory && matchesSearch;
    }).toList();
  }
}
