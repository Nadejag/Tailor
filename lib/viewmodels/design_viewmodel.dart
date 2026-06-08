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
  List<String> get categories => [
        'All',
        'Shirt',
        'Suit',
        'Coat',
        'Pant',
        'Trouser',
        'Waistcoat',
        'Shalwar Kameez',
        'Tie',
        'Pocket Square',
      ];

  Future<void> fetchDesigns() async {
    setBusy(true);
    try {
      // Simulating API call
      await Future.delayed(Duration(seconds: 1));

      _designs = [
        Design(
          id: '1',
          tailorId: 'tailor1',
          name: 'Business Shirt',
          imageUrl: 'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?auto=format&fit=crop&w=700&q=80',
          category: 'Shirt',
          price: 2500,
          description: 'Premium formal white dress shirt with spread collar, fly-front placket and French cuffs.',
          status: 'selected',
        ),
        Design(
          id: '2',
          tailorId: 'tailor1',
          name: 'Modern Suit',
          imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=700&q=80',
          category: 'Suit',
          price: 5000,
          description: 'Contemporary slim-fit two-piece suit tailored for formal and business occasions.',
          status: 'selected',
        ),
        Design(
          id: '3',
          tailorId: 'tailor1',
          name: 'Classic Three-Piece Suit',
          imageUrl: 'https://images.unsplash.com/photo-1617127365659-c47fa864d8bc?auto=format&fit=crop&w=700&q=80',
          category: 'Suit',
          price: 7500,
          description: 'Elegant three-piece suit — coat, waistcoat and trouser — for weddings and events.',
          status: 'selected',
        ),
        Design(
          id: '4',
          tailorId: 'tailor1',
          name: 'Formal Waistcoat',
          imageUrl: 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=700&q=80',
          category: 'Waistcoat',
          price: 1800,
          description: 'V-neck five-button single-breasted waistcoat for western and traditional ensembles.',
          status: 'selected',
        ),
        Design(
          id: '5',
          tailorId: 'tailor1',
          name: 'Premium Wool Coat',
          imageUrl: 'https://images.unsplash.com/photo-1539533113208-f6df8cc8b543?auto=format&fit=crop&w=700&q=80',
          category: 'Coat',
          price: 8500,
          description: 'Full-length premium wool overcoat with notch lapel and double-button front.',
          status: 'selected',
        ),
        Design(
          id: '6',
          tailorId: 'tailor1',
          name: 'Navy Blazer',
          imageUrl: 'https://images.unsplash.com/photo-1593032465175-481ac7f401a0?auto=format&fit=crop&w=700&q=80',
          category: 'Coat',
          price: 4500,
          description: 'Classic navy blazer with peak lapel — pairs perfectly with trousers or jeans.',
          status: 'selected',
        ),
        Design(
          id: '7',
          tailorId: 'tailor1',
          name: 'Shalwar Kameez Set',
          imageUrl: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&w=700&q=80',
          category: 'Shalwar Kameez',
          price: 3500,
          description: 'Traditional kameez and shalwar set — separate department forms for precise tailoring.',
          status: 'selected',
        ),
        Design(
          id: '8',
          tailorId: 'tailor1',
          name: 'Tailored Trouser',
          imageUrl: 'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?auto=format&fit=crop&w=700&q=80',
          category: 'Trouser',
          price: 2200,
          description: 'Slim-fit dress trouser with front pleats, cross pockets and heel guard finish.',
          status: 'selected',
        ),
        Design(
          id: '9',
          tailorId: 'tailor1',
          name: 'Oxford Dress Shirt',
          imageUrl: 'https://images.unsplash.com/photo-1603252109360-909baaf261c7?auto=format&fit=crop&w=700&q=80',
          category: 'Shirt',
          price: 2800,
          description: 'Light-blue Oxford shirt with button-down collar and two-button round cuffs.',
          status: 'selected',
        ),
        Design(
          id: '10',
          tailorId: 'tailor1',
          name: 'Silk Tie',
          imageUrl: 'https://images.unsplash.com/photo-1589756823695-278bc923f962?auto=format&fit=crop&w=700&q=80',
          category: 'Tie',
          price: 1200,
          description: 'Jacquard silk tie in classic stripe pattern — included in the strategic wardrobe package.',
          status: 'selected',
        ),
        Design(
          id: '11',
          tailorId: 'tailor1',
          name: 'Linen Pocket Square',
          imageUrl: 'https://images.unsplash.com/photo-1598032895397-b9472444bf93?auto=format&fit=crop&w=700&q=80',
          category: 'Pocket Square',
          price: 800,
          description: 'White linen pocket square with bordered edge — essential wardrobe accessory.',
          status: 'selected',
        ),
        Design(
          id: '12',
          tailorId: 'tailor1',
          name: 'Dress Pant',
          imageUrl: 'https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?auto=format&fit=crop&w=700&q=80',
          category: 'Pant',
          price: 2000,
          description: 'Flat-front dress pant with adjustable belt and standard finish.',
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
          ? 'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?auto=format&fit=crop&w=700&q=80'
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
