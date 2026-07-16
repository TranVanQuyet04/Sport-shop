package org.example.controller;

import org.example.model.ChatRoom;
import org.example.service.ChatRoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/chat/rooms")
@RequiredArgsConstructor
public class ChatRoomController {

    private final ChatRoomService chatRoomService;

    @PostMapping
    public ChatRoom createRoom(@RequestBody Map<String, String> body) {
        String name = body.get("customerName");
        if (name == null || name.isEmpty()) {
            throw new IllegalArgumentException("Customer name is required");
        }
        return chatRoomService.createRoom(name);
    }

    @GetMapping("/me")
    public List<ChatRoom> getMyRooms(@RequestParam(required = false) String customerName) {
        if (customerName == null) return new ArrayList<>(); // Tránh lỗi 500 nếu thiếu param
        return chatRoomService.getMyRooms(customerName);
    }

    @GetMapping("/admin/me")
    @PreAuthorize("hasRole('ADMIN')")
    public List<ChatRoom> getAdminRooms() {
        return chatRoomService.getAllRooms();
    }
}
