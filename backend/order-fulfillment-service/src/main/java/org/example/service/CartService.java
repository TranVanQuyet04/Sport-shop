package org.example.service;

import org.example.dto.request.AddToCartRequest;
import org.example.dto.response.CartResponse;

public interface CartService {
    Long getCurrentUserId();
    CartResponse getMyCart();
    CartResponse addToCart(AddToCartRequest request);
    CartResponse updateItemQuantity(Long cartItemId, Integer quantity);
    CartResponse removeItem(Long cartItemId);
    void clearCart();
}
