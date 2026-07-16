package org.example.service;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.model.Brand;
import org.example.model.Category;
import org.example.model.Product;
import org.example.model.ProductVariant;
import org.example.model.Sport;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.RestClientException;

import java.math.BigDecimal;
import java.util.HashSet;
import java.util.List;

@Component
@RequiredArgsConstructor
@Slf4j
public class ProductCatalogClient {
    private final RestTemplate restTemplate;

    @Value("${services.product-catalog.url}")
    private String productCatalogUrl;

    public List<Product> getProducts() {
        String baseUrl = productCatalogUrl.replaceAll("/+$", "");

        try {
            List<ProductDetail> details = restTemplate.exchange(
                    baseUrl + "/api/products/chat-catalog",
                    HttpMethod.GET,
                    null,
                    new ParameterizedTypeReference<List<ProductDetail>>() { }
            ).getBody();
            if (details != null) {
                List<Product> products = details.stream()
                        .filter(detail -> detail != null)
                        .map(this::toProduct)
                        .toList();
                log.info("Loaded complete chat catalog: {} products, {} variants",
                        products.size(), countVariants(products));
                return products;
            }
        } catch (RestClientException bulkError) {
            log.warn("Complete chat catalog endpoint unavailable; using compatible detail lookup: {}",
                    bulkError.getMessage());
        }

        return getProductsFromDetailEndpoints(baseUrl);
    }

    private List<Product> getProductsFromDetailEndpoints(String baseUrl) {
        List<ProductSummary> summaries = restTemplate.exchange(
                baseUrl + "/api/products",
                HttpMethod.GET,
                null,
                new ParameterizedTypeReference<List<ProductSummary>>() { }
        ).getBody();

        if (summaries == null || summaries.isEmpty()) {
            return List.of();
        }

        List<Product> products = summaries.stream()
                .map(ProductSummary::getId)
                .map(id -> restTemplate.getForObject(
                        baseUrl + "/api/products/{id}", ProductDetail.class, id))
                .filter(detail -> detail != null)
                .map(this::toProduct)
                .toList();
        log.info("Loaded compatible chat catalog: {} products, {} variants",
                products.size(), countVariants(products));
        return products;
    }

    private int countVariants(List<Product> products) {
        return products.stream()
                .map(Product::getVariants)
                .filter(variants -> variants != null)
                .mapToInt(java.util.Collection::size)
                .sum();
    }

    private Product toProduct(ProductDetail detail) {
        Product product = Product.builder()
                .id(detail.getId())
                .productName(detail.getProductName())
                .description(detail.getDescription())
                .category(new Category(null, detail.getCategoryName(), null, null, null, null))
                .brand(Brand.builder().brandName(detail.getBrandName()).build())
                .sport(Sport.builder().sportName(detail.getSportName()).build())
                .variants(new HashSet<>())
                .build();

        if (detail.getVariants() != null) {
            detail.getVariants().stream().map(variant -> ProductVariant.builder()
                    .id(variant.getId())
                    .sku(variant.getSku())
                    .size(variant.getSize())
                    .color(variant.getColor())
                    .price(variant.getPrice())
                    .stockQuantity(variant.getStockQuantity())
                    .product(product)
                    .build()).forEach(product.getVariants()::add);
        }
        return product;
    }

    @Data
    public static class ProductSummary {
        private Long id;
    }

    @Data
    public static class ProductDetail {
        private Long id;
        private String productName;
        private String description;
        private String categoryName;
        private String brandName;
        private String sportName;
        private List<VariantDetail> variants;
    }

    @Data
    public static class VariantDetail {
        private Long id;
        private String sku;
        private String size;
        private String color;
        private BigDecimal price;
        private Integer stockQuantity;
    }
}
