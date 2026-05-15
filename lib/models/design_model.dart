class Design {
  final String id;
  final String tailorId;
  final String name;
  final String imageUrl;
  final String category;
  final double price;
  final String description;
  final String status;

  Design({
    required this.id,
    required this.tailorId,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.price,
    required this.description,
    required this.status,
  });

  Design copyWith({
    String? id,
    String? tailorId,
    String? name,
    String? imageUrl,
    String? category,
    double? price,
    String? description,
    String? status,
  }) {
    return Design(
      id: id ?? this.id,
      tailorId: tailorId ?? this.tailorId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }

  factory Design.fromJson(Map<String, dynamic> json) {
    return Design(
      id: json['id'],
      tailorId: json['tailor_id'],
      name: json['name'],
      imageUrl: json['image_url'],
      category: json['category'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tailor_id': tailorId,
      'name': name,
      'image_url': imageUrl,
      'category': category,
      'price': price,
      'description': description,
      'status': status,
    };
  }
}
