import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/responsive.dart';
import '../../viewmodels/payment_viewmodel.dart';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payments')),
      body: Consumer<PaymentViewModel>(
        builder: (context, viewModel, child) {
          final progress =
              viewModel.payment == null || viewModel.payment!.totalAmount == 0
              ? 0.0
              : viewModel.payment!.paidAmount / viewModel.payment!.totalAmount;

          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ResponsiveCenter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment Summary Cards
                  if (viewModel.payment != null) ...[
                    _buildPaymentHero(context, viewModel, progress),
                    SizedBox(height: 18),
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
                                '${viewModel.totalOrders}',
                                Theme.of(context).colorScheme.primary,
                                Icons.inventory_2_outlined,
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildSummaryCard(
                                'Total Amount',
                                'Rs. ${viewModel.payment!.totalAmount.toStringAsFixed(2)}',
                                Theme.of(context).colorScheme.secondary,
                                Icons.shopping_bag_outlined,
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildSummaryCard(
                                'Paid',
                                'Rs. ${viewModel.payment!.paidAmount.toStringAsFixed(2)}',
                                Colors.green,
                                Icons.check_circle_outline,
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildSummaryCard(
                                'Remaining',
                                'Rs. ${viewModel.payment!.remainingAmount.toStringAsFixed(2)}',
                                Theme.of(context).colorScheme.tertiary,
                                Icons.pending_actions_outlined,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 24),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Progress',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: LinearProgressIndicator(
                              minHeight: 12,
                              value: progress.clamp(0, 1),
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.green,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            alignment: WrapAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(progress * 100).toStringAsFixed(1)}% Paid',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Remaining: Rs. ${viewModel.payment!.remainingAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Payment History',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: () =>
                            _showRecordPaymentDialog(context, viewModel),
                        icon: Icon(Icons.add, size: 18),
                        label: Text('Record'),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (viewModel.paymentHistory.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.history,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 12),
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
    BuildContext context,
    PaymentViewModel viewModel,
    double progress,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.secondary.withValues(alpha: 0.16),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Payment overview',
                    style: TextStyle(
                      color: colorScheme.onSecondary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(Icons.receipt_long, color: colorScheme.onSecondary),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Track total orders, paid amount, remaining balance, and every recorded payment.',
              style: TextStyle(
                color: colorScheme.onSecondary.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'Rs. ${viewModel.payment!.remainingAmount.toStringAsFixed(0)}',
              style: TextStyle(
                color: colorScheme.onSecondary,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'remaining balance',
              style: TextStyle(
                color: colorScheme.onSecondary.withValues(alpha: 0.76),
                fontWeight: FontWeight.w600,
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.22), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 6),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
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
  ) {
    final amountController = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    String selectedMethod = 'Cash';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Record Payment'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter amount',
                        prefixText: 'Rs. ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedMethod,
                      items: ['Cash', 'Online', 'Card', 'Check']
                          .map(
                            (method) => DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => selectedMethod = value ?? 'Cash');
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    if (amount > 0) {
                      final navigator = Navigator.of(dialogContext);
                      final success = await viewModel.recordPayment(
                        'user1',
                        amount,
                        selectedMethod,
                      );
                      if (success && mounted) {
                        navigator.pop();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Payment recorded successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Record'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
