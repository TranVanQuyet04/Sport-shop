package org.example.model;

import org.example.model.enums.OrderStatus;
import org.example.model.enums.PaymentMethod;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "orders")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    private LocalDateTime orderDate;

    @Enumerated(EnumType.STRING)
    private OrderStatus status;

    private BigDecimal totalAmount;

    @Enumerated(EnumType.STRING)
    private PaymentMethod paymentMethod;

    // --- SNAPSHOT Äá»ŠA CHá»ˆ (LÆ°u cá»©ng táº¡i thá»i Ä‘iá»ƒm mua) ---
    private String recipientName;
    private String phoneNumber;
    private String shippingAddress; // GhÃ©p full chuá»—i: Sá»‘ nhÃ , PhÆ°á»ng, Quáº­n, Tá»‰nh

    private String note; // Ghi chÃº cá»§a khÃ¡ch hÃ ng

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<OrderItem> orderItems = new ArrayList<>();
}
