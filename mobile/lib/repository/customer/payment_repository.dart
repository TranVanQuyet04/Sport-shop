import '../../model/common/backend_models.dart';

abstract interface class PaymentRepository {
  Future<PaymentResponseModel> createVnPayPayment(String orderId);
}
