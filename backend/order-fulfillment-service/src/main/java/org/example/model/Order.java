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

    private LocalDateTime deliveredAt;

    private LocalDateTime completedAt;

    @Enumerated(EnumType.STRING)
    private OrderStatus status;

    private BigDecimal totalAmount;

    @Enumerated(EnumType.STRING)
    private PaymentMethod paymentMethod;

    // --- SNAPSHOT ĐỊA CHỈ (Lưu cứng tại thời điểm mua) ---
    private String recipientName;
    private String phoneNumber;
    private String shippingAddress; // Ghép full chuỗi: Số nhà, Phường, Quận, Tỉnh

    private String note; // Ghi chú của khách hàng

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<OrderItem> orderItems = new ArrayList<>();
}
