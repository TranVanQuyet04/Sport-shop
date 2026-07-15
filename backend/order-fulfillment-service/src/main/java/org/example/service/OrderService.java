package org.example.service;

import org.example.dto.request.OrderCreationRequest;
import org.example.dto.response.OrderResponse;
import org.example.model.enums.OrderStatus;

import java.util.List;

public interface OrderService {
    Long getCurrentUserId();
    OrderResponse createOrder(OrderCreationRequest request);
    List<OrderResponse> getMyOrders();
    OrderResponse getMyOrder(Long orderId);
    OrderResponse updateOrderStatus(Long orderId, OrderStatus newStatus);
    List<OrderResponse> getAllOrders();
    OrderResponse getOrderForAdmin(Long orderId);
    OrderResponse userUpdateOrderStatus(Long orderId, OrderStatus status);
    void deleteOrderForAdmin(Long orderId);
}
