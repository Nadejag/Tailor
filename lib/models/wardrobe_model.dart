import 'design_model.dart';

class Wardrobe {
  final String id;
  final String userId;
  final String designId;
  final String status; // 'selected', 'stitching', 'completed'
  final DateTime createdAt;
  final Design? design;

  Wardrobe({
    required this.id,
    required this.userId,
    required this.designId,
    required this.status,
    required this.createdAt,
    this.design,
  });

  factory Wardrobe.fromJson(Map<String, dynamic> json) {
    return Wardrobe(
      id: json['id'],
      userId: json['user_id'],
      designId: json['design_id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      design: json['design'] != null ? Design.fromJson(json['design']) : null,
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
    };
  }
}