package com.team6.ecommercesystem.service;

import com.team6.ecommercesystem.model.ChatRoom;
import com.team6.ecommercesystem.model.enums.ChatRoomType;
import com.team6.ecommercesystem.repository.ChatRoomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ChatRoomService {

    private final ChatRoomRepository chatRoomRepository;

    public ChatRoom createRoom(String customerName) {
        ChatRoom room = ChatRoom.builder()
                .customerName(customerName)
                .adminName("Sportshop Support")
                .lastMessageAt(LocalDateTime.now())
                .hasUnread(false)
                .type(ChatRoomType.ADMIN_SUPPORT)
                .build();

        return chatRoomRepository.save(room);
    }

    public List<ChatRoom> getMyRooms(String customerName) {
        return chatRoomRepository.findByCustomerName(customerName);
    }

    public List<ChatRoom> getAllRooms() {
        return chatRoomRepository.findAll();
    }
}
