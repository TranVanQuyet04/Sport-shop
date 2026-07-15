package org.example.utils;

import org.example.dto.response.CartItemResponse;
import org.example.dto.response.CartResponse;
import org.example.model.Cart;
import org.example.model.CartItem;

import java.math.BigDecimal;
import java.util.stream.Collectors;

public class CartMapper {
    public static CartResponse toResponse(Cart cart) {
        return CartResponse.builder()
                .id(cart.getId())
                .totalPrice(cart.getTotalPrice())
                .totalItems(cart.getItems().stream().mapToInt(CartItem::getQuantity).sum())
                .items(cart.getItems().stream().map(CartMapper::toItemResponse).collect(Collectors.toList()))
                .build();
    }

    private static CartItemResponse toItemResponse(CartItem item) {
        return CartItemResponse.builder()
                .id(item.getId())
                .variantId(item.getVariantId())
                .productName(item.getProductName())
                .size(item.getSize())
                .color(item.getColor())
                .price(item.getUnitPrice())
                .quantity(item.getQuantity())
                .subTotal(item.getUnitPrice().multiply(new BigDecimal(item.getQuantity())))
                .imageUrl(item.getImageUrl())
                .maxStock(item.getAvailableStock())
                .build();
    }
}
