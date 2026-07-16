package org.example.dto.response;

import org.example.model.enums.OrderStatus;
import org.example.model.enums.PaymentMethod;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
public class OrderResponse {
    private Long id;
    private LocalDateTime orderDate;
    private LocalDateTime deliveredAt;
    private LocalDateTime completedAt;
    private OrderStatus status;
    private String deliveryStatus;
    private BigDecimal totalAmount;
    private PaymentMethod paymentMethod;

    // Thông tin giao hàng snapshot
    private String recipientName;
    private String phoneNumber;
    private String shippingAddress;
    private String note;

    private List<OrderItemResponse> items;
}
