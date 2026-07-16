package org.example.utils;

import org.example.dto.response.OrderItemResponse;
import org.example.dto.response.OrderResponse;
import org.example.model.Order;
import org.example.model.OrderItem;

import java.math.BigDecimal;
import java.util.stream.Collectors;

public class OrderMapper {
    public static OrderResponse toResponse(Order order) {
        return OrderResponse.builder()
                .id(order.getId())
                .orderDate(order.getOrderDate())
                .deliveredAt(order.getDeliveredAt())
                .completedAt(order.getCompletedAt())
                .status(order.getStatus())
                .deliveryStatus(toDeliveryStatus(order))
                .totalAmount(order.getTotalAmount())
                .paymentMethod(order.getPaymentMethod())
                .recipientName(order.getRecipientName())
                .phoneNumber(order.getPhoneNumber())
                .shippingAddress(order.getShippingAddress())
                .note(order.getNote())
                .items(order.getOrderItems().stream().map(OrderMapper::toItemResponse).collect(Collectors.toList()))
                .build();
    }

    private static String toDeliveryStatus(Order order) {
        if (order.getStatus() == null) {
            return "WAITING_PICKUP";
        }
        return switch (order.getStatus()) {
            case PENDING, CONFIRMED, PACKING, PAID -> "WAITING_PICKUP";
            case SHIPPED, SHIPPING -> "OUT_FOR_DELIVERY";
            case DELIVERED, COMPLETED -> "DELIVERED";
            case CANCELLED -> "RETURNED";
        };
    }

    private static OrderItemResponse toItemResponse(OrderItem item) {
        return OrderItemResponse.builder()
                .id(item.getId())
                .variantId(item.getVariantId())
                .productName(item.getProductName())
                .size(item.getSize())
                .color(item.getColor())
                .price(item.getPrice()) // LÆ°u Ã½: Láº¥y giÃ¡ tá»« OrderItem (giÃ¡ lÃºc mua) chá»© khÃ´ng pháº£i giÃ¡ hiá»‡n táº¡i cá»§a Variant
                .quantity(item.getQuantity())
                .subTotal(item.getPrice().multiply(new BigDecimal(item.getQuantity())))
                .variantImage(item.getVariantImage())
                .build();
    }
}
