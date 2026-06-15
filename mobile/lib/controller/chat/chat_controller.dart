import 'package:flutter/foundation.dart';

import '../../model/chat/chat_model.dart';
import '../../repository/chat/chat_repository.dart';

class ChatController extends ChangeNotifier {
  ChatController({required this.chatRepository});

  final ChatRepository chatRepository;

  List<ChatMessageModel> messages = const [
    ChatMessageModel(
      id: 'welcome',
      content: 'Xin chao, Sportshop co the ho tro gi cho ban?',
      sender: 'ADMIN',
      sentAt: null,
    ),
  ];
  List<ChatRoomModel> rooms = const [];
  bool isLoading = false;
  bool isSending = false;
  String? errorMessage;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

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
    _safeNotifyListeners();

    try {
      final response = await chatRepository.sendBotMessage(
        message: text,
        history: messages.map((message) => message.content).toList(),
      );
      messages = [
        ...messages,
        ChatMessageModel.local(
          content: response.isEmpty ? 'Da nhan tin nhan cua ban.' : response,
          sender: 'ADMIN',
        ),
      ];
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isSending = false;
      _safeNotifyListeners();
    }
  }

  Future<void> loadAdminRooms() async {
    isLoading = true;
    errorMessage = null;
    _safeNotifyListeners();

    try {
      rooms = await chatRepository.getAdminRooms();
    } catch (error) {
      rooms = const [];
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      _safeNotifyListeners();
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
    _safeNotifyListeners();

    try {
      final responseMessages = await chatRepository.sendRoomMessage(
        roomId: roomId,
        content: text,
        sender: sender,
      );
      messages = responseMessages;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isSending = false;
      _safeNotifyListeners();
    }
  }
}
