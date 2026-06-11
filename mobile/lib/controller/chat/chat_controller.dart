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
      errorMessage = error.toString();
    } finally {
      isSending = false;
      notifyListeners();
    }
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
