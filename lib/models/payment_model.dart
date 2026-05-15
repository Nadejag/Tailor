class Payment {
  final String id;
  final String userId;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      userId: json['user_id'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      paidAmount: (json['paid_amount'] as num).toDouble(),
      remainingAmount: (json['remaining_amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class PaymentHistory {
  final String id;
  final String userId;
  final double amount;
  final String method; // 'cash', 'online', etc.
  final DateTime createdAt;

  PaymentHistory({
    required this.id,
    required this.userId,
    required this.amount,
    required this.method,
    required this.createdAt,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['id'],
      userId: json['user_id'],
      amount: (json['amount'] as num).toDouble(),
      method: json['method'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'method': method,
      'created_at': createdAt.toIso8601String(),
    };
  }
}