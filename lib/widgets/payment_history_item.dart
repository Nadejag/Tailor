import 'package:flutter/material.dart';
import '../models/payment_model.dart';

class PaymentHistoryItem extends StatelessWidget {
  final PaymentHistory payment;

  const PaymentHistoryItem({required this.payment, super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final date =
        '${payment.createdAt.day}/${payment.createdAt.month}/${payment.createdAt.year}';
    final methodColor = _methodColor(context, payment.method);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: methodColor.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: methodColor.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: methodColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Icon(_methodIcon(payment.method), color: methodColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rs. ${payment.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: methodColor.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    payment.method,
                    style: TextStyle(
                      fontSize: 11,
                      color: methodColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 5),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _methodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.payments_outlined;
      case 'online':
        return Icons.wifi_tethering_outlined;
      case 'card':
        return Icons.credit_card;
      case 'check':
        return Icons.receipt_long_outlined;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  Color _methodColor(BuildContext context, String method) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (method.toLowerCase()) {
      case 'cash':
        return Colors.green;
      case 'online':
        return colorScheme.primary;
      case 'card':
        return colorScheme.secondary;
      case 'check':
        return colorScheme.tertiary;
      default:
        return colorScheme.primary;
    }
  }
}
