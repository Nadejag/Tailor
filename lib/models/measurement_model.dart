class Measurement {
  final String id;
  final String userId;
  final double chest;
  final double waist;
  final double shoulder;
  final double arms;
  final double length;
  final String notes;
  final String updatedBy;
  final DateTime updatedAt;

  Measurement({
    required this.id,
    required this.userId,
    required this.chest,
    required this.waist,
    required this.shoulder,
    required this.arms,
    required this.length,
    required this.notes,
    required this.updatedBy,
    required this.updatedAt,
  });

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      id: json['id'],
      userId: json['user_id'],
      chest: (json['chest'] as num).toDouble(),
      waist: (json['waist'] as num).toDouble(),
      shoulder: (json['shoulder'] as num).toDouble(),
      arms: (json['arms'] as num).toDouble(),
      length: (json['length'] as num).toDouble(),
      notes: json['notes'],
      updatedBy: json['updated_by'],
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'chest': chest,
      'waist': waist,
      'shoulder': shoulder,
      'arms': arms,
      'length': length,
      'notes': notes,
      'updated_by': updatedBy,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}