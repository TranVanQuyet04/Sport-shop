import 'package:flutter/foundation.dart';

import '../../model/chat/chat_model.dart';
import '../../repository/chat/chat_repository.dart';

class ChatPresenter extends ChangeNotifier {
  ChatPresenter({required this.chatRepository});

  final ChatRepository chatRepository;

  List<ChatMessageModel> messages = const [];
  List<ChatRoomModel> rooms = const [];
  Map<String, ChatMessageModel> latestMessagesByRoomId = const {};
  ChatRoomModel? activeRoom;
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
        history: messages
            .take(messages.length - 1)
            .map((message) => '${message.sender}: ${message.content}')
            .toList(),
      );
      messages = [
        ...messages,
        ChatMessageModel.local(
          content: response.isEmpty ? 'Đã nhận tin nhắn của bạn.' : response,
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

  void clearBotHistory() {
    messages = const [];
    errorMessage = null;
    _safeNotifyListeners();
  }

  Future<void> clearActiveRoomHistory() async {
    final roomId = activeRoom?.id;
    if (roomId == null || roomId.isEmpty || isSending || isLoading) {
      return;
    }
    isLoading = true;
    errorMessage = null;
    _safeNotifyListeners();
    try {
      await chatRepository.clearRoomMessages(roomId);
      messages = const [];
      latestMessagesByRoomId = {...latestMessagesByRoomId}..remove(roomId);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> loadAdminRooms({bool silent = false}) async {
    if (!silent) {
      isLoading = true;
    }
    errorMessage = null;
    _safeNotifyListeners();

    try {
      final loadedRooms = await chatRepository.getAdminRooms();
      rooms = loadedRooms;
      latestMessagesByRoomId = await _loadLatestMessages(loadedRooms);
    } catch (error) {
      if (!silent) {
        rooms = const [];
        latestMessagesByRoomId = const {};
      }
      errorMessage = error.toString();
    } finally {
      if (!silent) {
        isLoading = false;
      }
      _safeNotifyListeners();
    }
  }

  Future<void> openCustomerSupportRoom(String customerName) async {
    final name = customerName.trim().isEmpty
        ? 'Customer ${DateTime.now().millisecondsSinceEpoch}'
        : customerName.trim();

    isLoading = true;
    errorMessage = null;
    _safeNotifyListeners();

    try {
      final existingRooms = await chatRepository.getMyRooms(name);
      activeRoom = existingRooms.isNotEmpty
          ? existingRooms.reduce((latest, room) {
              final latestTime =
                  latest.lastMessageAt ??
                  DateTime.fromMillisecondsSinceEpoch(0);
              final roomTime =
                  room.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              return roomTime.isAfter(latestTime) ? room : latest;
            })
          : await chatRepository.createRoom(name);

      if (activeRoom?.id.isNotEmpty == true) {
        messages = await chatRepository.getRoomMessages(activeRoom!.id);
      } else {
        messages = const [];
      }
    } catch (error) {
      messages = const [];
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> loadRoomMessages(String roomId, {bool silent = false}) async {
    if (!silent) {
      isLoading = true;
    }
    errorMessage = null;
    _safeNotifyListeners();

    try {
      messages = await chatRepository.getRoomMessages(roomId);
      if (messages.isNotEmpty) {
        latestMessagesByRoomId = {
          ...latestMessagesByRoomId,
          roomId: messages.last,
        };
      }
    } catch (error) {
      if (!silent) {
        messages = const [];
      }
      errorMessage = error.toString();
    } finally {
      if (!silent) {
        isLoading = false;
      }
      _safeNotifyListeners();
    }
  }

  Future<void> sendRoomMessage({
    required String roomId,
    required String content,
    required String sender,
    String? intent,
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
        intent: intent,
      );
      messages = responseMessages;
      if (responseMessages.isNotEmpty) {
        latestMessagesByRoomId = {
          ...latestMessagesByRoomId,
          roomId: responseMessages.last,
        };
      }
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isSending = false;
      _safeNotifyListeners();
    }
  }

  Future<Map<String, ChatMessageModel>> _loadLatestMessages(
    List<ChatRoomModel> sourceRooms,
  ) async {
    final entries = await Future.wait(
      sourceRooms.take(40).where((room) => room.id.isNotEmpty).map((
        room,
      ) async {
        try {
          final roomMessages = await chatRepository.getRoomMessages(room.id);
          if (roomMessages.isEmpty) {
            return null;
          }
          return MapEntry(room.id, roomMessages.last);
        } catch (_) {
          return null;
        }
      }),
    );

    return Map.fromEntries(
      entries.whereType<MapEntry<String, ChatMessageModel>>(),
    );
  }
}
