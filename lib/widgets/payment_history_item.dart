import 'package:flutter/material.dart';
import '../models/payment_model.dart';

class PaymentHistoryItem extends StatelessWidget {
  final PaymentHistory payment;

  const PaymentHistoryItem({required this.payment, super.key});

  @override
  Widget build(BuildContext context) {
    final date =
        '${payment.createdAt.day}/${payment.createdAt.month}/${payment.createdAt.year}';

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                payment.method.toLowerCase() == 'cash'
                    ? Icons.money
                    : Icons.credit_card,
                color: Colors.deepPurple,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rs. ${payment.amount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  payment.method,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Flexible(
            child: Text(
              date,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
