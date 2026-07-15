package org.example.controller;

import org.example.dto.request.OrderCreationRequest;
import org.example.dto.response.OrderResponse;
import org.example.model.enums.OrderStatus;
import org.example.service.OrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
@Tag(name = "Order Management", description = "Checkout and Order History")
public class OrderController {
    private final OrderService orderService;

    @PostMapping("/checkout")
    @Operation(summary = "Place an order (Checkout)", description = "Create order from current cart")
    public ResponseEntity<OrderResponse> placeOrder(@Valid @RequestBody OrderCreationRequest request) {
        return ResponseEntity.ok(orderService.createOrder(request));
    }

    @GetMapping
    @Operation(summary = "Get my order history")
    public ResponseEntity<List<OrderResponse>> getMyOrders() {
        return ResponseEntity.ok(orderService.getMyOrders());
    }

    @GetMapping("/my-orders")
    @Operation(summary = "Get my order history alias", description = "Mobile-compatible alias for my orders")
    public ResponseEntity<List<OrderResponse>> getMyOrdersAlias() {
        return getMyOrders();
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get my order detail")
    public ResponseEntity<OrderResponse> getMyOrder(@PathVariable Long id) {
        return ResponseEntity.ok(orderService.getMyOrder(id));
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SHOP_STAFF') or hasRole('SHIPPER')")
    @Operation(summary = "Update order status", description = "Shipper/Admin update order status")
    public ResponseEntity<OrderResponse> updateOrderStatus(
            @PathVariable Long id,
            @RequestParam OrderStatus status) {
        return ResponseEntity.ok(orderService.updateOrderStatus(id, status));
    }

    @GetMapping("/admin")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SHOP_STAFF') or hasRole('SHIPPER')")
    @Operation(summary = "Get all order history")
    public ResponseEntity<List<OrderResponse>> getAllOrders() {
        return ResponseEntity.ok(orderService.getAllOrders());
    }

    @GetMapping("/admin/{id}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SHOP_STAFF') or hasRole('SHIPPER')")
    @Operation(summary = "Get order detail for staff")
    public ResponseEntity<OrderResponse> getOrderForAdmin(@PathVariable Long id) {
        return ResponseEntity.ok(orderService.getOrderForAdmin(id));
    }

    @DeleteMapping("/admin/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete pending/cancelled order for admin")
    public ResponseEntity<Void> deleteOrderForAdmin(@PathVariable Long id) {
        orderService.deleteOrderForAdmin(id);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/orderStatus")
    @Operation(summary = "Update my status order")
    public ResponseEntity<OrderResponse> userUpdateOrderStatus(@PathVariable Long id, @RequestParam OrderStatus status){
        return ResponseEntity.ok(orderService.userUpdateOrderStatus(id, status));
    }
}
