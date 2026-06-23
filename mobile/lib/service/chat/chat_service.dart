import '../../core/network/api_client.dart';
import '../../model/chat/chat_model.dart';

abstract interface class ChatService {
  Future<String> sendBotMessage({
    required String message,
    required List<String> history,
  });

  Future<ChatRoomModel> createRoom(String customerName);

  Future<List<ChatRoomModel>> getAdminRooms();

  Future<List<ChatRoomModel>> getMyRooms(String customerName);

  Future<List<ChatMessageModel>> getRoomMessages(String roomId);

  Future<List<ChatMessageModel>> sendRoomMessage({
    required String roomId,
    required String content,
    required String sender,
  });
}

class ChatApiService implements ChatService {
  const ChatApiService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<String> sendBotMessage({
    required String message,
    required List<String> history,
  }) async {
    final json = await _apiClient.postJson(
      '/chat/send',
      data: {'message': message, 'history': history},
    );
    final source = json['result'] is Map
        ? Map<String, dynamic>.from(json['result'] as Map)
        : json;
    return (source['response'] ?? source['message'] ?? '').toString();
  }

  @override
  Future<ChatRoomModel> createRoom(String customerName) async {
    final json = await _apiClient.postJson(
      '/chat/rooms',
      data: {'customerName': customerName},
    );
    return ChatRoomModel.fromJson(json);
  }

  @override
  Future<List<ChatRoomModel>> getAdminRooms() async {
    final json = await _apiClient.getJson('/chat/rooms/admin/me');
    return _parseRooms(json);
  }

  @override
  Future<List<ChatRoomModel>> getMyRooms(String customerName) async {
    final json = await _apiClient.getJson(
      '/chat/rooms/me',
      queryParameters: {'customerName': customerName},
    );
    return _parseRooms(json);
  }

  @override
  Future<List<ChatMessageModel>> getRoomMessages(String roomId) async {
    final json = await _apiClient.getJson('/chat/rooms/$roomId/messages');
    return _parseMessages(json);
  }

  @override
  Future<List<ChatMessageModel>> sendRoomMessage({
    required String roomId,
    required String content,
    required String sender,
  }) async {
    final json = await _apiClient.postJson(
      '/chat/rooms/$roomId/messages',
      data: {'content': content, 'sender': sender},
    );
    final rawItems = json['result'] ?? json['data'] ?? json;
    if (rawItems is! List) {
      return const [];
    }
    return _parseMessages(json);
  }

  List<ChatRoomModel> _parseRooms(Map<String, dynamic> json) {
    final rawItems = json['result'] ?? json['data'] ?? json;
    if (rawItems is! List) {
      return const [];
    }
    return rawItems
        .whereType<Map>()
        .map((item) => ChatRoomModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  List<ChatMessageModel> _parseMessages(Map<String, dynamic> json) {
    final rawItems = json['result'] ?? json['data'] ?? json;
    if (rawItems is! List) {
      return const [];
    }
    return rawItems
        .whereType<Map>()
        .map(
          (item) => ChatMessageModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }
}
