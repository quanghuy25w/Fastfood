import 'dart:async';

class PaymentService {
  PaymentService._();

  static final PaymentService instance = PaymentService._();

  /// Service xử lý thanh toán, mock hoặc tích hợp API thật.
  /// Trả về trạng thái thanh toán cho CheckoutScreen hoặc Provider.
  /// Tách biệt logic thanh toán ra service riêng.
  Future<bool> processPayment(double amount, String paymentMethod) async {
    try {
      if (amount <= 0) {
        return false;
      }

      if (paymentMethod.trim().isEmpty) {
        return false;
      }

      // Simulate network call.
      await Future<void>.delayed(const Duration(seconds: 2));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String> getTransactionId() async {
    // Mock transaction id (can be replaced by real gateway response).
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return 'TXN-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<bool> verifyPayment(String transactionId) async {
    // Simulate verify API call.
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (transactionId.trim().isEmpty) {
      return false;
    }

    return true;
  }
}
