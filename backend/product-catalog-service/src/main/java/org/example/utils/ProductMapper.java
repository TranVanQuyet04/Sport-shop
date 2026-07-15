package org.example.utils;

import org.example.dto.response.ProductDetailResponse;
import org.example.dto.response.ProductSummaryResponse;
import org.example.dto.response.VariantResponse;
import org.example.model.Product;
import org.example.model.ProductImage;
import org.example.model.ProductVariant;

import java.math.BigDecimal;
import java.util.stream.Collectors;

public class ProductMapper {
    public static VariantResponse toVariantDto(ProductVariant variant) {
        return VariantResponse.builder()
                .id(variant.getId())
                .sku(variant.getSku())
                .size(variant.getSize())
                .color(variant.getColor())
                .price(variant.getPrice())
                .stockQuantity(variant.getStockQuantity())
                .imageUrls(variant.getImages() != null ?
                        variant.getImages().stream()
                                .map(ProductImage::getImageUrl)
                                .collect(Collectors.toList())
                        : new java.util.ArrayList<>())
                .build();
    }

    public static ProductSummaryResponse toSummaryDto(Product product) {
        BigDecimal price = BigDecimal.ZERO;
        String imageUrl = null;

        if (!product.getVariants().isEmpty()) {

            ProductVariant variant = product.getVariants()
                    .stream()
                    .findFirst()
                    .orElse(null);

            price = variant.getPrice();

            if (variant.getImages() != null && !variant.getImages().isEmpty()) {
                imageUrl = variant.getImages()
                        .stream()
                        .findFirst()
                        .map(ProductImage::getImageUrl)
                        .orElse(null);
            }
        }

        return ProductSummaryResponse.builder()
                .id(product.getId())
                .productName(product.getProductName())
                .categoryName(product.getCategory().getCategoryName())
                .brandName(product.getBrand().getBrandName())
                .sportName(product.getSport().getSportName())
                .price(price)
                .image_url(imageUrl)
                .build();
    }

    public static ProductDetailResponse toDetailDto(Product product) {
        return ProductDetailResponse.builder()
                .id(product.getId())
                .productName(product.getProductName())
                .description(product.getDescription())
                .categoryName(product.getCategory().getCategoryName())
                .brandName(product.getBrand().getBrandName())
                .sportName(product.getSport().getSportName())
                .variants(product.getVariants().stream()
                        .map(ProductMapper::toVariantDto)
                        .collect(Collectors.toList()))
                .build();
    }
}
