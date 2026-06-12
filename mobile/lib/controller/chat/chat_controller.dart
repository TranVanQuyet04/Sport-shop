import 'package:flutter/foundation.dart';

import '../../model/chat/chat_model.dart';
import '../../repository/chat/chat_repository.dart';

class ChatController extends ChangeNotifier {
  ChatController({required this.chatRepository});

  final ChatRepository chatRepository;

  List<ChatMessageModel> messages = const [
    ChatMessageModel(
      id: 'welcome',
      content: 'Xin chào, Sportshop có thể hỗ trợ gì cho bạn?',
      sender: 'ADMIN',
      sentAt: null,
    ),
  ];
  List<ChatRoomModel> rooms = const [];
  bool isLoading = false;
  bool isSending = false;
  String? errorMessage;

  Future<void> sendBotMessage(String content) async {
    final text = content.trim();
    if (text.isEmpty) {
      return;
    }

    isSending = true;
    errorMessage = null;
    messages = [
      ...messages,
      ChatMessageModel.local(content: text, sender: 'CUSTOMER'),
    ];
    notifyListeners();

    try {
      final response = await chatRepository.sendBotMessage(
        message: text,
        history: messages.map((message) => message.content).toList(),
      );
      messages = [
        ...messages,
        ChatMessageModel.local(
          content: response.isEmpty
              ? 'Mình đã nhận được tin nhắn của bạn.'
              : response,
          sender: 'ADMIN',
        ),
      ];
    } catch (error) {
      errorMessage =
          'Đang phản hồi ở chế độ demo vì chưa kết nối được backend chat.';
      messages = [
        ...messages,
        ChatMessageModel.local(content: _demoReply(text), sender: 'ADMIN'),
      ];
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  String _demoReply(String content) {
    final lower = content.toLowerCase();
    if (lower.contains('đơn') || lower.contains('giao')) {
      return 'Mình đã nhận yêu cầu kiểm tra đơn hàng. Bạn có thể vào mục Đơn hàng để xem tracking, hoặc gửi mã đơn để hỗ trợ viên kiểm tra chi tiết.';
    }
    if (lower.contains('đổi') || lower.contains('size')) {
      return 'Sportshop hỗ trợ đổi size trong vòng 7 ngày nếu sản phẩm còn nguyên tem và chưa qua sử dụng.';
    }
    if (lower.contains('thanh toán') || lower.contains('cod')) {
      return 'Bạn có thể chọn COD, VNPay hoặc ví điện tử ở bước thanh toán. Với COD, bạn thanh toán trực tiếp khi nhận hàng.';
    }
    return 'Sportshop đã ghi nhận tin nhắn của bạn. Hỗ trợ viên sẽ phản hồi sớm nhất có thể.';
  }

  Future<void> loadAdminRooms() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      rooms = await chatRepository.getAdminRooms();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendRoomMessage({
    required String roomId,
    required String content,
    required String sender,
  }) async {
    final text = content.trim();
    if (text.isEmpty) {
      return;
    }

    isSending = true;
    errorMessage = null;
    messages = [
      ...messages,
      ChatMessageModel.local(content: text, sender: sender),
    ];
    notifyListeners();

    try {
      final responseMessages = await chatRepository.sendRoomMessage(
        roomId: roomId,
        content: text,
        sender: sender,
      );
      if (responseMessages.isNotEmpty) {
        messages = responseMessages;
      }
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isSending = false;
      notifyListeners();
    }
  }
}
