package org.example.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.example.dto.response.ChatResponse;
import org.example.model.Product;
import org.example.model.ProductVariant;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestClientResponseException;

import java.math.BigDecimal;
import java.text.Normalizer;
import java.text.DecimalFormat;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChatBotService {
    private static final ObjectMapper JSON = new ObjectMapper();
    private static final int OPENROUTER_MAX_ATTEMPTS = 3;
    private static final int MIN_CONTEXT_SCORE = 6;
    private static final long OPENROUTER_INITIAL_BACKOFF_MS = 600L;
    private static final Pattern DIACRITICS_PATTERN = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
    private static final Pattern SIZE_PATTERN = Pattern.compile(
            "(?:size|co|sz|so)\\s*[:=-]?\\s*(free\\s*size|freesize|3xl|2xl|xxl|xl|xs|s|m|l|\\d{2,3})\\b"
    );
    private static final String PRICE_NUMBER_PATTERN = "[0-9]+(?:[.,][0-9]+)*";
    private static final String PRICE_UNIT_PATTERN = "trieu|tr|k|nghin|ngan|vnd|d";
    private static final Pattern PRICE_RANGE_PATTERN = Pattern.compile(
            "(?:tu\\s+)?(" + PRICE_NUMBER_PATTERN + ")\\s*(" + PRICE_UNIT_PATTERN + ")?"
                    + "\\s*(?:den|toi|-)\\s*(" + PRICE_NUMBER_PATTERN + ")\\s*(" + PRICE_UNIT_PATTERN + ")"
    );
    private static final Pattern MIN_PRICE_PATTERN = Pattern.compile(
            "(tren|hon|lon hon|cao hon|tu|it nhat|toi thieu|khong duoi)\\s*"
                    + "(" + PRICE_NUMBER_PATTERN + ")\\s*(" + PRICE_UNIT_PATTERN + ")?"
    );
    private static final Pattern MIN_PRICE_SUFFIX_PATTERN = Pattern.compile(
            "(" + PRICE_NUMBER_PATTERN + ")\\s*(" + PRICE_UNIT_PATTERN + ")?\\s*(?:tro len|do len)"
    );
    private static final Pattern MAX_PRICE_PATTERN = Pattern.compile(
            "(duoi|thap hon|nho hon|khong qua|toi da|tam gia|ngan sach)\\s*"
                    + "(" + PRICE_NUMBER_PATTERN + ")\\s*(" + PRICE_UNIT_PATTERN + ")?"
    );
    private static final Pattern MAX_PRICE_SUFFIX_PATTERN = Pattern.compile(
            "(" + PRICE_NUMBER_PATTERN + ")\\s*(" + PRICE_UNIT_PATTERN + ")?\\s*(?:tro xuong|do xuong)"
    );
    private static final Map<String, List<String>> COLOR_ALIASES = Map.ofEntries(
            Map.entry("den", List.of("den", "black")),
            Map.entry("trang", List.of("trang", "white")),
            Map.entry("do", List.of("do", "red")),
            Map.entry("xanh", List.of("xanh", "blue", "green", "navy")),
            Map.entry("xam", List.of("xam", "gray", "grey")),
            Map.entry("hong", List.of("hong", "pink")),
            Map.entry("vang", List.of("vang", "yellow")),
            Map.entry("nau", List.of("nau", "brown"))
    );
    private static final Map<String, Pattern> COLOR_QUERY_PATTERNS = Map.ofEntries(
            Map.entry("den", Pattern.compile("\\b(đen|black)\\b|\\b(?:màu|mau|color)\\s+den\\b")),
            Map.entry("trang", Pattern.compile("\\b(trắng|white)\\b|\\b(?:màu|mau|color)\\s+trang\\b")),
            Map.entry("do", Pattern.compile("\\b(đỏ|red)\\b|\\b(?:màu|mau|color)\\s+do\\b")),
            Map.entry("xanh", Pattern.compile("\\b(xanh|blue|green|navy)\\b")),
            Map.entry("xam", Pattern.compile("\\b(xám|gray|grey)\\b|\\b(?:màu|mau|color)\\s+xam\\b")),
            Map.entry("hong", Pattern.compile("\\b(hồng|pink)\\b|\\b(?:màu|mau|color)\\s+hong\\b")),
            Map.entry("vang", Pattern.compile("\\b(vàng|yellow)\\b|\\b(?:màu|mau|color)\\s+vang\\b")),
            Map.entry("nau", Pattern.compile("\\b(nâu|brown)\\b|\\b(?:màu|mau|color)\\s+nau\\b"))
    );
    private static final List<String> COLOR_PRIORITY = List.of(
            "den", "trang", "do", "xanh", "xam", "hong", "vang", "nau"
    );
    private static final Set<String> GREETING_TERMS = Set.of(
            "chao", "xin chao", "hello", "hi", "alo", "tro giup", "help"
    );
    private static final Set<String> FOLLOW_UP_TERMS = Set.of(
            "cai do", "mon do", "mon tren", "o tren", "dau tien", "thu hai", "thu ba", "vua goi y"
    );
    private static final Set<String> NEW_SEARCH_TERMS = Set.of(
            "tim", "kiem", "mua", "goi y", "tu van", "tat ca", "san pham", "mat hang"
    );
    private static final Set<String> PRODUCT_KIND_TERMS = Set.of(
            "giay", "ao", "quan", "vot", "tui", "balo", "mu", "non", "tat", "gang", "day", "bang"
    );
    private static final Map<String, List<String>> SPORT_ALIASES = Map.ofEntries(
            Map.entry("chay bo", List.of("chay bo", "running")),
            Map.entry("cau long", List.of("cau long", "badminton")),
            Map.entry("bong da", List.of("bong da", "football", "soccer", "futsal")),
            Map.entry("bong ro", List.of("bong ro", "basketball")),
            Map.entry("gym", List.of("gym", "fitness", "the hinh")),
            Map.entry("fitness", List.of("gym", "fitness", "the hinh")),
            Map.entry("tennis", List.of("tennis", "quan vot"))
    );
    private static final Set<String> BASIC_CATALOG_TERMS = Set.of(
            "tim", "kiem", "mua", "goi y", "tu van", "phu hop", "san pham", "mat hang",
            "gia", "ngan sach", "duoi", "tren", "hon", "it nhat", "toi thieu", "khong qua",
            "size", "mau", "sku", "con hang", "ton kho",
            "giay", "ao", "quan", "vot", "bong", "tui", "mu", "non", "tat", "gang", "day",
            "bang", "bao ho", "chay bo", "gym", "fitness", "cau long", "tennis", "bong da",
            "bong ro", "the thao", "tap", "tap luyen"
    );
    private static final Set<String> COMPLEX_REQUEST_TERMS = Set.of(
            "so sanh", "phan tich", "danh gia", "tai sao", "vi sao", "uu diem", "nhuoc diem",
            "nen chon", "toi bi dau", "bi chan thuong", "tu van suc khoe"
    );
    private static final Set<String> STOP_WORDS = Set.of(
            "toi", "muon", "mua", "tim", "kiem", "san", "pham", "con", "khong",
            "co", "bao", "nhieu", "cai", "chiec", "size", "mau", "cho", "minh", "ban",
            "shop", "hang", "ton", "kho", "gia", "la", "may", "hay", "goi", "y", "theo",
            "nhu", "cau", "phu", "hop", "can", "mot", "va", "voi", "nao", "giup", "do"
    );

    private final ProductCatalogClient productCatalogClient;
    private final RestTemplate restTemplate;

    @Value("${openrouter.api.key}")
    private String openRouterApiKey;

    @Value("${openrouter.api.url}")
    private String openRouterUrl;

    @Value("${openrouter.api.model}")
    private String openRouterModel;

    @Value("${openrouter.app.title}")
    private String openRouterAppTitle;

    @Value("${app.frontend.url}")
    private String frontendUrl;

    @Value("${chat.local.enabled:true}")
    private boolean localAssistantEnabled;

    public ChatResponse generateResponse(String userMessage, List<String> history) {
        return generateResponse(userMessage, history, null);
    }

    public ChatResponse generateResponse(String userMessage, List<String> history, String explicitIntent) {
        try {
            SupportIntent supportIntent = resolveSupportIntent(explicitIntent, userMessage);
            ChatResponse supportResponse = buildSupportIntentResponse(supportIntent);
            if (supportResponse != null) {
                return supportResponse;
            }

            String catalogMessage = enrichCatalogMessage(userMessage, supportIntent);
            List<String> safeHistory = sanitizeHistory(history, userMessage);
            ConversationCriteria criteria = extractCriteria(catalogMessage, safeHistory);

            if (localAssistantEnabled && isGreetingOnly(catalogMessage)) {
                return ChatResponse.builder()
                        .response(buildLocalGreeting())
                        .status("LOCAL")
                        .build();
            }

            List<Product> products = productCatalogClient.getProducts();
            ProductSearchResult searchResult = findRelevantProducts(catalogMessage, safeHistory, products, criteria);
            List<Product> relevantProducts = searchResult.products();

            if (localAssistantEnabled && shouldHandleLocally(catalogMessage, criteria, products)) {
                String localResult = buildLocalCatalogResponse(searchResult, criteria);
                if (searchResult.intentMatched() || !criteria.isEmpty()) {
                    localResult += buildActionMarkers(relevantProducts, criteria);
                }
                return ChatResponse.builder()
                        .response(localResult)
                        .status("LOCAL")
                        .build();
            }

            String productContext = buildProductContext(relevantProducts, criteria);
            String historyContext = String.join("\n", safeHistory);
            String criteriaContext = criteria.describe();

            String fullPrompt = String.format("""
                    Bạn là StrideX Support, trợ lý tư vấn bán hàng cho shop đồ thể thao.

                    DỮ LIỆU SẢN PHẨM LẤY TRỰC TIẾP TỪ BACKEND:
                    %s

                    LỊCH SỬ TRÒ CHUYỆN:
                    %s

                    KHÁCH HÀNG HỎI:
                    %s

                    RÀNG BUỘC ĐÃ ĐƯỢC BACKEND TRÍCH XUẤT:
                    %s

                    QUY TẮC BẮT BUỘC:
                    1. Khi khách hỏi còn hàng, số lượng, tồn kho, size, màu, SKU: chỉ trả lời dựa trên số liệu tồn kho trong dữ liệu backend ở trên.
                    2. Nếu sản phẩm có tồn kho > 0, nói rõ tổng số lượng còn lại và liệt kê size/màu/SKU còn hàng.
                    3. Nếu sản phẩm tồn kho = 0 hoặc không có variant còn hàng, nói rõ hiện hết hàng và gợi ý sản phẩm khác còn hàng nếu có.
                    4. Hiểu câu hỏi nối tiếp như "món ở trên", "cái đó", "trong số vừa gợi ý" dựa vào lịch sử. Không bắt khách nhắc lại từ đầu.
                    5. Ưu tiên đúng mọi ràng buộc giá, size, màu và còn hàng. Nếu không có kết quả khớp hoàn toàn, nói rõ ràng buộc nào chưa đáp ứng rồi đề xuất lựa chọn gần nhất.
                    6. Không tự bịa số lượng, size, màu, giá hoặc sản phẩm ngoài dữ liệu backend.
                    7. Không liệt kê toàn bộ kho. Chỉ đưa tối đa 3 lựa chọn tốt nhất, giải thích ngắn vì sao phù hợp và kết thúc bằng một câu hỏi hữu ích.
                    8. Trả lời bằng tiếng Việt tự nhiên, nhớ sở thích khách đã nói trong lịch sử và không lặp lại lời chào ở mỗi lượt.
                    """, productContext, historyContext, catalogMessage, criteriaContext);

            String aiResult;
            String status;
            try {
                aiResult = callOpenRouterApi(fullPrompt);
                status = "SUCCESS";
            } catch (RuntimeException aiError) {
                log.warn("OpenRouter unavailable after retries; using catalog fallback: {}", aiError.getMessage());
                aiResult = buildCatalogFallback(relevantProducts, criteria);
                status = "FALLBACK";
            }
            aiResult += buildActionMarkers(relevantProducts, criteria);

            return ChatResponse.builder()
                    .response(aiResult)
                    .status(status)
                    .build();
        } catch (Exception e) {
            log.error("ChatBot Error: {}", e.getMessage(), e);
            return ChatResponse.builder()
                    .response("Rất tiếc, hệ thống tư vấn đang bận xử lý. Bạn vui lòng thử lại sau hoặc xem sản phẩm trực tiếp tại cửa hàng nhé!")
                    .status("ERROR")
                    .build();
        }
    }

    private String enrichCatalogMessage(String userMessage, SupportIntent intent) {
        String safeMessage = userMessage == null ? "" : userMessage;
        String normalized = normalize(safeMessage);
        if (intent == SupportIntent.RUNNING_SHOES
                && !(containsTerm(normalized, "giay") && containsTerm(normalized, "chay bo"))) {
            return safeMessage + " giày chạy bộ";
        }
        if (intent == SupportIntent.GYM_PRODUCTS && !containsTerm(normalized, "gym")) {
            return safeMessage + " đồ gym";
        }
        return safeMessage;
    }

    private SupportIntent resolveSupportIntent(String explicitIntent, String userMessage) {
        SupportIntent explicit = SupportIntent.from(explicitIntent);
        if (explicit != null) {
            return explicit;
        }

        String message = normalize(userMessage);
        if (containsAnyPhrase(message, List.of(
                "tra cuu don hang",
                "tinh trang don hang",
                "theo doi don hang",
                "kiem tra don hang",
                "don hang cua minh"
        ))) {
            return SupportIntent.ORDER_LOOKUP;
        }
        if (containsAnyPhrase(message, List.of(
                "chinh sach doi tra",
                "ho tro doi tra",
                "yeu cau doi tra",
                "doi tra san pham",
                "doi tra",
                "hoan tra",
                "tra hang"
        ))) {
            return SupportIntent.RETURN_POLICY;
        }
        if (containsAnyPhrase(message, List.of(
                "gap nhan vien",
                "noi chuyen voi nhan vien",
                "lien he nhan vien",
                "nhan vien tu van",
                "tu van vien",
                "ho tro truc tiep",
                "gap nguoi that",
                "noi chuyen voi nguoi that"
        ))) {
            return SupportIntent.HUMAN_HANDOFF;
        }
        if (containsAnyPhrase(message, List.of(
                "tu van size",
                "chon size",
                "huong dan size",
                "bang size",
                "cung cap so do nao",
                "nen cung cap so do nao"
        ))) {
            return SupportIntent.SIZE_GUIDE;
        }
        if (containsAnyPhrase(message, List.of(
                "giam gia",
                "khuyen mai",
                "uu dai",
                "dang sale",
                "on sale"
        ))) {
            return SupportIntent.DISCOUNT_SEARCH;
        }
        boolean namesProductKind = PRODUCT_KIND_TERMS.stream()
                .anyMatch(kind -> isRequestedProductKind(message, kind));
        boolean namesSpecificSport = SPORT_ALIASES.keySet().stream()
                .anyMatch(sport -> containsTerm(message, sport));
        if ((containsTerm(message, "ngan sach") || containsTerm(message, "tam gia"))
                && !parseCriteria(userMessage).hasPriceConstraint()
                && !namesProductKind
                && !namesSpecificSport) {
            return SupportIntent.BUDGET_GUIDE;
        }
        boolean asksForUnspecifiedSport = containsAnyPhrase(message, List.of(
                "theo mon the thao",
                "mon the thao toi dang tap",
                "theo mon dang tap"
        ));
        if (asksForUnspecifiedSport && !namesSpecificSport) {
            return SupportIntent.SPORT_GUIDE;
        }
        return null;
    }

    private boolean containsAnyPhrase(String message, List<String> phrases) {
        return phrases.stream().anyMatch(phrase -> containsTerm(message, phrase));
    }

    private ChatResponse buildSupportIntentResponse(SupportIntent intent) {
        if (intent == null || intent == SupportIntent.RUNNING_SHOES || intent == SupportIntent.GYM_PRODUCTS) {
            return null;
        }

        String response = switch (intent) {
            case ORDER_LOOKUP -> "Bạn có thể xem trạng thái mới nhất trong mục Đơn hàng của tôi. "
                    + "Hãy mở đơn cần kiểm tra; nếu vẫn cần hỗ trợ, gửi mã đơn cho nhân viên "
                    + "và không gửi mã OTP hoặc thông tin thanh toán.\n\n"
                    + "[[ACTION:OPEN_ORDERS:route=/customer/orders;label=Xem đơn hàng của tôi]]";
            case RETURN_POLICY -> "Mình có thể hỗ trợ yêu cầu đổi/trả. Điều kiện áp dụng có thể khác theo "
                    + "đơn và sản phẩm, nên cần kiểm tra đúng đơn trước khi xác nhận. Hãy mở đơn hàng rồi "
                    + "gửi mã đơn, sản phẩm cần đổi/trả, lý do và tình trạng sản phẩm để nhân viên hỗ trợ.\n\n"
                    + "[[ACTION:OPEN_ORDERS:route=/customer/orders;label=Mở đơn cần đổi trả]]";
            case HUMAN_HANDOFF -> "Yêu cầu gặp nhân viên của bạn đã được ghi nhận trong phòng hỗ trợ này "
                    + "và nhân viên có thể xem nội dung bạn gửi. Bạn hãy mô tả ngắn vấn đề cần hỗ trợ; "
                    + "thời gian phản hồi tùy thời điểm. Không gửi mã OTP hoặc thông tin thanh toán.";
            case SIZE_GUIDE -> "Để tư vấn size chính xác hơn, với giày bạn hãy gửi chiều dài bàn chân "
                    + "theo cm (đo cả hai chân) và kiểu mang ôm hay thoải mái. Với áo/quần, hãy gửi chiều cao, "
                    + "cân nặng và số đo vòng ngực, eo, mông tùy sản phẩm. Bạn đang cần size cho món nào?";
            case DISCOUNT_SEARCH -> "Dữ liệu kho hiện chỉ có giá bán hiện tại, chưa có giá gốc hoặc cờ giảm giá "
                    + "đủ tin cậy nên mình chưa thể xác nhận món nào đang giảm giá. Bạn cho mình loại sản phẩm "
                    + "và ngân sách tối đa, mình sẽ lọc các lựa chọn phù hợp nhất theo giá hiện có.";
            case BUDGET_GUIDE -> "Bạn cho mình ngân sách tối đa hoặc một khoảng giá cụ thể, ví dụ “dưới "
                    + "1 triệu” hoặc “từ 1 đến 2 triệu”. Thêm loại sản phẩm, môn thể thao và size nếu có để "
                    + "mình lọc đúng hàng còn trong kho.";
            case SPORT_GUIDE -> "Bạn đang tập môn thể thao nào? Hãy cho mình thêm loại sản phẩm cần tìm "
                    + "(giày, áo, quần hoặc phụ kiện), size và ngân sách; mình sẽ lọc các món phù hợp trong kho.";
            case RUNNING_SHOES, GYM_PRODUCTS -> throw new IllegalStateException("Catalog intents are handled separately");
        };
        return ChatResponse.builder()
                .response(response)
                .status("LOCAL")
                .build();
    }

    private ProductSearchResult findRelevantProducts(String userMessage, List<String> history,
                                                     List<Product> products, ConversationCriteria criteria) {
        String currentMessage = normalize(userMessage);
        String historyText = normalize(String.join(" ", history));
        boolean followUp = containsAnyTerm(currentMessage, FOLLOW_UP_TERMS)
                || (!criteria.isEmpty() && !isNewCatalogSearch(userMessage));
        String retrievalText = followUp ? currentMessage + " " + historyText : currentMessage;
        List<String> keywords = List.of(retrievalText.split("\\s+")).stream()
                .map(String::trim)
                .filter(word -> word.length() >= 2)
                .filter(word -> !STOP_WORDS.contains(word))
                .distinct()
                .toList();

        List<Product> contextualMatches = products.stream()
                .filter(product -> scoreProduct(
                        product, currentMessage, followUp ? historyText : "", keywords
                ) >= MIN_CONTEXT_SCORE)
                .sorted(Comparator.comparingInt(
                        (Product product) -> scoreProduct(product, currentMessage, followUp ? historyText : "", keywords)
                ).reversed()
                        .thenComparing(product -> minimumInStockPrice(product),
                                Comparator.nullsLast(Comparator.naturalOrder()))
                        .thenComparing(Product::getId, Comparator.nullsLast(Comparator.naturalOrder())))
                .toList();

        SemanticFilters semanticFilters = extractSemanticFilters(currentMessage, products);
        if (!semanticFilters.isEmpty()) {
            contextualMatches = contextualMatches.stream()
                    .filter(product -> matchesSemanticFilters(product, semanticFilters))
                    .toList();
            if (contextualMatches.isEmpty()) {
                return new ProductSearchResult(List.of(), true, false);
            }
        }

        List<Product> pool = contextualMatches.isEmpty() ? products : contextualMatches;
        List<Product> exactMatches = pool.stream()
                .filter(product -> hasMatchingVariant(product, criteria))
                .limit(8)
                .toList();
        if (!exactMatches.isEmpty()) {
            return new ProductSearchResult(exactMatches, !contextualMatches.isEmpty(), true);
        }

        // Keep contextual alternatives so the model can explain which constraint
        // could not be met instead of forgetting the products discussed above.
        List<Product> alternatives = pool.stream()
                .sorted(Comparator.comparingInt(this::totalStock).reversed())
                .limit(5)
                .toList();
        return new ProductSearchResult(alternatives, !contextualMatches.isEmpty(), false);
    }

    private SemanticFilters extractSemanticFilters(String message, List<Product> products) {
        List<String> kinds = PRODUCT_KIND_TERMS.stream()
                .filter(kind -> isRequestedProductKind(message, kind))
                .toList();
        List<List<String>> sports = SPORT_ALIASES.entrySet().stream()
                .filter(entry -> containsTerm(message, entry.getKey()))
                .map(Map.Entry::getValue)
                .distinct()
                .toList();
        List<String> brands = products.stream()
                .map(product -> product.getBrand() == null ? "" : normalize(product.getBrand().getBrandName()))
                .filter(brand -> !brand.isBlank() && containsTerm(message, brand))
                .distinct()
                .toList();
        return new SemanticFilters(kinds, sports, brands);
    }

    private boolean isRequestedProductKind(String message, String kind) {
        if (!containsTerm(message, kind)) {
            return false;
        }
        if (!"tat".equals(kind) || !containsTerm(message, "tat ca")) {
            return true;
        }
        long sockTermCount = java.util.Arrays.stream(message.split("\\s+"))
                .filter("tat"::equals)
                .count();
        return sockTermCount > 1;
    }

    private boolean matchesSemanticFilters(Product product, SemanticFilters filters) {
        String productName = normalize(product.getProductName());
        String category = normalize(product.getCategory() == null ? "" : product.getCategory().getCategoryName());
        String sport = normalize(product.getSport() == null ? "" : product.getSport().getSportName());
        String brand = normalize(product.getBrand() == null ? "" : product.getBrand().getBrandName());

        boolean kindMatches = filters.kinds().isEmpty() || filters.kinds().stream()
                .anyMatch(kind -> containsTerm(productName, kind) || containsTerm(category, kind));
        boolean sportMatches = filters.sports().isEmpty() || filters.sports().stream()
                .anyMatch(aliases -> aliases.stream().anyMatch(alias -> containsTerm(sport, alias)));
        boolean brandMatches = filters.brands().isEmpty() || filters.brands().stream()
                .anyMatch(requestedBrand -> containsTerm(brand, requestedBrand));
        return kindMatches && sportMatches && brandMatches;
    }

    private int scoreProduct(Product product, String currentMessage, String historyText, List<String> keywords) {
        String productName = normalize(product.getProductName());
        String description = normalize(product.getDescription());
        String brand = normalize(product.getBrand() == null ? "" : product.getBrand().getBrandName());
        String category = normalize(product.getCategory() == null ? "" : product.getCategory().getCategoryName());
        String sport = normalize(product.getSport() == null ? "" : product.getSport().getSportName());

        int score = 0;
        if (!productName.isBlank() && containsTerm(currentMessage, productName)) {
            score += 40;
        }
        if (!historyText.isBlank() && !productName.isBlank() && containsTerm(historyText, productName)) {
            score += 12;
        }
        for (String keyword : keywords) {
            score += containsTerm(productName, keyword) ? 8 : 0;
            score += containsTerm(category, keyword) ? 7 : 0;
            score += containsTerm(sport, keyword) ? 7 : 0;
            score += containsTerm(brand, keyword) ? 6 : 0;
            score += containsTerm(description, keyword) ? 1 : 0;
        }
        if (product.getVariants() != null) {
            for (ProductVariant variant : product.getVariants()) {
                String variantSearchable = normalize(String.join(" ",
                        safe(variant.getSku()),
                        safe(variant.getColor()),
                        safe(variant.getSize())
                ));
                for (String keyword : keywords) {
                    if (containsTerm(variantSearchable, keyword)) {
                        score += 2;
                    }
                }
            }
        }
        return score;
    }

    private boolean isGreetingOnly(String userMessage) {
        String message = normalize(userMessage);
        return containsAnyTerm(message, GREETING_TERMS)
                && !containsAnyTerm(message, BASIC_CATALOG_TERMS)
                && !containsAnyTerm(message, FOLLOW_UP_TERMS);
    }

    private boolean shouldHandleLocally(String userMessage, ConversationCriteria criteria, List<Product> products) {
        String message = normalize(userMessage);
        if (containsAnyTerm(message, COMPLEX_REQUEST_TERMS)) {
            return false;
        }
        return !criteria.isEmpty()
                || containsAnyTerm(message, BASIC_CATALOG_TERMS)
                || containsAnyTerm(message, FOLLOW_UP_TERMS)
                || products.stream().anyMatch(product -> referencesProduct(message, product));
    }

    private boolean referencesProduct(String message, Product product) {
        return matchesCatalogField(message, product.getProductName())
                || matchesCatalogField(message, product.getBrand() == null ? null : product.getBrand().getBrandName())
                || matchesCatalogField(message, product.getCategory() == null ? null : product.getCategory().getCategoryName())
                || matchesCatalogField(message, product.getSport() == null ? null : product.getSport().getSportName());
    }

    private boolean matchesCatalogField(String message, String rawField) {
        String field = normalize(rawField);
        return !field.isBlank() && (containsTerm(message, field) || containsTerm(field, message));
    }

    private boolean containsAnyTerm(String text, Set<String> terms) {
        return terms.stream().anyMatch(term -> containsTerm(text, term));
    }

    private boolean containsTerm(String text, String term) {
        if (text == null || text.isBlank() || term == null || term.isBlank()) {
            return false;
        }
        return (" " + text + " ").contains(" " + term + " ");
    }

    private String buildLocalGreeting() {
        return "Chào bạn! Mình có thể tự tìm sản phẩm trực tiếp trong kho theo loại đồ, môn thể thao, "
                + "size, màu và ngân sách mà không cần gọi AI. Ví dụ: “Tìm giày chạy bộ size 42 dưới 2 triệu”.";
    }

    private String buildLocalCatalogResponse(ProductSearchResult result, ConversationCriteria criteria) {
        if (result.products().isEmpty()) {
            return result.intentMatched()
                    ? "Mình chưa tìm thấy sản phẩm đúng loại, môn thể thao hoặc thương hiệu bạn yêu cầu trong kho. "
                    + "Bạn muốn thử một lựa chọn gần khác không?"
                    : "Hiện cửa hàng chưa có dữ liệu sản phẩm để mình tìm kiếm. Bạn vui lòng thử lại sau nhé.";
        }
        if (!result.intentMatched() && criteria.isEmpty()) {
            return "Bạn cho mình thêm một chút thông tin như loại sản phẩm, môn thể thao, size, màu "
                    + "hoặc ngân sách để mình lọc đúng món phù hợp nhé.";
        }

        List<String> suggestions = result.products().stream()
                .map(product -> formatFallbackSuggestion(product, criteria))
                .filter(suggestion -> suggestion != null)
                .limit(3)
                .toList();
        if (suggestions.isEmpty()) {
            return "Mình chưa tìm thấy biến thể còn hàng phù hợp với yêu cầu hiện tại. "
                    + "Bạn có muốn đổi size, màu hoặc ngân sách không?";
        }

        String filters = describeActiveCriteria(criteria);
        String intro = result.constraintsMatched()
                ? "Mình đã tự lọc trực tiếp từ kho hàng"
                : "Kho chưa có lựa chọn khớp đủ yêu cầu; đây là các phương án gần nhất";
        return intro + (filters.isBlank() ? "." : " theo " + filters + ".")
                + " Các lựa chọn phù hợp nhất là:\n\n"
                + String.join("\n", suggestions)
                + "\n\nBạn muốn xem chi tiết hay thêm sản phẩm nào vào giỏ?";
    }

    private String describeActiveCriteria(ConversationCriteria criteria) {
        List<String> filters = new java.util.ArrayList<>();
        if (criteria.size() != null) {
            filters.add("size " + criteria.size());
        }
        if (criteria.color() != null) {
            filters.add("màu " + displayColor(criteria.color()));
        }
        if (criteria.minPrice() != null && criteria.maxPrice() != null) {
            filters.add((criteria.minPriceExclusive() ? "giá trên " : "giá từ ")
                    + formatMoney(criteria.minPrice())
                    + (criteria.maxPriceExclusive() ? " đến dưới " : " đến ")
                    + formatMoney(criteria.maxPrice()));
        } else if (criteria.minPrice() != null) {
            filters.add((criteria.minPriceExclusive() ? "giá trên " : "giá từ ")
                    + formatMoney(criteria.minPrice()));
        } else if (criteria.maxPrice() != null) {
            filters.add((criteria.maxPriceExclusive() ? "giá dưới " : "ngân sách tối đa ")
                    + formatMoney(criteria.maxPrice()));
        }
        return String.join(", ", filters);
    }

    private String formatMoney(BigDecimal price) {
        return new DecimalFormat("#,###").format(price).replace(',', '.') + " VNĐ";
    }

    private String displayColor(String color) {
        return switch (color) {
            case "den" -> "đen";
            case "trang" -> "trắng";
            case "do" -> "đỏ";
            case "xanh" -> "xanh";
            case "xam" -> "xám";
            case "hong" -> "hồng";
            case "vang" -> "vàng";
            case "nau" -> "nâu";
            default -> color;
        };
    }

    private String buildProductContext(List<Product> products, ConversationCriteria criteria) {
        if (products.isEmpty()) {
            return "Không tìm thấy sản phẩm nào trong database.";
        }

        return products.stream()
                .map(product -> formatProductForPrompt(product, criteria))
                .collect(Collectors.joining("\n---\n"));
    }

    private String formatProductForPrompt(Product product, ConversationCriteria criteria) {
        List<ProductVariant> allVariants = product.getVariants() == null
                ? List.of()
                : product.getVariants().stream()
                .sorted(Comparator.comparing(ProductVariant::getId))
                .toList();
        List<ProductVariant> matchingVariants = allVariants.stream()
                .filter(variant -> variantMatches(variant, criteria))
                .toList();
        List<ProductVariant> variants = criteria.isEmpty() || matchingVariants.isEmpty()
                ? allVariants
                : matchingVariants;

        int totalStock = variants.stream()
                .mapToInt(variant -> stockOf(variant.getStockQuantity()))
                .sum();

        String priceRange = buildPriceRange(variants);
        String variantLines = variants.isEmpty()
                ? "- Chưa có biến thể/tồn kho"
                : variants.stream()
                .map(variant -> String.format(
                        "- SKU: %s | Size: %s | Màu: %s | Giá: %s VNĐ | Tồn kho: %d | Trạng thái: %s",
                        fallback(variant.getSku(), "N/A"),
                        fallback(variant.getSize(), "N/A"),
                        fallback(variant.getColor(), "N/A"),
                        variant.getPrice() == null ? "Đang cập nhật" : variant.getPrice().toPlainString(),
                        stockOf(variant.getStockQuantity()),
                        stockOf(variant.getStockQuantity()) > 0 ? "CÒN HÀNG" : "HẾT HÀNG"
                ))
                .collect(Collectors.joining("\n"));

        String variantActionLines = variants.isEmpty()
                ? "- Không có variant để thao tác nhanh"
                : variants.stream()
                .map(variant -> String.format(
                        "- VariantId: %d | ProductId: %d | SKU: %s | Size: %s | Màu: %s | Có thể thêm giỏ: %s",
                        variant.getId(),
                        product.getId(),
                        fallback(variant.getSku(), "N/A"),
                        fallback(variant.getSize(), "N/A"),
                        fallback(variant.getColor(), "N/A"),
                        stockOf(variant.getStockQuantity()) > 0 ? "YES" : "NO"
                ))
                .collect(Collectors.joining("\n"));

        return String.format("""
                Tên sản phẩm: %s
                Mô tả: %s
                Brand: %s
                Danh mục: %s
                Môn thể thao: %s
                Giá tham khảo: %s
                Tổng tồn kho: %d
                Biến thể:
                %s
                Action metadata:
                %s
                """,
                product.getProductName(),
                fallback(product.getDescription(), "Chưa có mô tả"),
                product.getBrand() == null ? "N/A" : fallback(product.getBrand().getBrandName(), "N/A"),
                product.getCategory() == null ? "N/A" : fallback(product.getCategory().getCategoryName(), "N/A"),
                product.getSport() == null ? "N/A" : fallback(product.getSport().getSportName(), "N/A"),
                priceRange,
                totalStock,
                variantLines,
                variantActionLines
        );
    }

    private String buildActionMarkers(List<Product> products, ConversationCriteria criteria) {
        return products.stream()
                .filter(product -> product.getId() != null)
                .limit(3)
                .map(product -> {
                    List<ProductVariant> matchingVariants = product.getVariants() == null
                            ? List.of()
                            : product.getVariants().stream()
                            .filter(variant -> stockOf(variant.getStockQuantity()) > 0)
                            .filter(variant -> variantMatches(variant, criteria) || criteria.isEmpty())
                            .sorted(Comparator.comparing(ProductVariant::getPrice,
                                            Comparator.nullsLast(Comparator.naturalOrder()))
                                    .thenComparing(ProductVariant::getId,
                                            Comparator.nullsLast(Comparator.naturalOrder())))
                            .toList();
                    ProductVariant inStockVariant = matchingVariants.size() == 1
                            ? matchingVariants.get(0)
                            : null;

                    String productName = fallback(product.getProductName(), "Sản phẩm");
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

    private List<String> sanitizeHistory(List<String> history, String userMessage) {
        if (history == null) {
            return List.of();
        }
        String normalizedCurrent = normalize(userMessage);
        List<String> cleaned = history.stream()
                .filter(item -> item != null && !item.isBlank())
                .toList();
        if (!cleaned.isEmpty() && normalize(cleaned.get(cleaned.size() - 1)).endsWith(normalizedCurrent)) {
            cleaned = cleaned.subList(0, cleaned.size() - 1);
        }
        return cleaned.stream()
                .skip(Math.max(0, cleaned.size() - 10))
                .map(item -> item.length() > 1500 ? item.substring(0, 1500) : item)
                .toList();
    }

    private ConversationCriteria extractCriteria(String userMessage, List<String> history) {
        ConversationCriteria current = parseCriteria(userMessage);
        if (isNewCatalogSearch(userMessage)) {
            return current;
        }
        ConversationCriteria previous = latestCustomerCriteria(history);
        boolean currentSpecifiesPrice = current.hasPriceConstraint();
        return new ConversationCriteria(
                current.size() != null ? current.size() : previous.size(),
                current.color() != null ? current.color() : previous.color(),
                currentSpecifiesPrice ? current.minPrice() : previous.minPrice(),
                currentSpecifiesPrice ? current.minPriceExclusive() : previous.minPriceExclusive(),
                currentSpecifiesPrice ? current.maxPrice() : previous.maxPrice(),
                currentSpecifiesPrice ? current.maxPriceExclusive() : previous.maxPriceExclusive()
        );
    }

    private boolean isNewCatalogSearch(String rawMessage) {
        String message = normalize(rawMessage);
        if (containsAnyTerm(message, FOLLOW_UP_TERMS)) {
            return false;
        }
        boolean hasProductKind = PRODUCT_KIND_TERMS.stream()
                .anyMatch(kind -> isRequestedProductKind(message, kind));
        boolean hasSport = SPORT_ALIASES.keySet().stream().anyMatch(sport -> containsTerm(message, sport));
        return hasProductKind || hasSport || containsAnyTerm(message, NEW_SEARCH_TERMS);
    }

    private ConversationCriteria latestCustomerCriteria(List<String> history) {
        String size = null;
        String color = null;
        BigDecimal minPrice = null;
        boolean minPriceExclusive = false;
        BigDecimal maxPrice = null;
        boolean maxPriceExclusive = false;
        boolean priceResolved = false;
        for (int index = history.size() - 1; index >= 0; index--) {
            String item = history.get(index);
            String normalizedItem = normalize(item);
            if (normalizedItem.startsWith("assistant ")
                    || normalizedItem.startsWith("admin ")
                    || normalizedItem.startsWith("bot ")
                    || normalizedItem.startsWith("ai ")
                    || normalizedItem.startsWith("tro ly ")) {
                continue;
            }
            ConversationCriteria parsed = parseCriteria(item);
            size = size == null ? parsed.size() : size;
            color = color == null ? parsed.color() : color;
            if (!priceResolved && parsed.hasPriceConstraint()) {
                minPrice = parsed.minPrice();
                minPriceExclusive = parsed.minPriceExclusive();
                maxPrice = parsed.maxPrice();
                maxPriceExclusive = parsed.maxPriceExclusive();
                priceResolved = true;
            }
            if (size != null && color != null && priceResolved) {
                break;
            }
        }
        return new ConversationCriteria(
                size, color, minPrice, minPriceExclusive, maxPrice, maxPriceExclusive
        );
    }

    private ConversationCriteria parseCriteria(String rawMessage) {
        String message = normalize(rawMessage);
        String originalLower = rawMessage == null ? "" : rawMessage.toLowerCase(Locale.ROOT);
        String size = null;
        Matcher sizeMatcher = SIZE_PATTERN.matcher(message);
        if (sizeMatcher.find()) {
            size = switch (sizeMatcher.group(1).replace(" ", "").toUpperCase(Locale.ROOT)) {
                case "2XL" -> "XXL";
                case "FREESIZE" -> "FreeSize";
                default -> sizeMatcher.group(1).toUpperCase(Locale.ROOT);
            };
        }

        String color = COLOR_PRIORITY.stream()
                .filter(key -> COLOR_QUERY_PATTERNS.get(key).matcher(originalLower).find())
                .findFirst().orElse(null);

        BigDecimal minPrice = null;
        boolean minPriceExclusive = false;
        BigDecimal maxPrice = null;
        boolean maxPriceExclusive = false;
        String priceMessage = normalizeForPrice(rawMessage);

        Matcher rangeMatcher = PRICE_RANGE_PATTERN.matcher(priceMessage);
        if (rangeMatcher.find()) {
            minPrice = parsePriceAmount(rangeMatcher.group(1), rangeMatcher.group(2));
            maxPrice = parsePriceAmount(rangeMatcher.group(3), rangeMatcher.group(4));
            if (minPrice.compareTo(maxPrice) > 0) {
                BigDecimal originalMin = minPrice;
                minPrice = maxPrice;
                maxPrice = originalMin;
            }
        } else {
            Matcher minMatcher = MIN_PRICE_PATTERN.matcher(priceMessage);
            if (minMatcher.find()) {
                String qualifier = minMatcher.group(1);
                minPrice = parsePriceAmount(minMatcher.group(2), minMatcher.group(3));
                minPriceExclusive = Set.of("tren", "hon", "lon hon", "cao hon").contains(qualifier);
            } else {
                Matcher minSuffixMatcher = MIN_PRICE_SUFFIX_PATTERN.matcher(priceMessage);
                if (minSuffixMatcher.find()) {
                    minPrice = parsePriceAmount(minSuffixMatcher.group(1), minSuffixMatcher.group(2));
                }
            }

            Matcher maxMatcher = MAX_PRICE_PATTERN.matcher(priceMessage);
            if (maxMatcher.find()) {
                String qualifier = maxMatcher.group(1);
                maxPrice = parsePriceAmount(maxMatcher.group(2), maxMatcher.group(3));
                maxPriceExclusive = Set.of("duoi", "thap hon", "nho hon").contains(qualifier);
            } else {
                Matcher maxSuffixMatcher = MAX_PRICE_SUFFIX_PATTERN.matcher(priceMessage);
                if (maxSuffixMatcher.find()) {
                    maxPrice = parsePriceAmount(maxSuffixMatcher.group(1), maxSuffixMatcher.group(2));
                }
            }
        }
        return new ConversationCriteria(
                size, color, minPrice, minPriceExclusive, maxPrice, maxPriceExclusive
        );
    }

    private BigDecimal parsePriceAmount(String rawAmount, String unit) {
        boolean groupedThousands = rawAmount.matches("[0-9]{1,3}(?:[.,][0-9]{3})+");
        BigDecimal amount = groupedThousands
                ? new BigDecimal(rawAmount.replace(".", "").replace(",", ""))
                : new BigDecimal(rawAmount.replace(',', '.'));
        if ("tr".equals(unit) || "trieu".equals(unit)) {
            return amount.multiply(BigDecimal.valueOf(1_000_000));
        }
        if ("k".equals(unit) || "nghin".equals(unit) || "ngan".equals(unit)) {
            return amount.multiply(BigDecimal.valueOf(1_000));
        }
        if (unit == null && !groupedThousands) {
            if (amount.compareTo(BigDecimal.valueOf(100)) < 0) {
                return amount.multiply(BigDecimal.valueOf(1_000_000));
            }
            if (amount.compareTo(BigDecimal.valueOf(10_000)) < 0) {
                return amount.multiply(BigDecimal.valueOf(1_000));
            }
        }
        return amount;
    }

    private String normalizeForPrice(String value) {
        if (value == null) {
            return "";
        }
        String normalized = Normalizer.normalize(
                value.replace('đ', 'd').replace('Đ', 'D'),
                Normalizer.Form.NFD
        );
        return DIACRITICS_PATTERN.matcher(normalized)
                .replaceAll("")
                .toLowerCase(Locale.ROOT)
                .replaceAll("[^a-z0-9.,\\-\\s]", " ")
                .replaceAll("\\s+", " ")
                .trim();
    }

    private boolean hasMatchingVariant(Product product, ConversationCriteria criteria) {
        return product.getVariants() != null && product.getVariants().stream()
                .anyMatch(variant -> variantMatches(variant, criteria));
    }

    private boolean variantMatches(ProductVariant variant, ConversationCriteria criteria) {
        if (stockOf(variant.getStockQuantity()) <= 0) {
            return false;
        }
        if (criteria.size() != null && !normalize(variant.getSize()).equals(normalize(criteria.size()))) {
            return false;
        }
        if (criteria.color() != null) {
            String variantColor = normalize(variant.getColor());
            boolean colorMatches = COLOR_ALIASES.get(criteria.color()).stream().anyMatch(variantColor::contains);
            if (!colorMatches) {
                return false;
            }
        }
        if (criteria.hasPriceConstraint() && variant.getPrice() == null) {
            return false;
        }
        if (criteria.minPrice() != null) {
            int comparison = variant.getPrice().compareTo(criteria.minPrice());
            if (comparison < 0 || (comparison == 0 && criteria.minPriceExclusive())) {
                return false;
            }
        }
        if (criteria.maxPrice() != null) {
            int comparison = variant.getPrice().compareTo(criteria.maxPrice());
            if (comparison > 0 || (comparison == 0 && criteria.maxPriceExclusive())) {
                return false;
            }
        }
        return true;
    }

    private record ConversationCriteria(
            String size,
            String color,
            BigDecimal minPrice,
            boolean minPriceExclusive,
            BigDecimal maxPrice,
            boolean maxPriceExclusive
    ) {
        boolean isEmpty() {
            return size == null && color == null && !hasPriceConstraint();
        }

        boolean hasPriceConstraint() {
            return minPrice != null || maxPrice != null;
        }

        String describe() {
            return "Size=" + (size == null ? "không yêu cầu" : size)
                    + "; Màu=" + (color == null ? "không yêu cầu" : color)
                    + "; Giá tối thiểu=" + (minPrice == null ? "không yêu cầu"
                    : (minPriceExclusive ? "trên " : "từ ") + minPrice.toPlainString() + " VNĐ")
                    + "; Giá tối đa=" + (maxPrice == null ? "không yêu cầu" : maxPrice.toPlainString() + " VNĐ");
        }
    }

    private record ProductSearchResult(List<Product> products, boolean intentMatched, boolean constraintsMatched) {
    }

    private record SemanticFilters(List<String> kinds, List<List<String>> sports, List<String> brands) {
        boolean isEmpty() {
            return kinds.isEmpty() && sports.isEmpty() && brands.isEmpty();
        }
    }

    private enum SupportIntent {
        RUNNING_SHOES,
        GYM_PRODUCTS,
        DISCOUNT_SEARCH,
        SIZE_GUIDE,
        SPORT_GUIDE,
        BUDGET_GUIDE,
        ORDER_LOOKUP,
        RETURN_POLICY,
        HUMAN_HANDOFF;

        private static SupportIntent from(String rawIntent) {
            if (rawIntent == null || rawIntent.isBlank()) {
                return null;
            }
            String normalized = rawIntent.trim()
                    .toUpperCase(Locale.ROOT)
                    .replace('-', '_')
                    .replace(' ', '_');
            try {
                return valueOf(normalized);
            } catch (IllegalArgumentException ignored) {
                return null;
            }
        }
    }

    private String buildPriceRange(List<ProductVariant> variants) {
        List<BigDecimal> prices = variants.stream()
                .map(ProductVariant::getPrice)
                .filter(price -> price != null)
                .sorted()
                .toList();
        if (prices.isEmpty()) {
            return "Đang cập nhật";
        }
        BigDecimal min = prices.get(0);
        BigDecimal max = prices.get(prices.size() - 1);
        if (min.compareTo(max) == 0) {
            return min.toPlainString() + " VNĐ";
        }
        return min.toPlainString() + " - " + max.toPlainString() + " VNĐ";
    }

    private int totalStock(Product product) {
        if (product.getVariants() == null) {
            return 0;
        }
        return product.getVariants().stream()
                .mapToInt(variant -> stockOf(variant.getStockQuantity()))
                .sum();
    }

    private BigDecimal minimumInStockPrice(Product product) {
        if (product.getVariants() == null) {
            return null;
        }
        return product.getVariants().stream()
                .filter(variant -> stockOf(variant.getStockQuantity()) > 0)
                .map(ProductVariant::getPrice)
                .filter(price -> price != null)
                .min(Comparator.naturalOrder())
                .orElse(null);
    }

    private int stockOf(Integer stock) {
        return stock == null ? 0 : Math.max(stock, 0);
    }

    private String normalize(String value) {
        if (value == null) {
            return "";
        }
        String normalized = Normalizer.normalize(
                value.replace('đ', 'd').replace('Đ', 'D'),
                Normalizer.Form.NFD
        );
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

    private String callOpenRouterApi(String prompt) {
        if (openRouterApiKey == null || openRouterApiKey.isBlank()) {
            throw new RuntimeException("OPENROUTER_API_KEY is not configured");
        }
        Map<String, Object> requestBody = Map.of(
                "model", openRouterModel,
                "messages", List.of(Map.of(
                        "role", "user",
                        "content", prompt
                )),
                "max_tokens", 900
        );
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(openRouterApiKey);
        if (frontendUrl != null && !frontendUrl.isBlank()) {
            headers.set("HTTP-Referer", frontendUrl);
        }
        if (openRouterAppTitle != null && !openRouterAppTitle.isBlank()) {
            headers.set("X-OpenRouter-Title", openRouterAppTitle);
        }
        HttpEntity<Map<String, Object>> request = new HttpEntity<>(requestBody, headers);

        RuntimeException lastError = null;
        for (int attempt = 1; attempt <= OPENROUTER_MAX_ATTEMPTS; attempt++) {
            try {
                Map<?, ?> response = restTemplate.postForObject(openRouterUrl, request, Map.class);
                return extractOpenRouterText(response);
            } catch (RestClientResponseException e) {
                String errorDetail = extractOpenRouterHttpError(e.getResponseBodyAsString());
                lastError = new RuntimeException(
                        "OpenRouter returned HTTP " + e.getStatusCode().value() + errorDetail, e);
                if (!isRetryableStatus(e.getStatusCode().value()) || attempt == OPENROUTER_MAX_ATTEMPTS) {
                    break;
                }
                log.warn("OpenRouter returned HTTP {} (attempt {}/{}); retrying",
                        e.getStatusCode().value(), attempt, OPENROUTER_MAX_ATTEMPTS);
                waitBeforeRetry(attempt);
            } catch (ResourceAccessException e) {
                lastError = new RuntimeException("OpenRouter connection failed", e);
                if (attempt == OPENROUTER_MAX_ATTEMPTS) {
                    break;
                }
                log.warn("OpenRouter connection failed (attempt {}/{}); retrying",
                        attempt, OPENROUTER_MAX_ATTEMPTS);
                waitBeforeRetry(attempt);
            } catch (Exception e) {
                throw new RuntimeException("OpenRouter communication failed: " + e.getMessage(), e);
            }
        }
        throw lastError == null ? new RuntimeException("OpenRouter did not return a response") : lastError;
    }

    private boolean isRetryableStatus(int status) {
        return status == 429 || status == 500 || status == 502 || status == 503 || status == 504;
    }

    private void waitBeforeRetry(int attempt) {
        try {
            Thread.sleep(OPENROUTER_INITIAL_BACKOFF_MS * (1L << (attempt - 1)));
        } catch (InterruptedException interrupted) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("OpenRouter retry interrupted", interrupted);
        }
    }

    private String buildCatalogFallback(List<Product> products, ConversationCriteria criteria) {
        if (products.isEmpty()) {
            return "Hiện tôi chưa tìm thấy sản phẩm phù hợp trong cửa hàng. "
                    + "Bạn cho tôi biết thêm loại sản phẩm, size, màu hoặc ngân sách nhé.";
        }

        List<String> suggestions = products.stream()
                .map(product -> formatFallbackSuggestion(product, criteria))
                .filter(suggestion -> suggestion != null)
                .limit(3)
                .toList();
        if (suggestions.isEmpty()) {
            return "Tôi chưa tìm thấy biến thể còn hàng đáp ứng đủ " + criteria.describe()
                    + ". Bạn có muốn nới size, màu hoặc ngân sách không?";
        }

        return "Dịch vụ AI đang tạm gián đoạn, nhưng tôi đã kiểm tra trực tiếp dữ liệu cửa hàng. "
                + "Các lựa chọn phù hợp nhất là:\n\n"
                + String.join("\n", suggestions)
                + "\n\nBạn muốn xem chi tiết hay thêm sản phẩm nào vào giỏ?";
    }

    private String formatFallbackSuggestion(Product product, ConversationCriteria criteria) {
        if (product.getVariants() == null) {
            return null;
        }
        ProductVariant variant = product.getVariants().stream()
                .filter(item -> variantMatches(item, criteria))
                .min(Comparator.comparing(ProductVariant::getPrice,
                                Comparator.nullsLast(Comparator.naturalOrder()))
                        .thenComparing(ProductVariant::getId,
                                Comparator.nullsLast(Comparator.naturalOrder())))
                .orElseGet(() -> product.getVariants().stream()
                        .filter(item -> stockOf(item.getStockQuantity()) > 0)
                        .min(Comparator.comparing(ProductVariant::getPrice,
                                        Comparator.nullsLast(Comparator.naturalOrder()))
                                .thenComparing(ProductVariant::getId,
                                        Comparator.nullsLast(Comparator.naturalOrder())))
                        .orElse(null));
        if (variant == null) {
            return null;
        }
        String price = variant.getPrice() == null
                ? "đang cập nhật"
                : new DecimalFormat("#,###").format(variant.getPrice()).replace(',', '.') + " VNĐ";
        return "• " + fallback(product.getProductName(), "Sản phẩm")
                + " — Size " + fallback(variant.getSize(), "N/A")
                + ", màu " + fallback(variant.getColor(), "N/A")
                + ", " + price
                + ", còn " + stockOf(variant.getStockQuantity()) + " sản phẩm.";
    }

    private String extractOpenRouterText(Map<?, ?> response) {
        if (response == null) {
            throw new RuntimeException("OpenRouter returned an empty response");
        }
        if (response.get("error") != null) {
            throw new RuntimeException("OpenRouter request failed" + describeOpenRouterError(response.get("error")));
        }
        if (!(response.get("choices") instanceof List<?> choices) || choices.isEmpty()) {
            throw new RuntimeException("OpenRouter response did not contain choices");
        }
        Object firstChoice = choices.get(0);
        if (!(firstChoice instanceof Map<?, ?> choice)) {
            throw new RuntimeException("OpenRouter returned an invalid choice");
        }
        if (choice.get("error") != null || "error".equals(choice.get("finish_reason"))) {
            throw new RuntimeException("OpenRouter generation failed" + describeOpenRouterError(choice.get("error")));
        }
        if (choice.get("message") instanceof Map<?, ?> message) {
            String content = extractOpenRouterContent(message.get("content"));
            if (!content.isBlank()) {
                return content;
            }
        }
        throw new RuntimeException("OpenRouter response did not contain assistant text");
    }

    private String extractOpenRouterContent(Object content) {
        if (content instanceof String text) {
            return text.trim();
        }
        if (content instanceof List<?> parts) {
            return parts.stream()
                    .filter(Map.class::isInstance)
                    .map(Map.class::cast)
                    .map(part -> part.get("text"))
                    .filter(String.class::isInstance)
                    .map(String.class::cast)
                    .filter(text -> !text.isBlank())
                    .collect(Collectors.joining("\n"));
        }
        return "";
    }

    private String extractOpenRouterHttpError(String responseBody) {
        if (responseBody == null || responseBody.isBlank()) {
            return "";
        }
        try {
            Map<?, ?> parsed = JSON.readValue(responseBody, Map.class);
            return describeOpenRouterError(parsed.get("error"));
        } catch (Exception ignored) {
            return "";
        }
    }

    private String describeOpenRouterError(Object error) {
        if (!(error instanceof Map<?, ?> errorMap)) {
            return "";
        }
        Object metadata = errorMap.get("metadata");
        Object errorType = metadata instanceof Map<?, ?> metadataMap
                ? metadataMap.get("error_type")
                : null;
        String details = java.util.stream.Stream.of(errorMap.get("code"), errorType, errorMap.get("message"))
                .filter(value -> value != null && !value.toString().isBlank())
                .map(Object::toString)
                .collect(Collectors.joining(" | "));
        return details.isBlank() ? "" : ": " + details;
    }
}
