package com.team6.ecommercesystem.service;

import com.team6.ecommercesystem.dto.response.ChatResponse;
import com.team6.ecommercesystem.model.Product;
import com.team6.ecommercesystem.model.ProductVariant;
import com.team6.ecommercesystem.repository.ProductRepository;
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
                    Báº¡n lÃ  StrideX Support, trá»£ lÃ½ tÆ° váº¥n bÃ¡n hÃ ng cho shop Ä‘á»“ thá»ƒ thao.

                    Dá»® LIá»†U Sáº¢N PHáº¨M Láº¤Y TRá»°C TIáº¾P Tá»ª BACKEND:
                    %s

                    Lá»ŠCH Sá»¬ TRÃ’ CHUYá»†N:
                    %s

                    KHÃCH HÃ€NG Há»ŽI:
                    %s

                    QUY Táº®C Báº®T BUá»˜C:
                    1. Khi khÃ¡ch há»i cÃ²n hÃ ng, sá»‘ lÆ°á»£ng, tá»“n kho, size, mÃ u, SKU: chá»‰ tráº£ lá»i dá»±a trÃªn sá»‘ liá»‡u tá»“n kho trong dá»¯ liá»‡u backend á»Ÿ trÃªn.
                    2. Náº¿u sáº£n pháº©m cÃ³ tá»“n kho > 0, nÃ³i rÃµ tá»•ng sá»‘ lÆ°á»£ng cÃ²n láº¡i vÃ  liá»‡t kÃª size/mÃ u/SKU cÃ²n hÃ ng.
                    3. Náº¿u sáº£n pháº©m tá»“n kho = 0 hoáº·c khÃ´ng cÃ³ variant cÃ²n hÃ ng, nÃ³i rÃµ hiá»‡n háº¿t hÃ ng vÃ  gá»£i Ã½ sáº£n pháº©m khÃ¡c cÃ²n hÃ ng náº¿u cÃ³.
                    4. Náº¿u khÃ´ng tÃ¬m tháº¥y sáº£n pháº©m khÃ¡ch há»i, nÃ³i khÃ´ng tÃ¬m tháº¥y trong cá»­a hÃ ng vÃ  há»i láº¡i tÃªn sáº£n pháº©m hoáº·c nhu cáº§u.
                    6. KhÃ´ng tá»± bá»‹a sá»‘ lÆ°á»£ng, size, mÃ u, giÃ¡ hoáº·c sáº£n pháº©m ngoÃ i dá»¯ liá»‡u backend.
                    7. Tráº£ lá»i ngáº¯n gá»n, thÃ¢n thiá»‡n, giá»‘ng nhÃ¢n viÃªn tÆ° váº¥n sport shop.
                    """, productContext, historyContext, userMessage);

            String aiResult = callGeminiApi(fullPrompt) + buildActionMarkers(relevantProducts);

            return ChatResponse.builder()
                    .response(aiResult)
                    .status("SUCCESS")
                    .build();
        } catch (Exception e) {
            log.error("ChatBot Error: {}", e.getMessage(), e);
            return ChatResponse.builder()
                    .response("Ráº¥t tiáº¿c, há»‡ thá»‘ng tÆ° váº¥n Ä‘ang báº­n xá»­ lÃ½. Báº¡n vui lÃ²ng thá»­ láº¡i sau hoáº·c xem sáº£n pháº©m trá»±c tiáº¿p táº¡i cá»­a hÃ ng nhÃ©!")
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
            return "KhÃ´ng tÃ¬m tháº¥y sáº£n pháº©m nÃ o trong database.";
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
                ? "- ChÆ°a cÃ³ biáº¿n thá»ƒ/tá»“n kho"
                : variants.stream()
                .map(variant -> String.format(
                        "- SKU: %s | Size: %s | MÃ u: %s | GiÃ¡: %s VNÄ | Tá»“n kho: %d | Tráº¡ng thÃ¡i: %s",
                        fallback(variant.getSku(), "N/A"),
                        fallback(variant.getSize(), "N/A"),
                        fallback(variant.getColor(), "N/A"),
                        variant.getPrice() == null ? "Äang cáº­p nháº­t" : variant.getPrice().toPlainString(),
                        stockOf(variant.getStockQuantity()),
                        stockOf(variant.getStockQuantity()) > 0 ? "CÃ’N HÃ€NG" : "Háº¾T HÃ€NG"
                ))
                .collect(Collectors.joining("\n"));

        String variantActionLines = variants.isEmpty()
                ? "- KhÃ´ng cÃ³ variant Ä‘á»ƒ thao tÃ¡c nhanh"
                : variants.stream()
                .map(variant -> String.format(
                        "- VariantId: %d | ProductId: %d | SKU: %s | Size: %s | MÃ u: %s | CÃ³ thá»ƒ thÃªm giá»: %s",
                        variant.getId(),
                        product.getId(),
                        fallback(variant.getSku(), "N/A"),
                        fallback(variant.getSize(), "N/A"),
                        fallback(variant.getColor(), "N/A"),
                        stockOf(variant.getStockQuantity()) > 0 ? "YES" : "NO"
                ))
                .collect(Collectors.joining("\n"));

        return String.format("""
                TÃªn sáº£n pháº©m: %s
                MÃ´ táº£: %s
                Brand: %s
                Danh má»¥c: %s
                MÃ´n thá»ƒ thao: %s
                GiÃ¡ tham kháº£o: %s
                Tá»•ng tá»“n kho: %d
                Biáº¿n thá»ƒ:
                %s
                Action metadata:
                %s
                """,
                product.getProductName(),
                fallback(product.getDescription(), "ChÆ°a cÃ³ mÃ´ táº£"),
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

                    String productName = fallback(product.getProductName(), "Sáº£n pháº©m");
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
            return "Äang cáº­p nháº­t";
        }
        BigDecimal min = prices.get(0);
        BigDecimal max = prices.get(prices.size() - 1);
        if (min.compareTo(max) == 0) {
            return min.toPlainString() + " VNÄ";
        }
        return min.toPlainString() + " - " + max.toPlainString() + " VNÄ";
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
        return "TÃ´i chÆ°a tÃ¬m tháº¥y thÃ´ng tin phÃ¹ há»£p. Báº¡n vui lÃ²ng há»i rÃµ hÆ¡n tÃªn sáº£n pháº©m, size hoáº·c mÃ u cáº§n mua nhÃ©.";
    }
}
