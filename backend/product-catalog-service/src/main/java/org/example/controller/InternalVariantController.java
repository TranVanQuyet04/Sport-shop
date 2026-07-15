package org.example.controller;

import lombok.RequiredArgsConstructor;
import org.example.dto.response.InternalVariantResponse;
import org.example.model.ProductImage;
import org.example.model.ProductVariant;
import org.example.repository.ProductVariantRepository;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/internal/variants")
@RequiredArgsConstructor
public class InternalVariantController {
    private final ProductVariantRepository variantRepository;

    @GetMapping("/{id}")
    @Transactional(readOnly = true)
    public InternalVariantResponse getVariant(@PathVariable Long id) {
        return toResponse(findVariant(id));
    }

    @PostMapping("/{id}/reserve")
    @Transactional
    public InternalVariantResponse reserve(@PathVariable Long id, @RequestParam int quantity) {
        if (quantity <= 0) throw new IllegalArgumentException("Quantity must be positive");
        if (variantRepository.decrementStock(id, quantity) != 1) {
            throw new IllegalArgumentException("Insufficient stock");
        }
        return toResponse(findVariant(id));
    }

    private ProductVariant findVariant(Long id) {
        return variantRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Product variant not found"));
    }

    private InternalVariantResponse toResponse(ProductVariant variant) {
        String image = variant.getImages() == null ? "" : variant.getImages().stream()
                .findFirst().map(ProductImage::getImageUrl).orElse("");
        return new InternalVariantResponse(variant.getId(), variant.getSku(),
                variant.getProduct().getProductName(), variant.getColor(), variant.getSize(),
                variant.getPrice(), variant.getStockQuantity(), image);
    }
}
