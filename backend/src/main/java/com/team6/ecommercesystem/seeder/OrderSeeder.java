package com.team6.ecommercesystem.seeder;

import com.team6.ecommercesystem.model.*;
import com.team6.ecommercesystem.model.enums.OrderStatus;
import com.team6.ecommercesystem.model.enums.PaymentMethod;
import com.team6.ecommercesystem.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * Seeds realistic order + product demo data so that the Dashboard API
 * always returns non-zero numbers even on a fresh database.
 *
 * Strategy (idempotent):
 *  - If orders table already has rows → skip entirely.
 *  - Otherwise: ensure a demo product + variant exist, then insert
 *    30 orders spread across the last 30 days with a mix of statuses.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class OrderSeeder {

    private final OrderRepository       orderRepository;
    private final UserRepository        userRepository;
    private final RoleRepository        roleRepository;
    private final ProductRepository     productRepository;
    private final ProductVariantRepository productVariantRepository;
    private final CategoryRepository    categoryRepository;
    private final BrandRepository       brandRepository;
    private final PasswordEncoder       passwordEncoder;

    public void seed() {
        log.info("[OrderSeeder] Inserting demo daily data...");

        // ── 1. Ensure demo MEMBER users exist ─────────────────────────────
        Role memberRole = roleRepository.findByRoleCode("MEMBER")
                .orElseThrow(() -> new IllegalStateException("Role MEMBER not found"));

        List<User> customers = new ArrayList<>();
        String[] customerNames  = {"Nguyễn Văn An", "Trần Thị Bình", "Lê Minh Cường",
                                    "Phạm Thị Dung", "Hoàng Văn Em"};
        String[] customerEmails = {"demo.an@sport.vn", "demo.binh@sport.vn", "demo.cuong@sport.vn",
                                    "demo.dung@sport.vn", "demo.em@sport.vn"};
        for (int i = 0; i < customerNames.length; i++) {
            final String email    = customerEmails[i];
            final String name     = customerNames[i];
            final String phoneSfx = "090000000" + (i + 1);
            User u = userRepository.findByEmail(email).orElseGet(() ->
                    userRepository.save(User.builder()
                            .fullName(name)
                            .email(email)
                            .phoneNumber(phoneSfx)
                            .password(passwordEncoder.encode("Demo@1234"))
                            .status(true)
                            .role(memberRole)
                            .failedLoginAttempts(0)
                            .lastPasswordChangeDate(LocalDateTime.now())
                            .lastLoginDate(LocalDateTime.now())
                            .build()));
            customers.add(u);
        }

        // ── 2. Ensure a demo Category, Brand, Product + Variant exist ──────
        Category cat = categoryRepository.findAll().stream().findFirst()
                .orElseGet(() -> {
                    Category c = new Category();
                    c.setCategoryName("Demo Category");
                    return categoryRepository.save(c);
                });

        Brand brand = brandRepository.findAll().stream().findFirst()
                .orElseGet(() -> brandRepository.save(
                        Brand.builder()
                                .brandName("Demo Brand")
                                .slug("demo-brand")
                                .isActive(true)
                                .build()));

        Product product = productRepository.findAll().stream().findFirst()
                .orElseGet(() -> productRepository.save(
                        Product.builder()
                                .productName("Áo thể thao demo")
                                .description("Sản phẩm demo tự động được tạo bởi seeder.")
                                .category(cat)
                                .brand(brand)
                                .build()));

        ProductVariant variant = productVariantRepository.findAll().stream().findFirst()
                .orElseGet(() -> productVariantRepository.save(
                        ProductVariant.builder()
                                .sku("DEMO-001-M-WHITE")
                                .color("Trắng")
                                .size("M")
                                .price(BigDecimal.valueOf(299_000))
                                .stockQuantity(1000)
                                .product(product)
                                .build()));

        // ── 3. Insert 30 demo orders spread over the last 30 days ─────────
        Random rng = new Random(42L);
        OrderStatus[] statuses = {
                OrderStatus.COMPLETED, OrderStatus.COMPLETED, OrderStatus.COMPLETED,
                OrderStatus.COMPLETED, OrderStatus.COMPLETED, // 5/8 will be COMPLETED
                OrderStatus.PENDING,
                OrderStatus.CONFIRMED,
                OrderStatus.CANCELLED
        };

        LocalDateTime now = LocalDateTime.now();
        List<Order> orders = new ArrayList<>();

        for (int i = 0; i < 30; i++) {
            // Spread evenly over last 30 days with some intra-day randomness
            LocalDateTime orderDate = now
                    .minusDays(29 - (i % 30))
                    .minusHours(rng.nextInt(24))
                    .minusMinutes(rng.nextInt(60));

            User customer = customers.get(i % customers.size());
            OrderStatus status = statuses[rng.nextInt(statuses.length)];

            int qty = 1 + rng.nextInt(5);
            BigDecimal itemPrice = variant.getPrice();
            BigDecimal total = itemPrice.multiply(BigDecimal.valueOf(qty));

            Order order = Order.builder()
                    .user(customer)
                    .orderDate(orderDate)
                    .status(status)
                    .totalAmount(total)
                    .paymentMethod(rng.nextBoolean() ? PaymentMethod.COD : PaymentMethod.VNPAY)
                    .recipientName(customer.getFullName())
                    .phoneNumber(customer.getPhoneNumber())
                    .shippingAddress("123 Demo Street, Quận 1, TP. Hồ Chí Minh")
                    .note("")
                    .build();

            // Add order item
            OrderItem item = OrderItem.builder()
                    .order(order)
                    .variant(variant)
                    .quantity(qty)
                    .price(itemPrice)
                    .build();
            order.getOrderItems().add(item);

            orders.add(order);
        }

        orderRepository.saveAll(orders);
        log.info("[OrderSeeder] ✅ Inserted {} demo orders successfully.", orders.size());
    }
}
