package org.example.service;

import org.example.client.AuthAddress;
import org.example.client.AuthServiceClient;
import org.example.client.AuthUser;
import org.example.client.CatalogVariant;
import org.example.client.ProductCatalogClient;
import org.example.dto.request.OrderCreationRequest;
import org.example.dto.response.OrderResponse;
import org.example.model.*;
import org.example.model.enums.OrderStatus;
import org.example.repository.*;
import org.example.utils.OrderMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class OrderServiceImpl implements  OrderService {
    private final OrderRepository orderRepository;
    private final CartRepository cartRepository;
    private final ProductCatalogClient productCatalogClient;
    private final AuthServiceClient authServiceClient;
    private final OrderAssignmentRepository assignmentRepository;
    private final DeliveryReportRepository deliveryReportRepository;

    @Override
    public Long getCurrentUserId() {
        try {
            String userIdStr = SecurityContextHolder.getContext().getAuthentication().getName();
            return Long.parseLong(userIdStr);
        } catch (NumberFormatException e) {
            throw new RuntimeException("Invalid User ID");
        }    }

    @Override
    public OrderResponse createOrder(OrderCreationRequest request) {
        Long userId = getCurrentUserId();

        // 1. Láº¥y giá» hÃ ng
        Cart cart = cartRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Giá» hÃ ng trá»‘ng"));

        if (cart.getItems().isEmpty()) {
            throw new RuntimeException("Giá» hÃ ng khÃ´ng cÃ³ sáº£n pháº©m nÃ o Ä‘á»ƒ thanh toÃ¡n");
        }

        // 2. Láº¥y Ä‘á»‹a chá»‰ giao hÃ ng (Validate xem cÃ³ pháº£i cá»§a user nÃ y khÃ´ng)
        AuthAddress address = authServiceClient.getMyAddress(request.getAddressId());
        if (address == null) throw new RuntimeException("Äá»‹a chá»‰ giao hÃ ng khÃ´ng há»£p lá»‡");

        // 3. Khá»Ÿi táº¡o Order
        Order order = Order.builder()
                .userId(userId)
                .orderDate(LocalDateTime.now())
                .status(OrderStatus.PENDING) // Máº·c Ä‘á»‹nh lÃ  Chá» xá»­ lÃ½
                .paymentMethod(request.getPaymentMethod())
                .note(request.getNote())
                .recipientName(address.recipientName())
                .phoneNumber(address.phoneNumber())
                // Snapshot Ä‘á»‹a chá»‰ full text
                .shippingAddress(String.format("%s, %s, %s, %s",
                        address.street(), address.ward(), address.district(), address.city()))
                .build();

        // 4. Xá»­ lÃ½ tá»«ng Item: Check kho -> Trá»« kho -> Táº¡o OrderItem
        List<OrderItem> orderItems = new ArrayList<>();
        BigDecimal totalAmount = BigDecimal.ZERO;

        for (CartItem cartItem : cart.getItems()) {
            CatalogVariant variant = productCatalogClient.getVariant(cartItem.getVariantId());

            // Check tá»“n kho (Concurrency check cÆ¡ báº£n)
            if (variant.stockQuantity() < cartItem.getQuantity()) {
                throw new RuntimeException("Sản phẩm " + variant.productName() + " không đủ số lượng tồn kho.");
            }

            // Trá»« kho
            productCatalogClient.reserve(variant.id(), cartItem.getQuantity());

            // Táº¡o OrderItem
            OrderItem orderItem = OrderItem.builder()
                    .order(order)
                    .variantId(variant.id())
                    .productName(variant.productName())
                    .size(variant.size())
                    .color(variant.color())
                    .variantImage(variant.imageUrl())
                    .quantity(cartItem.getQuantity())
                    .price(variant.price()) // Snapshot giá tại thời điểm mua
                    .build();

            orderItems.add(orderItem);

            // TÃ­nh: subTotal = price * quantity
            BigDecimal subTotal = orderItem.getPrice().multiply(new BigDecimal(orderItem.getQuantity()));
            // TÃ­nh: totalAmount = totalAmount + subTotal
            totalAmount = totalAmount.add(subTotal);        }

        // 5. HoÃ n táº¥t Order
        order.setOrderItems(orderItems);
        order.setTotalAmount(totalAmount);
        Order savedOrder = orderRepository.save(order);

        // 6. XÃ³a sáº¡ch giá» hÃ ng sau khi Ä‘áº·t thÃ nh cÃ´ng
        cart.getItems().clear();
        cartRepository.save(cart);

        return OrderMapper.toResponse(savedOrder);
    }

    @Override
    public List<OrderResponse> getMyOrders() {
        Long userId = getCurrentUserId();
        return orderRepository.findByUserIdOrderByOrderDateDesc(userId).stream()
                .map(OrderMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public OrderResponse getMyOrder(Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        Long userId = getCurrentUserId();
        if (!order.getUserId().equals(userId)) {
            throw new RuntimeException("Order not found");
        }
        return OrderMapper.toResponse(order);
    }

    @Override
    public List<OrderResponse> getAllOrders() {
        return orderRepository.findAll()
                .stream()
                .map(OrderMapper::toResponse)
                .toList();
    }

    @Override
    public OrderResponse getOrderForAdmin(Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        return OrderMapper.toResponse(order);
    }

    @Override
    public OrderResponse updateOrderStatus(Long orderId, OrderStatus newStatus) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        AuthUser currentUser = authServiceClient.getUser(getCurrentUserId());
        String roleCode = currentUser.effectiveRole();
        OrderStatus currentStatus = order.getStatus();

        if (roleCode.equals("SHOP_STAFF")) {
            validateShopStaffTransition(currentStatus, newStatus);
        } else if (roleCode.equals("SHIPPER")) {
            validateShipperTransition(currentStatus, newStatus);
        } else if (!roleCode.equals("ADMIN")) {
            throw new RuntimeException("Ban khong co quyen cap nhat trang thai don hang");
        }

        order.setStatus(newStatus);
        applyStatusTimestamp(order, newStatus);
        return OrderMapper.toResponse(orderRepository.save(order));
    }

    @Override
    public OrderResponse userUpdateOrderStatus(Long orderId, OrderStatus status) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Khong tim thay don hang"));

        Long currentUserId = getCurrentUserId();
        OrderStatus currentStatus = order.getStatus();

        if (!order.getUserId().equals(currentUserId)) {
            throw new RuntimeException("Ban khong co quyen cap nhat don hang nay");
        }

        if (status == OrderStatus.CANCELLED && currentStatus == OrderStatus.PENDING) {
            order.setStatus(status);
        } else if (status == OrderStatus.COMPLETED && currentStatus == OrderStatus.DELIVERED) {
            order.setStatus(status);
            applyStatusTimestamp(order, status);
        } else {
            throw new RuntimeException("Trang thai cap nhat khong hop le");
        }

        return OrderMapper.toResponse(orderRepository.save(order));
    }

    @Override
    public void deleteOrderForAdmin(Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        if (order.getStatus() != OrderStatus.PENDING && order.getStatus() != OrderStatus.CANCELLED) {
            throw new IllegalArgumentException("Only pending or cancelled orders can be deleted");
        }
        assignmentRepository.findByOrderId(orderId).ifPresent(assignmentRepository::delete);
        deliveryReportRepository.findByOrderIdOrderByCreatedAtDesc(orderId).forEach(deliveryReportRepository::delete);
        orderRepository.delete(order);
    }

    private void validateShopStaffTransition(OrderStatus currentStatus, OrderStatus newStatus) {
        boolean valid =
                (currentStatus == OrderStatus.PENDING && newStatus == OrderStatus.CONFIRMED)
                || (currentStatus == OrderStatus.CONFIRMED && newStatus == OrderStatus.PACKING)
                || (currentStatus == OrderStatus.PACKING && newStatus == OrderStatus.SHIPPED);

        if (!valid) {
            throw new IllegalArgumentException("Shop staff khong duoc chuyen trang thai tu " + currentStatus + " sang " + newStatus);
        }
    }

    private void applyStatusTimestamp(Order order, OrderStatus status) {
        LocalDateTime now = LocalDateTime.now();
        if (status == OrderStatus.DELIVERED && order.getDeliveredAt() == null) {
            order.setDeliveredAt(now);
        }
        if (status == OrderStatus.COMPLETED && order.getCompletedAt() == null) {
            order.setCompletedAt(now);
        }
    }

    private void validateShipperTransition(OrderStatus currentStatus, OrderStatus newStatus) {
        boolean valid = currentStatus == OrderStatus.SHIPPED
                && (newStatus == OrderStatus.DELIVERED || newStatus == OrderStatus.CANCELLED);

        if (!valid) {
            throw new IllegalArgumentException("Shipper khong duoc chuyen trang thai tu " + currentStatus + " sang " + newStatus);
        }
    }

}
