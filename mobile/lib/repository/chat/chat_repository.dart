import '../../model/chat/chat_model.dart';

abstract interface class ChatRepository {
  Future<String> sendBotMessage({
    required String message,
    required List<String> history,
  });

  Future<ChatRoomModel> createRoom(String customerName);

  Future<List<ChatRoomModel>> getAdminRooms();

  Future<List<ChatRoomModel>> getMyRooms(String customerName);

  Future<List<ChatMessageModel>> sendRoomMessage({
    required String roomId,
    required String content,
    required String sender,
  });
}
