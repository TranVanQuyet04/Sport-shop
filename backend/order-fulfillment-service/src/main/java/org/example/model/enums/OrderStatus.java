package org.example.model.enums;

public enum OrderStatus {
    PENDING,    // Chá» xá»­ lÃ½/Chá» thanh toÃ¡n
    CONFIRMED,  // ÄÃ£ xÃ¡c nháº­n
    PACKING,    // Äang Ä‘Ã³ng gÃ³i
    SHIPPED,    // ÄÃ£ bÃ n giao cho giao hÃ ng
    COMPLETED,  // ÄÆ¡n hÃ ng hoÃ n táº¥t
    CANCELLED,  // ÄÃ£ há»§y

    // Legacy web/payment statuses kept for backward compatibility.
    PAID,       // ÄÃ£ thanh toÃ¡n (Chá» giao)
    SHIPPING,    // Äang giao hÃ ng
    DELIVERED  // Giao thÃ nh cÃ´ng
}
