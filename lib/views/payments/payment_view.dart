import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/responsive.dart';
import '../../viewmodels/payment_viewmodel.dart';
import '../../viewmodels/wardrobe_viewmodel.dart';
import '../../widgets/payment_history_item.dart';

class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PaymentViewModel>().fetchPaymentInfo('user1');
      context.read<WardrobeViewModel>().fetchWardrobeItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: Consumer2<PaymentViewModel, WardrobeViewModel>(
        builder: (context, viewModel, wardrobeViewModel, child) {
          final colorScheme = Theme.of(context).colorScheme;
          final wardrobeTotal = wardrobeViewModel.totalAdjustedAmount;
          final effectiveTotal = wardrobeTotal > 0
              ? wardrobeTotal
              : viewModel.payment?.totalAmount ?? 0;
          final effectivePaid = (viewModel.payment?.paidAmount ?? 0)
              .clamp(0, effectiveTotal)
              .toDouble();
          final effectiveRemaining = (effectiveTotal - effectivePaid)
              .clamp(0, double.infinity)
              .toDouble();
          final progress = effectiveTotal == 0
              ? 0.0
              : effectivePaid / effectiveTotal;

          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ResponsiveCenter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (viewModel.payment != null) ...[
                    _buildPaymentHero(
                      context,
                      progress: progress,
                      paid: effectivePaid,
                      total: effectiveTotal,
                      remaining: effectiveRemaining,
                      fabricCredit: wardrobeViewModel.totalFabricCredit,
                    ),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final gap = AppSpacing.cardGap(context);
                        final cardWidth = constraints.maxWidth < 390
                            ? constraints.maxWidth
                            : (constraints.maxWidth - gap) / 2;

                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: [
                            SizedBox(
                              width: cardWidth,
                              child: _buildSummaryCard(
                                'Total Orders',
                                '${wardrobeViewModel.totalItems == 0 ? viewModel.totalOrders : wardrobeViewModel.totalItems}',
                                colorScheme.primary,
                                Icons.inventory_2_outlined,
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildSummaryCard(
                                'Total Amount',
                                'Rs. ${effectiveTotal.toStringAsFixed(2)}',
                                colorScheme.secondary,
                                Icons.shopping_bag_outlined,
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildSummaryCard(
                                'Paid',
                                'Rs. ${effectivePaid.toStringAsFixed(2)}',
                                Colors.green,
                                Icons.check_circle_outline,
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildSummaryCard(
                                'Remaining',
                                'Rs. ${effectiveRemaining.toStringAsFixed(2)}',
                                colorScheme.tertiary,
                                Icons.pending_actions_outlined,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                  ],
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colorScheme.outlineVariant),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(
                            Icons.history_rounded,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Payment History',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${viewModel.paymentHistory.length} recorded transaction${viewModel.paymentHistory.length == 1 ? '' : 's'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: () => _showRecordPaymentDialog(
                            context,
                            viewModel,
                            effectiveTotal,
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Record'),
                          style: FilledButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (viewModel.paymentHistory.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.history,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No payment history',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...viewModel.paymentHistory.map(
                      (payment) => PaymentHistoryItem(payment: payment),
                    ),
                  SizedBox(height: MediaQuery.paddingOf(context).bottom + 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentHero(
    BuildContext context, {
    required double progress,
    required double paid,
    required double total,
    required double remaining,
    required double fabricCredit,
  }) {
    final paidPercent =
        '${(progress.clamp(0.0, 1.0) * 100).toStringAsFixed(0)}%';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      decoration: BoxDecoration(
        color: const Color(0xFF17324D),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17324D).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Payment overview',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD2B34C).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFFD2B34C).withValues(alpha: 0.32),
                    ),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: Color(0xFFD2B34C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Track total orders, paid amount, remaining balance, and every recorded payment.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    'Rs. ${remaining.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Text(
                    '$paidPercent paid',
                    style: const TextStyle(
                      color: Color(0xFFD2B34C),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'remaining balance',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.white.withValues(alpha: 0.14),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFD2B34C)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _heroAmountChip(
                  label: 'Paid',
                  value: 'Rs. ${paid.toStringAsFixed(0)}',
                  icon: Icons.check_circle_outline,
                ),
                const SizedBox(width: 10),
                _heroAmountChip(
                  label: 'Total',
                  value: 'Rs. ${total.toStringAsFixed(0)}',
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ],
            ),
            if (fabricCredit > 0) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD2B34C).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFFD2B34C).withValues(alpha: 0.20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      color: Color(0xFFD2B34C),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Customer fabric credit applied: Rs. ${fabricCredit.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _heroAmountChip({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.66),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.22), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showRecordPaymentDialog(
    BuildContext context,
    PaymentViewModel viewModel,
    double effectiveTotal,
  ) {
    final amountController = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    String selectedMethod = 'Cash';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final colorScheme = Theme.of(context).colorScheme;
            final methods = ['Cash', 'Online', 'Card', 'Check'];

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                MediaQuery.viewInsetsOf(context).bottom +
                    MediaQuery.paddingOf(context).bottom +
                    20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Record Payment',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add a new transaction to the customer account.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      hintText: 'Enter amount',
                      prefixText: 'Rs. ',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: methods.map((method) {
                      final selected = selectedMethod == method;
                      return ChoiceChip(
                        label: Text(method),
                        selected: selected,
                        avatar: Icon(
                          _methodIcon(method),
                          size: 17,
                          color: selected
                              ? colorScheme.onPrimary
                              : colorScheme.primary,
                        ),
                        selectedColor: colorScheme.primary,
                        labelStyle: TextStyle(
                          color: selected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                          side: BorderSide(
                            color: selected
                                ? Colors.transparent
                                : colorScheme.outlineVariant,
                          ),
                        ),
                        onSelected: (_) {
                          setState(() => selectedMethod = method);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            final amount =
                                double.tryParse(amountController.text) ?? 0;
                            if (amount <= 0) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Enter a valid amount'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final navigator = Navigator.of(sheetContext);
                            final success = await viewModel.recordPayment(
                              'user1',
                              amount,
                              selectedMethod,
                              totalOverride: effectiveTotal,
                            );
                            if (success && mounted) {
                              navigator.pop();
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Payment recorded successfully',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Record'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
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
}
