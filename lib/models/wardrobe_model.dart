import 'design_model.dart';

class FabricComponentChoice {
  final String componentName;
  final bool customerProvidesFabric;
  final double fabricCredit;

  const FabricComponentChoice({
    required this.componentName,
    this.customerProvidesFabric = false,
    this.fabricCredit = 0,
  });

  FabricComponentChoice copyWith({
    String? componentName,
    bool? customerProvidesFabric,
    double? fabricCredit,
  }) {
    return FabricComponentChoice(
      componentName: componentName ?? this.componentName,
      customerProvidesFabric:
          customerProvidesFabric ?? this.customerProvidesFabric,
      fabricCredit: fabricCredit ?? this.fabricCredit,
    );
  }

  factory FabricComponentChoice.fromJson(Map<String, dynamic> json) {
    return FabricComponentChoice(
      componentName: json['component_name'] ?? '',
      customerProvidesFabric: json['customer_provides_fabric'] ?? false,
      fabricCredit: (json['fabric_credit'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'component_name': componentName,
      'customer_provides_fabric': customerProvidesFabric,
      'fabric_credit': fabricCredit,
    };
  }
}

class Wardrobe {
  final String id;
  final String userId;
  final String designId;
  final String status; // 'selected', 'stitching', 'completed'
  final DateTime createdAt;
  final Design? design;
  final List<FabricComponentChoice> fabricChoices;

  Wardrobe({
    required this.id,
    required this.userId,
    required this.designId,
    required this.status,
    required this.createdAt,
    this.design,
    this.fabricChoices = const [],
  });

  double get basePrice => design?.price ?? 0;

  double get fabricCredit => fabricChoices.fold(
    0,
    (sum, choice) =>
        sum + (choice.customerProvidesFabric ? choice.fabricCredit : 0),
  );

  double get adjustedPrice {
    final adjusted = basePrice - fabricCredit;
    return adjusted < 0 ? 0 : adjusted;
  }

  List<FabricComponentChoice> get customerFabricChoices => fabricChoices
      .where((choice) => choice.customerProvidesFabric)
      .toList(growable: false);

  bool get hasCustomerFabric => customerFabricChoices.isNotEmpty;

  String get fabricSummary {
    if (!hasCustomerFabric) return 'Tailor fabric included';
    return 'Customer fabric: ${customerFabricChoices.map((e) => e.componentName).join(', ')}';
  }

  Wardrobe copyWith({
    String? id,
    String? userId,
    String? designId,
    String? status,
    DateTime? createdAt,
    Design? design,
    List<FabricComponentChoice>? fabricChoices,
  }) {
    return Wardrobe(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      designId: designId ?? this.designId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      design: design ?? this.design,
      fabricChoices: fabricChoices ?? this.fabricChoices,
    );
  }

  factory Wardrobe.fromJson(Map<String, dynamic> json) {
    return Wardrobe(
      id: json['id'],
      userId: json['user_id'],
      designId: json['design_id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      design: json['design'] != null ? Design.fromJson(json['design']) : null,
      fabricChoices: (json['fabric_choices'] as List<dynamic>? ?? [])
          .map(
            (choice) =>
                FabricComponentChoice.fromJson(choice as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'design_id': designId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'design': design?.toJson(),
      'fabric_choices': fabricChoices.map((choice) => choice.toJson()).toList(),
      'base_price': basePrice,
      'fabric_credit': fabricCredit,
      'adjusted_price': adjustedPrice,
    };
  }
}
