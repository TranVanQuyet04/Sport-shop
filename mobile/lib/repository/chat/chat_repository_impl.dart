import '../../model/chat/chat_model.dart';
import '../../service/chat/chat_service.dart';
import 'chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl(this._chatService);

  final ChatService _chatService;

  @override
  Future<String> sendBotMessage({
    required String message,
    required List<String> history,
  }) {
    return _chatService.sendBotMessage(message: message, history: history);
  }

  @override
  Future<ChatRoomModel> createRoom(String customerName) {
    return _chatService.createRoom(customerName);
  }

  @override
  Future<List<ChatRoomModel>> getAdminRooms() {
    return _chatService.getAdminRooms();
  }

  @override
  Future<List<ChatRoomModel>> getMyRooms(String customerName) {
    return _chatService.getMyRooms(customerName);
  }

  @override
  Future<List<ChatMessageModel>> getRoomMessages(String roomId) {
    return _chatService.getRoomMessages(roomId);
  }

  @override
  Future<List<ChatMessageModel>> sendRoomMessage({
    required String roomId,
    required String content,
    required String sender,
    String? intent,
  }) {
    return _chatService.sendRoomMessage(
      roomId: roomId,
      content: content,
      sender: sender,
      intent: intent,
    );
  }

  @override
  Future<void> clearRoomMessages(String roomId) {
    return _chatService.clearRoomMessages(roomId);
  }
}
