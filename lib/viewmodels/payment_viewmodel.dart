import 'base_viewmodel.dart';
import '../models/payment_model.dart';

class PaymentViewModel extends BaseViewModel {
  Payment? _payment;
  List<PaymentHistory> _paymentHistory = [];
  String _errorMessage = '';

  Payment? get payment => _payment;
  List<PaymentHistory> get paymentHistory => _paymentHistory;
  String get errorMessage => _errorMessage;
  int get totalOrders => 5;

  Future<void> fetchPaymentInfo(String userId) async {
    setBusy(true);
    try {
      // Simulating API call
      await Future.delayed(Duration(seconds: 1));

      _payment = Payment(
        id: '1',
        userId: userId,
        totalAmount: 12000,
        paidAmount: 8000,
        remainingAmount: 4000,
        createdAt: DateTime.now(),
      );

      _paymentHistory = [
        PaymentHistory(
          id: '1',
          userId: userId,
          amount: 2000,
          method: 'Cash',
          createdAt: DateTime.now().subtract(Duration(days: 10)),
        ),
        PaymentHistory(
          id: '2',
          userId: userId,
          amount: 3000,
          method: 'Online',
          createdAt: DateTime.now().subtract(Duration(days: 5)),
        ),
        PaymentHistory(
          id: '3',
          userId: userId,
          amount: 3000,
          method: 'Cash',
          createdAt: DateTime.now().subtract(Duration(days: 2)),
        ),
      ];

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  Future<bool> recordPayment(
    String userId,
    double amount,
    String method,
  ) async {
    setBusy(true);
    try {
      // Simulating API call
      await Future.delayed(Duration(seconds: 1));

      if (_payment != null) {
        final newPaidAmount = _payment!.paidAmount + amount;
        final newRemaining = _payment!.totalAmount - newPaidAmount;

        _payment = Payment(
          id: _payment!.id,
          userId: _payment!.userId,
          totalAmount: _payment!.totalAmount,
          paidAmount: newPaidAmount > _payment!.totalAmount
              ? _payment!.totalAmount
              : newPaidAmount,
          remainingAmount: newRemaining < 0 ? 0 : newRemaining,
          createdAt: _payment!.createdAt,
        );

        _paymentHistory.insert(
          0,
          PaymentHistory(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: userId,
            amount: amount,
            method: method,
            createdAt: DateTime.now(),
          ),
        );
      }

      _errorMessage = '';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      setBusy(false);
    }
  }
}
