import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../model/common/backend_models.dart';

abstract interface class PaymentService {
  Future<PaymentResponseModel> createVnPayPayment(String orderId);
}

class PaymentApiService implements PaymentService {
  const PaymentApiService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PaymentResponseModel> createVnPayPayment(String orderId) async {
    final cleanId = orderId.replaceAll('#', '').trim();
    final json = await _apiClient.getJson(
      '${ApiEndpoints.payment}/create_payment/$cleanId',
    );
    return PaymentResponseModel.fromJson(json);
  }
}
