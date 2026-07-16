package org.example.controller;

import org.example.dto.request.SendMessageRequest;
import org.example.model.ChatMessage;
import org.example.service.ChatMessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
public class ChatMessageController {

    private final ChatMessageService chatMessageService;

    @GetMapping("/rooms/{roomId}/messages")
    public List<ChatMessage> getMessages(@PathVariable Long roomId) {
        return chatMessageService.getMessages(roomId);
    }

    @PostMapping("/rooms/{roomId}/messages")
    public List<ChatMessage> sendMessage(
            @PathVariable Long roomId,
            @RequestBody SendMessageRequest request
    ) {
        return chatMessageService.sendMessage(roomId, request);
    }

    @DeleteMapping("/rooms/{roomId}/messages")
    @ResponseStatus(org.springframework.http.HttpStatus.NO_CONTENT)
    public void clearMessages(@PathVariable Long roomId) {
        chatMessageService.clearMessages(roomId);
    }
}
