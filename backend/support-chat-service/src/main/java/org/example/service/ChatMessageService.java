package org.example.service;

import org.example.dto.request.SendMessageRequest;
import org.example.model.ChatMessage;
import org.example.model.ChatRoom;
import org.example.model.enums.ChatRoomType;
import org.example.repository.ChatMessageRepository;
import org.example.repository.ChatRoomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ChatMessageService {

    private final ChatMessageRepository chatMessageRepository;
    private final ChatRoomRepository chatRoomRepository;
    private final ChatBotService chatBotService;

    public List<ChatMessage> getMessages(Long roomId) {
        if (!chatRoomRepository.existsById(roomId)) {
            throw new RuntimeException("Room khÃ´ng tá»“n táº¡i");
        }
        return chatMessageRepository.findByRoomIdOrderBySentAtAsc(roomId);
    }

    public List<ChatMessage> sendMessage(Long roomId, SendMessageRequest request) {
        ChatRoom room = chatRoomRepository.findById(roomId)
                .orElseThrow(() -> new RuntimeException("Room khÃ´ng tá»“n táº¡i"));

        String sender = request.getSender() == null ? "" : request.getSender().trim().toUpperCase();
        ChatMessage message = ChatMessage.builder()
                .room(room)
                .content(request.getContent())
                .sender(sender)
                .sentAt(LocalDateTime.now())
                .type("TEXT")
                .build();

        chatMessageRepository.save(message);
        room.setLastMessageAt(message.getSentAt());
        room.setHasUnread("CUSTOMER".equals(sender));
        chatRoomRepository.save(room);

        if ("CUSTOMER".equals(sender)) {
            appendBotReply(room, request.getContent());
        }

        return chatMessageRepository.findByRoomIdOrderBySentAtAsc(roomId);
    }

    private void appendBotReply(ChatRoom room, String customerMessage) {
        List<String> history = chatMessageRepository
                .findByRoomIdOrderBySentAtAsc(room.getId())
                .stream()
                .map(ChatMessage::getContent)
                .toList();

        String aiReply = chatBotService
                .generateResponse(customerMessage, history)
                .getResponse();

        ChatMessage botMessage = ChatMessage.builder()
                .room(room)
                .content(aiReply)
                .sender("BOT")
                .sentAt(LocalDateTime.now())
                .type("TEXT")
                .build();

        chatMessageRepository.save(botMessage);
        room.setLastMessageAt(botMessage.getSentAt());
        if (room.getType() == ChatRoomType.AI_SUPPORT) {
            room.setHasUnread(false);
        } else {
            room.setHasUnread(true);
        }
        chatRoomRepository.save(room);
    }
}
