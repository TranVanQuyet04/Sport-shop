import '../../model/common/backend_models.dart';
import '../../service/customer/payment_service.dart';
import 'payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  const PaymentRepositoryImpl(this._paymentService);

  final PaymentService _paymentService;

  @override
  Future<PaymentResponseModel> createVnPayPayment(String orderId) {
    return _paymentService.createVnPayPayment(orderId);
  }
}
