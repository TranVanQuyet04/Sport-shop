package org.example.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.example.dto.AIClassificationResult;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class AIProductService {
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    @Value("${gemini.api.key}")
    private String apiKey;

    @Value("${gemini.api.url}")
    private String geminiUrl;

    public AIClassificationResult classifyProduct(String productName, String description) {
        // XÃ¢y dá»±ng System Prompt vá»›i quy táº¯c nghiÃªm ngáº·t
        String systemInstruction = """
            Báº¡n lÃ  chuyÃªn gia phÃ¢n loáº¡i sáº£n pháº©m thá»ƒ thao. HÃ£y phÃ¢n tÃ­ch TÃªn vÃ  MÃ´ táº£ Ä‘á»ƒ tráº£ vá» JSON.
            
            QUY Táº®C PHÃ‚N LOáº I:
            1. category: Chá»‰ chá»n má»™t trong [Ão, Quáº§n, GiÃ y, Phá»¥ kiá»‡n, Thiáº¿t bá»‹ táº­p luyá»‡n].
            2. sportType: Chá»‰ chá»n má»™t trong [Gym, Yoga, BÃ³ng Ä‘Ã¡, Cháº¡y bá»™, Cáº§u lÃ´ng, Tennis, Basketball].
            3. targetGender: Chá»‰ chá»n má»™t trong [Nam, Ná»¯, Unisex].
            4. material: TrÃ­ch xuáº¥t cháº¥t liá»‡u váº£i chÃ­nh (vÃ­ dá»¥: Dri-FIT, Cotton...).
            5. tags: TrÃ­ch xuáº¥t 3-5 Ä‘áº·c Ä‘iá»ƒm ná»•i báº­t nháº¥t (vÃ­ dá»¥: ThoÃ¡ng khÃ­, Tháº¥m hÃºt má»“ hÃ´i...).

            YÃŠU Cáº¦U: Chá»‰ tráº£ vá» duy nháº¥t chuá»—i JSON. KhÃ´ng giáº£i thÃ­ch thÃªm.
            """;

        String userPrompt = String.format("Sáº£n pháº©m: %s\nMÃ´ táº£: %s", productName, description);
        String fullPrompt = systemInstruction + "\n" + userPrompt;

        try {
            String rawResponse = callGeminiApi(systemInstruction + "\n" + userPrompt);

            String cleanJson = rawResponse;
            int firstBrace = rawResponse.indexOf("{");
            int lastBrace = rawResponse.lastIndexOf("}");
            if (firstBrace >= 0 && lastBrace > firstBrace) {
                cleanJson = rawResponse.substring(firstBrace, lastBrace + 1);
            }

            AIClassificationResult result = objectMapper.readValue(cleanJson, AIClassificationResult.class);
            result.setStatus("SUCCESS");
            return result;

        } catch (Exception e) {
            log.error("Lá»—i phÃ¢n loáº¡i AI: {}", e.getMessage());
            return AIClassificationResult.builder()
                    .status("FAILURE")
                    .tags(List.of())
                    .build();
        }
    }
    private String callGeminiApi(String prompt) {
        Map<String, Object> requestBody = Map.of(
                "contents", List.of(Map.of("parts", List.of(Map.of("text", prompt))))
        );

        String url = UriComponentsBuilder.fromHttpUrl(geminiUrl)
                .queryParam("key", apiKey)
                .toUriString();

        try {
            Map<?, ?> response = restTemplate.postForObject(url, requestBody, Map.class);

            return extractTextFromResponse(response);

        } catch (Exception e) {
            throw new RuntimeException("AI Classification Service failed: " + e.getMessage());
        }
    }

    @SuppressWarnings("unchecked")
    private String extractTextFromResponse(Map<?, ?> response) {
        if (response != null && response.get("candidates") instanceof List<?> candidates) {
            if (!candidates.isEmpty()) {
                Map<String, Object> firstCandidate = (Map<String, Object>) candidates.get(0);
                Map<String, Object> content = (Map<String, Object>) firstCandidate.get("content");
                List<Map<String, Object>> parts = (List<Map<String, Object>>) content.get("parts");
                return parts.get(0).get("text").toString();
            }
        }
        throw new RuntimeException("Dá»¯ liá»‡u pháº£n há»“i tá»« AI khÃ´ng Ä‘Ãºng Ä‘á»‹nh dáº¡ng");
    }

}
