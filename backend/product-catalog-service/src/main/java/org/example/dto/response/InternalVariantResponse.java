package org.example.dto.response;

import java.math.BigDecimal;

public record InternalVariantResponse(Long id, String sku, String productName, String color,
                                      String size, BigDecimal price, Integer stockQuantity,
                                      String imageUrl) {
}
