package org.example.model.enums;

public enum OrderStatus {
    PENDING,    // Chờ xử lý/Chờ thanh toán
    CONFIRMED,  // Đã xác nhận
    PACKING,    // Đang đóng gói
    SHIPPED,    // Đã bàn giao cho giao hàng
    COMPLETED,  // Đơn hàng hoàn tất
    CANCELLED,  // Đã hủy

    // Legacy web/payment statuses kept for backward compatibility.
    PAID,       // Đã thanh toán (Chờ giao)
    SHIPPING,    // Đang giao hàng
    DELIVERED  // Giao thành công
}
