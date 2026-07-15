package org.example.client;

import java.math.BigDecimal;

public record CatalogVariant(Long id, String sku, String productName, String color, String size,
                             BigDecimal price, Integer stockQuantity, String imageUrl) {
}
