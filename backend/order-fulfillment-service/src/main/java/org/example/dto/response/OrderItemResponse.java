package org.example.dto.response;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Builder
public class OrderItemResponse {
    private Long id;            // ID cá»§a dÃ²ng trong Ä‘Æ¡n hÃ ng
    private Long variantId;     // ID cá»§a biáº¿n thá»ƒ (Ä‘á»ƒ FE dáº«n link vá» trang sáº£n pháº©m)
    private String productName;
    private String size;        // Quan trá»ng: Size lÃºc mua
    private String color;       // Quan trá»ng: MÃ u lÃºc mua
    private BigDecimal price;       // GiÃ¡ táº¡i thá»i Ä‘iá»ƒm mua
    private Integer quantity;
    private BigDecimal subTotal;    // ThÃ nh tiá»n (price * quantity)
    private String variantImage; // áº¢nh cá»§a biáº¿n thá»ƒ Ä‘Ã³
}
