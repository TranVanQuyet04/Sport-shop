package org.example.service;

import org.example.dto.response.ChatResponse;
import org.example.model.Product;
import org.example.model.ProductVariant;
import org.example.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.math.BigDecimal;
import java.text.Normalizer;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChatBotService {
    private static final Pattern DIACRITICS_PATTERN = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
    private static final Set<String> STOP_WORDS = Set.of(
            "toi", "muon", "mua", "tim", "kiem", "san", "pham", "con", "khong",
            "co", "bao", "nhieu", "cai", "chiec", "size", "mau", "ao", "quan", "giay",
            "cho", "minh", "ban", "shop", "hang", "ton", "kho", "gia", "la", "may"
    );

    private final ProductRepository productRepository;
    private final RestTemplate restTemplate;

    @Value("${gemini.api.key}")
    private String apiKey;

    @Value("${gemini.api.url}")
    private String geminiUrl;

    @Value("${app.frontend.url}")
    private String frontendUrl;

    public ChatResponse generateResponse(String userMessage, List<String> history) {
        try {
            List<Product> products = productRepository.findAllForChatBot();
            List<Product> relevantProducts = findRelevantProducts(userMessage, products);
            String productContext = buildProductContext(relevantProducts);
            String historyContext = String.join("\n", history == null ? List.of() : history);

            String fullPrompt = String.format("""
                    BÃ¡ÂºÂ¡n lÃƒÂ  StrideX Support, trÃ¡Â»Â£ lÃƒÂ½ tÃ†Â° vÃ¡ÂºÂ¥n bÃƒÂ¡n hÃƒÂ ng cho shop Ã„â€˜Ã¡Â»â€œ thÃ¡Â»Æ’ thao.

                    DÃ¡Â»Â® LIÃ¡Â»â€ U SÃ¡ÂºÂ¢N PHÃ¡ÂºÂ¨M LÃ¡ÂºÂ¤Y TRÃ¡Â»Â°C TIÃ¡ÂºÂ¾P TÃ¡Â»Âª BACKEND:
                    %s

                    LÃ¡Â»Å CH SÃ¡Â»Â¬ TRÃƒâ€™ CHUYÃ¡Â»â€ N:
                    %s

                    KHÃƒÂCH HÃƒâ‚¬NG HÃ¡Â»Å½I:
                    %s

                    QUY TÃ¡ÂºÂ®C BÃ¡ÂºÂ®T BUÃ¡Â»ËœC:
                    1. Khi khÃƒÂ¡ch hÃ¡Â»Âi cÃƒÂ²n hÃƒÂ ng, sÃ¡Â»â€˜ lÃ†Â°Ã¡Â»Â£ng, tÃ¡Â»â€œn kho, size, mÃƒÂ u, SKU: chÃ¡Â»â€° trÃ¡ÂºÂ£ lÃ¡Â»Âi dÃ¡Â»Â±a trÃƒÂªn sÃ¡Â»â€˜ liÃ¡Â»â€¡u tÃ¡Â»â€œn kho trong dÃ¡Â»Â¯ liÃ¡Â»â€¡u backend Ã¡Â»Å¸ trÃƒÂªn.
                    2. NÃ¡ÂºÂ¿u sÃ¡ÂºÂ£n phÃ¡ÂºÂ©m cÃƒÂ³ tÃ¡Â»â€œn kho > 0, nÃƒÂ³i rÃƒÂµ tÃ¡Â»â€¢ng sÃ¡Â»â€˜ lÃ†Â°Ã¡Â»Â£ng cÃƒÂ²n lÃ¡ÂºÂ¡i vÃƒÂ  liÃ¡Â»â€¡t kÃƒÂª size/mÃƒÂ u/SKU cÃƒÂ²n hÃƒÂ ng.
                    3. NÃ¡ÂºÂ¿u sÃ¡ÂºÂ£n phÃ¡ÂºÂ©m tÃ¡Â»â€œn kho = 0 hoÃ¡ÂºÂ·c khÃƒÂ´ng cÃƒÂ³ variant cÃƒÂ²n hÃƒÂ ng, nÃƒÂ³i rÃƒÂµ hiÃ¡Â»â€¡n hÃ¡ÂºÂ¿t hÃƒÂ ng vÃƒÂ  gÃ¡Â»Â£i ÃƒÂ½ sÃ¡ÂºÂ£n phÃ¡ÂºÂ©m khÃƒÂ¡c cÃƒÂ²n hÃƒÂ ng nÃ¡ÂºÂ¿u cÃƒÂ³.
                    4. NÃ¡ÂºÂ¿u khÃƒÂ´ng tÃƒÂ¬m thÃ¡ÂºÂ¥y sÃ¡ÂºÂ£n phÃ¡ÂºÂ©m khÃƒÂ¡ch hÃ¡Â»Âi, nÃƒÂ³i khÃƒÂ´ng tÃƒÂ¬m thÃ¡ÂºÂ¥y trong cÃ¡Â»Â­a hÃƒÂ ng vÃƒÂ  hÃ¡Â»Âi lÃ¡ÂºÂ¡i tÃƒÂªn sÃ¡ÂºÂ£n phÃ¡ÂºÂ©m hoÃ¡ÂºÂ·c nhu cÃ¡ÂºÂ§u.
                    6. KhÃƒÂ´ng tÃ¡Â»Â± bÃ¡Â»â€¹a sÃ¡Â»â€˜ lÃ†Â°Ã¡Â»Â£ng, size, mÃƒÂ u, giÃƒÂ¡ hoÃ¡ÂºÂ·c sÃ¡ÂºÂ£n phÃ¡ÂºÂ©m ngoÃƒÂ i dÃ¡Â»Â¯ liÃ¡Â»â€¡u backend.
                    7. TrÃ¡ÂºÂ£ lÃ¡Â»Âi ngÃ¡ÂºÂ¯n gÃ¡Â»Ân, thÃƒÂ¢n thiÃ¡Â»â€¡n, giÃ¡Â»â€˜ng nhÃƒÂ¢n viÃƒÂªn tÃ†Â° vÃ¡ÂºÂ¥n sport shop.
                    """, productContext, historyContext, userMessage);

            String aiResult = callGeminiApi(fullPrompt) + buildActionMarkers(relevantProducts);

            return ChatResponse.builder()
                    .response(aiResult)
                    .status("SUCCESS")
                    .build();
        } catch (Exception e) {
            log.error("ChatBot Error: {}", e.getMessage(), e);
            return ChatResponse.builder()
                    .response("RÃ¡ÂºÂ¥t tiÃ¡ÂºÂ¿c, hÃ¡Â»â€¡ thÃ¡Â»â€˜ng tÃ†Â° vÃ¡ÂºÂ¥n Ã„â€˜ang bÃ¡ÂºÂ­n xÃ¡Â»Â­ lÃƒÂ½. BÃ¡ÂºÂ¡n vui lÃƒÂ²ng thÃ¡Â»Â­ lÃ¡ÂºÂ¡i sau hoÃ¡ÂºÂ·c xem sÃ¡ÂºÂ£n phÃ¡ÂºÂ©m trÃ¡Â»Â±c tiÃ¡ÂºÂ¿p tÃ¡ÂºÂ¡i cÃ¡Â»Â­a hÃƒÂ ng nhÃƒÂ©!")
                    .status("ERROR")
                    .build();
        }
    }

    private List<Product> findRelevantProducts(String userMessage, List<Product> products) {
        String normalizedMessage = normalize(userMessage);
        List<String> keywords = List.of(normalizedMessage.split("\\s+")).stream()
                .map(String::trim)
                .filter(word -> word.length() >= 2)
                .filter(word -> !STOP_WORDS.contains(word))
                .toList();

        List<Product> matches = products.stream()
                .filter(product -> scoreProduct(product, normalizedMessage, keywords) > 0)
                .sorted(Comparator.comparingInt(
                        (Product product) -> scoreProduct(product, normalizedMessage, keywords)
                ).reversed())
                .limit(8)
                .toList();

        if (!matches.isEmpty()) {
            return matches;
        }

        return products.stream()
                .sorted(Comparator.comparingInt(this::totalStock).reversed())
                .limit(12)
                .toList();
    }

    private int scoreProduct(Product product, String normalizedMessage, List<String> keywords) {
        String searchable = normalize(String.join(" ",
                safe(product.getProductName()),
                safe(product.getDescription()),
                product.getBrand() == null ? "" : safe(product.getBrand().getBrandName()),
                product.getCategory() == null ? "" : safe(product.getCategory().getCategoryName()),
                product.getSport() == null ? "" : safe(product.getSport().getSportName())
        ));

        int score = 0;
        if (!normalizedMessage.isBlank() && searchable.contains(normalizedMessage)) {
            score += 8;
        }
        for (String keyword : keywords) {
            if (searchable.contains(keyword)) {
                score += 3;
            }
        }
        if (product.getVariants() != null) {
            for (ProductVariant variant : product.getVariants()) {
                String variantSearchable = normalize(String.join(" ",
                        safe(variant.getSku()),
                        safe(variant.getColor()),
                        safe(variant.getSize())
                ));
                for (String keyword : keywords) {
                    if (variantSearchable.contains(keyword)) {
                        score += 2;
                    }
                }
            }
        }
        return score;
    }

    private String buildProductContext(List<Product> products) {
        if (products.isEmpty()) {
            return "KhÃƒÂ´ng tÃƒÂ¬m thÃ¡ÂºÂ¥y sÃ¡ÂºÂ£n phÃ¡ÂºÂ©m nÃƒÂ o trong database.";
        }

        return products.stream()
                .map(this::formatProductForPrompt)
                .collect(Collectors.joining("\n---\n"));
    }

    private String formatProductForPrompt(Product product) {
        List<ProductVariant> variants = product.getVariants() == null
                ? List.of()
                : product.getVariants().stream()
                .sorted(Comparator.comparing(ProductVariant::getId))
                .toList();

        int totalStock = variants.stream()
                .mapToInt(variant -> stockOf(variant.getStockQuantity()))
                .sum();

        String priceRange = buildPriceRange(variants);
        String variantLines = variants.isEmpty()
                ? "- ChÃ†Â°a cÃƒÂ³ biÃ¡ÂºÂ¿n thÃ¡Â»Æ’/tÃ¡Â»â€œn kho"
                : variants.stream()
                .map(variant -> String.format(
                        "- SKU: %s | Size: %s | MÃƒÂ u: %s | GiÃƒÂ¡: %s VNÃ„Â | TÃ¡Â»â€œn kho: %d | TrÃ¡ÂºÂ¡ng thÃƒÂ¡i: %s",
                        fallback(variant.getSku(), "N/A"),
                        fallback(variant.getSize(), "N/A"),
                        fallback(variant.getColor(), "N/A"),
                        variant.getPrice() == null ? "Ã„Âang cÃ¡ÂºÂ­p nhÃ¡ÂºÂ­t" : variant.getPrice().toPlainString(),
                        stockOf(variant.getStockQuantity()),
                        stockOf(variant.getStockQuantity()) > 0 ? "CÃƒâ€™N HÃƒâ‚¬NG" : "HÃ¡ÂºÂ¾T HÃƒâ‚¬NG"
                ))
                .collect(Collectors.joining("\n"));

        String variantActionLines = variants.isEmpty()
                ? "- KhÃƒÂ´ng cÃƒÂ³ variant Ã„â€˜Ã¡Â»Æ’ thao tÃƒÂ¡c nhanh"
                : variants.stream()
                .map(variant -> String.format(
                        "- VariantId: %d | ProductId: %d | SKU: %s | Size: %s | MÃƒÂ u: %s | CÃƒÂ³ thÃ¡Â»Æ’ thÃƒÂªm giÃ¡Â»Â: %s",
                        variant.getId(),
                        product.getId(),
                        fallback(variant.getSku(), "N/A"),
                        fallback(variant.getSize(), "N/A"),
                        fallback(variant.getColor(), "N/A"),
                        stockOf(variant.getStockQuantity()) > 0 ? "YES" : "NO"
                ))
                .collect(Collectors.joining("\n"));

        return String.format("""
                TÃƒÂªn sÃ¡ÂºÂ£n phÃ¡ÂºÂ©m: %s
                MÃƒÂ´ tÃ¡ÂºÂ£: %s
                Brand: %s
                Danh mÃ¡Â»Â¥c: %s
                MÃƒÂ´n thÃ¡Â»Æ’ thao: %s
                GiÃƒÂ¡ tham khÃ¡ÂºÂ£o: %s
                TÃ¡Â»â€¢ng tÃ¡Â»â€œn kho: %d
                BiÃ¡ÂºÂ¿n thÃ¡Â»Æ’:
                %s
                Action metadata:
                %s
                """,
                product.getProductName(),
                fallback(product.getDescription(), "ChÃ†Â°a cÃƒÂ³ mÃƒÂ´ tÃ¡ÂºÂ£"),
                product.getBrand() == null ? "N/A" : fallback(product.getBrand().getBrandName(), "N/A"),
                product.getCategory() == null ? "N/A" : fallback(product.getCategory().getCategoryName(), "N/A"),
                product.getSport() == null ? "N/A" : fallback(product.getSport().getSportName(), "N/A"),
                priceRange,
                totalStock,
                variantLines,
                variantActionLines
        );
    }

    private String buildActionMarkers(List<Product> products) {
        return products.stream()
                .filter(product -> product.getId() != null)
                .limit(4)
                .map(product -> {
                    ProductVariant inStockVariant = product.getVariants() == null
                            ? null
                            : product.getVariants().stream()
                            .filter(variant -> stockOf(variant.getStockQuantity()) > 0)
                            .sorted(Comparator.comparing(ProductVariant::getId))
                            .findFirst()
                            .orElse(null);

                    String productName = fallback(product.getProductName(), "SÃ¡ÂºÂ£n phÃ¡ÂºÂ©m");
                    String marker = String.format(
                            "[[ACTION:VIEW_PRODUCT:productId=%d;label=%s]]",
                            product.getId(),
                            productName
                    );

                    if (inStockVariant == null) {
                        return marker;
                    }

                    String payload = String.format(
                            "productId=%d;variantId=%d;label=%s",
                            product.getId(),
                            inStockVariant.getId(),
                            productName
                    );
                    return marker
                            + "\n[[ACTION:ADD_TO_CART:" + payload + "]]"
                            + "\n[[ACTION:BUY_NOW:" + payload + "]]";
                })
                .collect(Collectors.joining("\n", "\n\n", ""));
    }

    private String buildPriceRange(List<ProductVariant> variants) {
        List<BigDecimal> prices = variants.stream()
                .map(ProductVariant::getPrice)
                .filter(price -> price != null)
                .sorted()
                .toList();
        if (prices.isEmpty()) {
            return "Ã„Âang cÃ¡ÂºÂ­p nhÃ¡ÂºÂ­t";
        }
        BigDecimal min = prices.get(0);
        BigDecimal max = prices.get(prices.size() - 1);
        if (min.compareTo(max) == 0) {
            return min.toPlainString() + " VNÃ„Â";
        }
        return min.toPlainString() + " - " + max.toPlainString() + " VNÃ„Â";
    }

    private int totalStock(Product product) {
        if (product.getVariants() == null) {
            return 0;
        }
        return product.getVariants().stream()
                .mapToInt(variant -> stockOf(variant.getStockQuantity()))
                .sum();
    }

    private int stockOf(Integer stock) {
        return stock == null ? 0 : Math.max(stock, 0);
    }

    private String normalize(String value) {
        if (value == null) {
            return "";
        }
        String normalized = Normalizer.normalize(value, Normalizer.Form.NFD);
        return DIACRITICS_PATTERN.matcher(normalized)
                .replaceAll("")
                .toLowerCase(Locale.ROOT)
                .replaceAll("[^a-z0-9\\s]", " ")
                .replaceAll("\\s+", " ")
                .trim();
    }

    private String safe(String value) {
        return value == null ? "" : value;
    }

    private String fallback(String value, String fallback) {
        return value == null || value.isBlank() ? fallback : value;
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
            throw new RuntimeException("AI Service communication failed: " + e.getMessage());
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
        return "TÃƒÂ´i chÃ†Â°a tÃƒÂ¬m thÃ¡ÂºÂ¥y thÃƒÂ´ng tin phÃƒÂ¹ hÃ¡Â»Â£p. BÃ¡ÂºÂ¡n vui lÃƒÂ²ng hÃ¡Â»Âi rÃƒÂµ hÃ†Â¡n tÃƒÂªn sÃ¡ÂºÂ£n phÃ¡ÂºÂ©m, size hoÃ¡ÂºÂ·c mÃƒÂ u cÃ¡ÂºÂ§n mua nhÃƒÂ©.";
    }
}
