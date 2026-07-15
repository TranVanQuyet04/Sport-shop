package org.example.controller;

import org.example.dto.request.ChatRequest;
import org.example.dto.response.ChatResponse;
import org.example.service.ChatBotService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
public class ChatController {
    private final ChatBotService chatBotService;

    @PostMapping("/send")
    public ResponseEntity<ChatResponse> chat(@RequestBody ChatRequest request) {
        // 1. Láº¥y lá»‹ch sá»­ tá»« Request do Frontend gá»­i lÃªn
        List<String> history = request.getHistory();
        if (history == null) {
            history = new ArrayList<>();
        }

        // 2. Gá»i Service vá»›i lá»‹ch sá»­ hiá»‡n táº¡i
        ChatResponse response = chatBotService.generateResponse(request.getMessage(), history);

        // ChÃº Ã½: Backend chá»‰ xá»­ lÃ½ vÃ  tráº£ vá» cÃ¢u tráº£ lá»i.
        // Frontend sáº½ tá»± cÃ³ trÃ¡ch nhiá»‡m ná»‘i (push) cÃ¢u há»i vÃ  cÃ¢u tráº£ lá»i má»›i vÃ o máº£ng history á»Ÿ dÆ°á»›i local.
        return ResponseEntity.ok(response);
    }
}
