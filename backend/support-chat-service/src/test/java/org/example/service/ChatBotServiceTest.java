package org.example.service;

import org.example.dto.response.ChatResponse;
import org.example.model.Brand;
import org.example.model.Category;
import org.example.model.Product;
import org.example.model.ProductVariant;
import org.example.model.Sport;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.content;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.header;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

class ChatBotServiceTest {
    private static final String OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions";

    private MockRestServiceServer server;
    private StubProductCatalogClient productCatalogClient;
    private ChatBotService chatBotService;

    @BeforeEach
    void setUp() {
        RestTemplate restTemplate = new RestTemplate();
        server = MockRestServiceServer.bindTo(restTemplate).build();
        productCatalogClient = new StubProductCatalogClient();
        chatBotService = new ChatBotService(productCatalogClient, restTemplate);

        ReflectionTestUtils.setField(chatBotService, "openRouterApiKey", "test-openrouter-key");
        ReflectionTestUtils.setField(chatBotService, "openRouterUrl", OPENROUTER_URL);
        ReflectionTestUtils.setField(chatBotService, "openRouterModel", "openrouter/free");
        ReflectionTestUtils.setField(chatBotService, "openRouterAppTitle", "StrideX Sport Shop");
        ReflectionTestUtils.setField(chatBotService, "frontendUrl", "http://localhost:5173");
        ReflectionTestUtils.setField(chatBotService, "localAssistantEnabled", true);
    }

    @Test
    void sendsOpenRouterChatCompletionRequestAndParsesAssistantText() {
        server.expect(requestTo(OPENROUTER_URL))
                .andExpect(method(HttpMethod.POST))
                .andExpect(header(HttpHeaders.AUTHORIZATION, "Bearer test-openrouter-key"))
                .andExpect(header("HTTP-Referer", "http://localhost:5173"))
                .andExpect(header("X-OpenRouter-Title", "StrideX Sport Shop"))
                .andExpect(content().json("""
                        {
                          "model": "openrouter/free",
                          "messages": [{"role": "user"}],
                          "max_tokens": 900
                        }
                        """, false))
                .andRespond(withSuccess("""
                        {
                          "id": "generation-test",
                          "choices": [{
                            "message": {"role": "assistant", "content": "Mình đã tìm thấy sản phẩm phù hợp."},
                            "finish_reason": "stop"
                          }]
                        }
                        """, MediaType.APPLICATION_JSON));

        ChatResponse response = chatBotService.generateResponse("Kể một câu chuyện ngắn", List.of());

        assertThat(response.getStatus()).isEqualTo("SUCCESS");
        assertThat(response.getResponse()).startsWith("Mình đã tìm thấy sản phẩm phù hợp.");
        server.verify();
    }

    @Test
    void fallsBackWhenOpenRouterReturnsAnInBandError() {
        server.expect(requestTo(OPENROUTER_URL))
                .andRespond(withSuccess("""
                        {
                          "error": {
                            "code": 402,
                            "message": "Insufficient credits"
                          }
                        }
                        """, MediaType.APPLICATION_JSON));

        ChatResponse response = chatBotService.generateResponse("Kể một câu chuyện ngắn", List.of());

        assertThat(response.getStatus()).isEqualTo("FALLBACK");
        assertThat(response.getResponse()).contains("chưa tìm thấy sản phẩm phù hợp");
        server.verify();
    }

    @Test
    void handlesRunningShoeSearchLocallyWithoutCallingOpenRouter() {
        Product runningShoe = product(
                2L,
                "Giày Chạy Bộ Nike Air Zoom Pegasus 40",
                "Đệm êm cho chạy bộ hằng ngày",
                "Nike",
                "Giày chạy bộ",
                "Chạy bộ (Running)",
                variant(7L, "NK-PEG40-BLK-42", "42", "Đen", "1800000", 15)
        );
        Product kneeGuard = product(
                9L,
                "Băng Bảo Vệ Đầu Gối Nike Pro",
                "Hỗ trợ đầu gối khi chạy bộ và tập luyện",
                "Nike",
                "Bảo hộ chấn thương",
                "Gym & Fitness",
                variant(24L, "NK-KNEE-BLK-FREE", "FreeSize", "Đen", "350000", 98)
        );
        productCatalogClient.setProducts(List.of(kneeGuard, runningShoe));

        ChatResponse response = chatBotService.generateResponse(
                "Tìm giày chạy bộ size 42 màu đen dưới 2 triệu, hãy gợi ý cho mình",
                List.of()
        );

        assertThat(response.getStatus()).isEqualTo("LOCAL");
        assertThat(response.getResponse())
                .contains("Giày Chạy Bộ Nike Air Zoom Pegasus 40")
                .contains("variantId=7")
                .doesNotContain("Băng Bảo Vệ Đầu Gối")
                .doesNotContain("Dịch vụ AI");
        server.verify();
    }

    @Test
    void handlesTheRunningShoePromptFromTheAppWithTheCompleteCatalog() {
        Product runningShoe = product(
                2L,
                "Giày Chạy Bộ Nike Air Zoom Pegasus 40",
                "Đệm êm cho chạy bộ hằng ngày",
                "Nike",
                "Giày chạy bộ",
                "Chạy bộ (Running)",
                variant(7L, "NK-PEG40-BLK-40", "40", "Đen Trắng", "3200000", 20)
        );
        Product trainingShorts = product(
                3L,
                "Quần Short Tập Gym Nam Adidas Aeroready",
                "Quần tập gym và chạy bộ",
                "Adidas",
                "Quần short",
                "Gym & Fitness",
                variant(9L, "AD-SHORT-GRY-L", "L", "Xám", "550000", 40)
        );
        productCatalogClient.setProducts(List.of(trainingShorts, runningShoe));

        ChatResponse response = chatBotService.generateResponse(
                "Tôi muốn tìm giày chạy bộ. Hãy gợi ý sản phẩm theo nhu cầu tập luyện và ngân sách.",
                List.of()
        );

        assertThat(response.getStatus()).isEqualTo("LOCAL");
        assertThat(response.getResponse())
                .contains("Giày Chạy Bộ Nike Air Zoom Pegasus 40")
                .doesNotContain("Quần Short Tập Gym Nam Adidas Aeroready")
                .doesNotContain("không có bất kỳ mẫu giày chạy bộ");
        server.verify();
    }

    @Test
    void handlesTheGymPromptFromTheAppWithoutReturningRunningShoes() {
        Product runningShoe = product(
                2L,
                "Giày Chạy Bộ Nike Air Zoom Pegasus 40",
                "Đệm êm cho chạy bộ hằng ngày",
                "Nike",
                "Giày chạy bộ",
                "Chạy bộ (Running)",
                variant(7L, "NK-PEG40-BLK-40", "40", "Đen Trắng", "3200000", 20)
        );
        Product trainingShorts = product(
                3L,
                "Quần Short Tập Gym Nam Adidas Aeroready",
                "Quần tập gym thoải mái, dễ vận động",
                "Adidas",
                "Quần short",
                "Gym & Fitness",
                variant(9L, "AD-SHORT-GRY-L", "L", "Xám", "550000", 40)
        );
        productCatalogClient.setProducts(List.of(runningShoe, trainingShorts));

        ChatResponse response = chatBotService.generateResponse(
                "Tôi muốn tìm đồ gym thoải mái, dễ vận động. Hãy gợi ý sản phẩm phù hợp.",
                List.of()
        );

        assertThat(response.getStatus()).isEqualTo("LOCAL");
        assertThat(response.getResponse())
                .contains("Quần Short Tập Gym Nam Adidas Aeroready")
                .doesNotContain("Giày Chạy Bộ Nike Air Zoom Pegasus 40");
        server.verify();
    }

    @Test
    void routesEveryNonCatalogQuickPromptBeforeProductSearch() {
        Map<String, String> prompts = new LinkedHashMap<>();
        prompts.put(
                "Hiện có sản phẩm thể thao nào đang giảm giá hoặc đáng mua không?",
                "chưa có giá gốc hoặc cờ giảm giá"
        );
        prompts.put(
                "Tôi cần tư vấn size giày hoặc quần áo thể thao. Tôi nên cung cấp số đo nào?",
                "chiều dài bàn chân"
        );
        prompts.put(
                "Hãy gợi ý trang phục hoặc giày theo môn thể thao tôi đang tập.",
                "Bạn đang tập môn thể thao nào?"
        );
        prompts.put(
                "Tôi muốn chọn sản phẩm theo ngân sách. Hãy gợi ý vài lựa chọn tốt.",
                "ngân sách tối đa hoặc một khoảng giá"
        );
        prompts.put(
                "Tôi muốn tra cứu tình trạng đơn hàng của mình.",
                "[[ACTION:OPEN_ORDERS:"
        );
        prompts.put(
                "Tôi cần hỗ trợ về chính sách đổi trả sản phẩm.",
                "sản phẩm cần đổi/trả"
        );
        prompts.put(
                "Tôi muốn gặp nhân viên tư vấn để được hỗ trợ trực tiếp.",
                "nhân viên có thể xem nội dung"
        );

        prompts.forEach((prompt, expected) -> {
            ChatResponse response = chatBotService.generateResponse(prompt, List.of());
            assertThat(response.getStatus()).as(prompt).isEqualTo("LOCAL");
            assertThat(response.getResponse())
                    .as(prompt)
                    .contains(expected)
                    .doesNotContain("[[ACTION:VIEW_PRODUCT:")
                    .doesNotContain("Các lựa chọn phù hợp nhất");
        });
        server.verify();
    }

    @Test
    void honorsEveryExplicitSupportIntentWithoutCallingTheCatalogOrAi() {
        Map<String, String> intents = new LinkedHashMap<>();
        intents.put("ORDER_LOOKUP", "OPEN_ORDERS");
        intents.put("RETURN_POLICY", "Mở đơn cần đổi trả");
        intents.put("HUMAN_HANDOFF", "nhân viên có thể xem nội dung");
        intents.put("SIZE_GUIDE", "số đo vòng ngực");
        intents.put("DISCOUNT_SEARCH", "chưa thể xác nhận món nào đang giảm giá");
        intents.put("BUDGET_GUIDE", "từ 1 đến 2 triệu");
        intents.put("SPORT_GUIDE", "Bạn đang tập môn thể thao nào?");

        intents.forEach((intent, expected) -> {
            ChatResponse response = chatBotService.generateResponse(
                    "Tìm giày màu trắng",
                    List.of(),
                    intent
            );
            assertThat(response.getStatus()).as(intent).isEqualTo("LOCAL");
            assertThat(response.getResponse())
                    .as(intent)
                    .contains(expected)
                    .doesNotContain("[[ACTION:VIEW_PRODUCT:");
        });
        assertThat(productCatalogClient.getRequestCount()).isZero();
        server.verify();
    }

    @Test
    void explicitCatalogIntentsStillUseTheLocalCatalogSearch() {
        Product runningShoe = product(
                2L,
                "Giày Chạy Bộ Nike Air Zoom Pegasus 40",
                "Đệm êm",
                "Nike",
                "Giày chạy bộ",
                "Chạy bộ (Running)",
                variant(7L, "NK-PEG40-BLK-40", "40", "Đen", "3200000", 20)
        );
        Product gymShorts = product(
                3L,
                "Quần Short Tập Gym Nam Adidas Aeroready",
                "Dễ vận động",
                "Adidas",
                "Quần short",
                "Gym & Fitness",
                variant(9L, "AD-SHORT-GRY-L", "L", "Xám", "550000", 40)
        );
        productCatalogClient.setProducts(List.of(runningShoe, gymShorts));

        ChatResponse running = chatBotService.generateResponse("Hãy giúp tôi", List.of(), "RUNNING_SHOES");
        ChatResponse gym = chatBotService.generateResponse("Hãy giúp tôi", List.of(), "GYM_PRODUCTS");

        assertThat(running.getResponse())
                .contains("Giày Chạy Bộ Nike Air Zoom Pegasus 40")
                .doesNotContain("Quần Short Tập Gym Nam Adidas Aeroready");
        assertThat(gym.getResponse())
                .contains("Quần Short Tập Gym Nam Adidas Aeroready")
                .doesNotContain("Giày Chạy Bộ Nike Air Zoom Pegasus 40");
        server.verify();
    }

    @Test
    void doesNotTreatTrangPhucOrHongAsWhiteOrPinkColorFilters() {
        Product whiteShirt = product(
                21L,
                "Áo Thể Thao Trắng",
                "Trang phục tập luyện",
                "Nike",
                "Áo thể thao",
                "Gym & Fitness",
                variant(31L, "SHIRT-WHITE-M", "M", "Trắng", "600000", 10)
        );
        Product blackShirt = product(
                22L,
                "Áo Thể Thao Đen",
                "Trang phục tập luyện",
                "Adidas",
                "Áo thể thao",
                "Gym & Fitness",
                variant(32L, "SHIRT-BLACK-M", "M", "Đen", "650000", 10)
        );
        Product pinkShoe = product(
                23L,
                "Giày Tập Màu Hồng",
                "Giày tập luyện",
                "Nike",
                "Giày thể thao",
                "Gym & Fitness",
                variant(33L, "SHOE-PINK-40", "40", "Hồng", "900000", 10)
        );
        Product blackShoe = product(
                24L,
                "Giày Tập Màu Đen",
                "Giày tập luyện",
                "Adidas",
                "Giày thể thao",
                "Gym & Fitness",
                variant(34L, "SHOE-BLACK-40", "40", "Đen", "950000", 10)
        );
        productCatalogClient.setProducts(List.of(whiteShirt, blackShirt, pinkShoe, blackShoe));

        ChatResponse clothing = chatBotService.generateResponse("Tìm áo trang phục tập luyện", List.of());
        ChatResponse broken = chatBotService.generateResponse("Tìm giày thay cho đôi bị hỏng", List.of());

        assertThat(clothing.getResponse())
                .contains("Áo Thể Thao Trắng")
                .contains("Áo Thể Thao Đen")
                .doesNotContain("theo màu trắng");
        assertThat(broken.getResponse())
                .contains("Giày Tập Màu Hồng")
                .contains("Giày Tập Màu Đen")
                .doesNotContain("theo màu hồng");
        server.verify();
    }

    @Test
    void supportsUnaccentedColorWhenTheUserExplicitlySaysMau() {
        Product whiteShoe = product(
                27L,
                "Giày Chạy Bộ Trắng",
                "Giày tập luyện",
                "Nike",
                "Giày chạy bộ",
                "Chạy bộ (Running)",
                variant(37L, "SHOE-WHITE-40", "40", "Trắng", "1200000", 10)
        );
        Product blackShoe = product(
                28L,
                "Giày Chạy Bộ Đen",
                "Giày tập luyện",
                "Adidas",
                "Giày chạy bộ",
                "Chạy bộ (Running)",
                variant(38L, "SHOE-BLACK-40", "40", "Đen", "1250000", 10)
        );
        productCatalogClient.setProducts(List.of(whiteShoe, blackShoe));

        ChatResponse response = chatBotService.generateResponse("Tim giay mau trang", List.of());

        assertThat(response.getResponse())
                .contains("Giày Chạy Bộ Trắng")
                .doesNotContain("Giày Chạy Bộ Đen")
                .contains("theo màu trắng");
        server.verify();
    }

    @Test
    void matchesEitherRequestedProductKindInsteadOfRequiringBoth() {
        Product shoe = product(
                25L,
                "Giày Thể Thao Nike",
                "Dùng tập luyện",
                "Nike",
                "Giày thể thao",
                "Gym & Fitness",
                variant(35L, "SHOE-40", "40", "Đen", "1000000", 10)
        );
        Product shirt = product(
                26L,
                "Áo Thể Thao Adidas",
                "Dùng tập luyện",
                "Adidas",
                "Áo thể thao",
                "Gym & Fitness",
                variant(36L, "SHIRT-M", "M", "Xanh", "700000", 10)
        );
        productCatalogClient.setProducts(List.of(shoe, shirt));

        ChatResponse response = chatBotService.generateResponse(
                "Tìm giày hoặc áo thể thao",
                List.of()
        );

        assertThat(response.getResponse())
                .contains("Giày Thể Thao Nike")
                .contains("Áo Thể Thao Adidas");
        server.verify();
    }

    @Test
    void handlesBroadSportsShirtSearchWithoutReturningShorts() {
        Product runningShirt = product(
                1L,
                "Áo Chạy Bộ Nam Nike Dri-FIT Miler",
                "Áo thể thao thoáng khí",
                "Nike",
                "Áo thể thao",
                "Chạy bộ (Running)",
                variant(3L, "NK-MILER-M", "M", "Trắng", "650000", 30)
        );
        Product trainingShorts = product(
                3L,
                "Quần Short Tập Gym Nam Adidas Aeroready",
                "Quần thể thao",
                "Adidas",
                "Quần short",
                "Gym & Fitness",
                variant(9L, "AD-SHORT-GRY-L", "L", "Xám", "550000", 40)
        );
        productCatalogClient.setProducts(List.of(trainingShorts, runningShirt));

        ChatResponse response = chatBotService.generateResponse("tìm áo thể thao", List.of());

        assertThat(response.getStatus()).isEqualTo("LOCAL");
        assertThat(response.getResponse())
                .contains("Áo Chạy Bộ Nam Nike Dri-FIT Miler")
                .doesNotContain("Quần Short Tập Gym Nam Adidas Aeroready");
        server.verify();
    }

    @Test
    void filtersAllShoesStrictlyAboveTwoMillionWithoutTreatingTatCaAsSocks() {
        productCatalogClient.setProducts(priceFilterShoes());

        ChatResponse response = chatBotService.generateResponse(
                "Tìm tất cả giày trên 2 triệu",
                List.of()
        );

        assertThat(response.getStatus()).isEqualTo("LOCAL");
        assertThat(response.getResponse())
                .contains("Giày Chạy Bộ Nike Air Zoom Pegasus 40")
                .contains("Giày Cầu Lông Yonex Power Cushion 65 Z3")
                .contains("Giày Bóng Rổ Under Armour Curry Flow 10")
                .contains("giá trên 2.000.000 VNĐ")
                .doesNotContain("Giày Bóng Đá Adidas Predator Accuracy.3 TF")
                .doesNotContain("Mình chưa tìm thấy sản phẩm đúng loại");
        server.verify();
    }

    @Test
    void newMinimumPriceReplacesTheMaximumPriceFromEarlierHistory() {
        productCatalogClient.setProducts(priceFilterShoes());

        ChatResponse response = chatBotService.generateResponse(
                "Tìm giày trên 2 triệu",
                List.of("CUSTOMER: Tìm giày dưới 2 triệu")
        );

        assertThat(response.getStatus()).isEqualTo("LOCAL");
        assertThat(response.getResponse())
                .contains("Giày Chạy Bộ Nike Air Zoom Pegasus 40")
                .contains("Giày Cầu Lông Yonex Power Cushion 65 Z3")
                .contains("Giày Bóng Rổ Under Armour Curry Flow 10")
                .doesNotContain("Giày Bóng Đá Adidas Predator Accuracy.3 TF")
                .doesNotContain("ngân sách tối đa 2.000.000 VNĐ");
        server.verify();
    }

    @Test
    void priceOnlyFollowUpKeepsThePreviouslyRequestedProductKind() {
        productCatalogClient.setProducts(priceFilterShoes());

        ChatResponse response = chatBotService.generateResponse(
                "trên 2 triệu",
                List.of("CUSTOMER: Tìm giày")
        );

        assertThat(response.getStatus()).isEqualTo("LOCAL");
        assertThat(response.getResponse())
                .contains("Giày Chạy Bộ Nike Air Zoom Pegasus 40")
                .contains("Giày Cầu Lông Yonex Power Cushion 65 Z3")
                .contains("Giày Bóng Rổ Under Armour Curry Flow 10")
                .doesNotContain("Giày Bóng Đá Adidas Predator Accuracy.3 TF");
        server.verify();
    }

    @Test
    void filtersShoesInsideAnInclusivePriceRange() {
        productCatalogClient.setProducts(priceFilterShoes());

        ChatResponse response = chatBotService.generateResponse(
                "Tìm giày từ 2 đến 3 triệu",
                List.of()
        );

        assertThat(response.getStatus()).isEqualTo("LOCAL");
        assertThat(response.getResponse())
                .contains("Giày Cầu Lông Yonex Power Cushion 65 Z3")
                .doesNotContain("Giày Chạy Bộ Nike Air Zoom Pegasus 40")
                .doesNotContain("Giày Bóng Rổ Under Armour Curry Flow 10")
                .doesNotContain("Giày Bóng Đá Adidas Predator Accuracy.3 TF");
        server.verify();
    }

    @Test
    void handlesRawBudgetLocallyWithoutPriceParsingError() {
        Product affordable = product(
                9L,
                "Băng Bảo Vệ Đầu Gối Nike Pro",
                "Bảo hộ tập luyện",
                "Nike",
                "Bảo hộ chấn thương",
                "Gym & Fitness",
                variant(24L, "NK-KNEE-BLK-FREE", "FreeSize", "Đen", "350000", 98)
        );
        Product overBudget = product(
                3L,
                "Quần Short Tập Gym Adidas Aeroready",
                "Quần tập gym",
                "Adidas",
                "Quần short",
                "Gym & Fitness",
                variant(9L, "AD-SHORT-BLK-M", "M", "Đen", "550000", 60)
        );
        productCatalogClient.setProducts(List.of(overBudget, affordable));

        ChatResponse response = chatBotService.generateResponse(
                "Gợi ý sản phẩm với ngân sách 500000",
                List.of()
        );

        assertThat(response.getStatus()).isEqualTo("LOCAL");
        assertThat(response.getResponse())
                .contains("Băng Bảo Vệ Đầu Gối Nike Pro")
                .doesNotContain("Quần Short Tập Gym Adidas Aeroready");
        server.verify();
    }

    @Test
    void handlesGreetingLocallyWithoutLoadingTheAiProvider() {
        ChatResponse response = chatBotService.generateResponse("Xin chào", List.of());

        assertThat(response.getStatus()).isEqualTo("LOCAL");
        assertThat(response.getResponse()).contains("không cần gọi AI");
        server.verify();
    }

    private Product product(Long id, String name, String description, String brandName,
                            String categoryName, String sportName, ProductVariant... variants) {
        Product product = Product.builder()
                .id(id)
                .productName(name)
                .description(description)
                .brand(Brand.builder().brandName(brandName).build())
                .category(new Category(null, categoryName, null, null, null, null))
                .sport(Sport.builder().sportName(sportName).build())
                .variants(new LinkedHashSet<>())
                .build();
        for (ProductVariant variant : variants) {
            variant.setProduct(product);
            product.getVariants().add(variant);
        }
        return product;
    }

    private ProductVariant variant(Long id, String sku, String size, String color,
                                   String price, int stock) {
        return ProductVariant.builder()
                .id(id)
                .sku(sku)
                .size(size)
                .color(color)
                .price(new BigDecimal(price))
                .stockQuantity(stock)
                .build();
    }

    private List<Product> priceFilterShoes() {
        return List.of(
                product(
                        4L,
                        "Giày Bóng Đá Adidas Predator Accuracy.3 TF",
                        "Giày đá bóng sân cỏ nhân tạo",
                        "Adidas",
                        "Giày bóng đá",
                        "Bóng đá",
                        variant(12L, "AD-PRED-40", "40", "Đỏ Đen", "1850000", 15)
                ),
                product(
                        2L,
                        "Giày Chạy Bộ Nike Air Zoom Pegasus 40",
                        "Giày chạy bộ đệm êm",
                        "Nike",
                        "Giày chạy bộ",
                        "Chạy bộ (Running)",
                        variant(5L, "NK-PEG-40", "40", "Đen Trắng", "3200000", 20)
                ),
                product(
                        6L,
                        "Giày Cầu Lông Yonex Power Cushion 65 Z3",
                        "Giày cầu lông chuyên nghiệp",
                        "Yonex",
                        "Giày cầu lông",
                        "Cầu lông",
                        variant(17L, "YX-65Z3-40", "40", "Trắng Vàng", "2950000", 14)
                ),
                product(
                        12L,
                        "Giày Bóng Rổ Under Armour Curry Flow 10",
                        "Giày bóng rổ hiệu năng cao",
                        "Under Armour",
                        "Giày bóng rổ",
                        "Bóng rổ",
                        variant(28L, "UA-CURRY-42", "42", "Xanh Dương", "3850000", 10)
                )
        );
    }

    private static final class StubProductCatalogClient extends ProductCatalogClient {
        private List<Product> products = List.of();
        private int requestCount;

        private StubProductCatalogClient() {
            super(new RestTemplate());
        }

        @Override
        public List<Product> getProducts() {
            requestCount++;
            return products;
        }

        private int getRequestCount() {
            return requestCount;
        }

        private void setProducts(List<Product> products) {
            this.products = products;
        }
    }
}
