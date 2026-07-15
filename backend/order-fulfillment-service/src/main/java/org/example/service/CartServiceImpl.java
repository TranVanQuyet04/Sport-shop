package org.example.service;

import org.example.client.CatalogVariant;
import org.example.client.ProductCatalogClient;
import org.example.dto.request.AddToCartRequest;
import org.example.dto.response.CartResponse;
import org.example.model.Cart;
import org.example.model.CartItem;
import org.example.repository.CartRepository;
import org.example.utils.CartMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CartServiceImpl implements  CartService {
    private final CartRepository cartRepository;
    private final ProductCatalogClient productCatalogClient;

    @Override
    public Long getCurrentUserId() {
        try {
            String userIdStr = SecurityContextHolder.getContext().getAuthentication().getName();
            return Long.parseLong(userIdStr);
        } catch (NumberFormatException e) {
            throw new RuntimeException("Invalid User ID");
        }
    }

    @Override
    public CartResponse getMyCart() {
        Long userId = getCurrentUserId();
        Cart cart = cartRepository.findByUserId(userId)
                .orElseGet(() -> {
                    Cart newCart = Cart.builder().userId(userId).build();
                    return cartRepository.save(newCart);
                });
        return CartMapper.toResponse(cart);
    }

    @Override
    public CartResponse addToCart(AddToCartRequest request) {
        Long userId = getCurrentUserId();

        Cart cart = cartRepository.findByUserId(userId)
                .orElseGet(() -> cartRepository.save(Cart.builder().userId(userId).build()));

        CatalogVariant variant = productCatalogClient.getVariant(request.getVariantId());

        if (variant.stockQuantity() < request.getQuantity()) {
            throw new RuntimeException("Không đủ hàng trong kho. Chỉ còn: " + variant.stockQuantity());
        }

        Optional<CartItem> existingItem = cart.getItems().stream()
                .filter(item -> item.getVariantId().equals(variant.id()))
                .findFirst();

        if (existingItem.isPresent()) {
            // Cộng dồn số lượng
            CartItem item = existingItem.get();
            int newQty = item.getQuantity() + request.getQuantity();

            // Check tồn kho lần nữa cho tổng số lượng
            if (newQty > variant.stockQuantity()) {
                throw new RuntimeException("Tổng số lượng vượt quá tồn kho");
            }
            item.setQuantity(newQty);
            item.setAvailableStock(variant.stockQuantity());
            item.setUnitPrice(variant.price());
        } else {
            // Thêm mới
            CartItem newItem = CartItem.builder()
                    .cart(cart)
                    .variantId(variant.id())
                    .productName(variant.productName())
                    .size(variant.size())
                    .color(variant.color())
                    .unitPrice(variant.price())
                    .imageUrl(variant.imageUrl())
                    .availableStock(variant.stockQuantity())
                    .quantity(request.getQuantity())
                    .build();
            cart.getItems().add(newItem);
        }
        return CartMapper.toResponse(cartRepository.save(cart));
    }

    @Override
    public CartResponse updateItemQuantity(Long cartItemId, Integer quantity) {
        Long userId = getCurrentUserId();
        Cart cart = cartRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Cart not found"));

        CartItem item = cart.getItems().stream()
                .filter(i -> i.getId().equals(cartItemId))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Item not in cart"));

        // Validate tồn kho
        CatalogVariant variant = productCatalogClient.getVariant(item.getVariantId());
        if (quantity > variant.stockQuantity()) {
            throw new RuntimeException("Vượt quá số lượng tồn kho");
        }

        item.setQuantity(quantity);
        item.setAvailableStock(variant.stockQuantity());
        item.setUnitPrice(variant.price());
        return CartMapper.toResponse(cartRepository.save(cart));
    }

    @Override
    public CartResponse removeItem(Long cartItemId) {
        Long userId = getCurrentUserId();
        Cart cart = cartRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Cart not found"));

        cart.getItems().removeIf(item -> item.getId().equals(cartItemId));
        return CartMapper.toResponse(cartRepository.save(cart));
    }

    @Override
    public void clearCart() {
        Long userId = getCurrentUserId();
        Cart cart = cartRepository.findByUserId(userId).orElse(null);
        if (cart != null) {
            cart.getItems().clear();
            cartRepository.save(cart);
        }
    }
}
