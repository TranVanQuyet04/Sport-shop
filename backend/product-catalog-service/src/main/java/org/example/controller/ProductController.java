package org.example.controller;

import org.example.dto.AIClassificationResult;
import org.example.dto.request.ProductRequest;
import org.example.dto.request.VariantRequest;
import org.example.dto.response.ProductDetailResponse;
import org.example.dto.response.ProductSummaryResponse;
import org.example.dto.response.VariantResponse;
import org.example.service.AIProductService;
import org.example.service.ProductServiceImpl;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/products")
@RequiredArgsConstructor
@Tag(name = "Product Management", description = "Products management endpoints")
public class ProductController {
    private final ProductServiceImpl productService;
    private final AIProductService aiProductService;

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ProductDetailResponse> create(@RequestBody ProductRequest req) {
        return ResponseEntity.ok(productService.createProduct(req));
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<ProductSummaryResponse>> getAll() {
        return ResponseEntity.ok(productService.getAllProducts());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ProductDetailResponse> getDetail(@PathVariable Long id) {
        return ResponseEntity.ok(productService.getProductDetail(id));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ProductSummaryResponse> update(@PathVariable Long id, @RequestBody ProductRequest req) {
        return ResponseEntity.ok(productService.updateProduct(id, req));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        productService.deleteProduct(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{productId}/variants")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<VariantResponse> addVariant(@PathVariable Long productId, @RequestBody VariantRequest req) {
        return ResponseEntity.ok(productService.addVariant(productId, req));
    }

    @PutMapping("/variants/{vId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<VariantResponse> updateVariant(@PathVariable Long vId, @RequestBody VariantRequest req) {
        return ResponseEntity.ok(productService.updateVariant(vId, req));
    }

    @DeleteMapping("/variants/{vId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteVariant(@PathVariable Long vId) {
        productService.deleteVariant(vId);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/variants/{vId}/stock")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> updateStock(@PathVariable Long vId, @RequestParam Integer quantity) {
        productService.updateStock(vId, quantity);
        return ResponseEntity.noContent().build();
    }

    // BÆ¯á»šC 1: Admin nháº¥n "AI Suggest" - Chá»‰ tráº£ vá» gá»£i Ã½, khÃ´ng lÆ°u
    @PostMapping("/ai-suggest")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AIClassificationResult> suggest(@RequestBody Map<String, String> payload) {
        return ResponseEntity.ok(aiProductService.classifyProduct(
                payload.get("productName"),
                payload.get("description")
        ));
    }

    // BÆ¯á»šC 2: Admin kiá»ƒm tra, sá»­a Ä‘á»•i rá»“i má»›i nháº¥n "Confirm" Ä‘á»ƒ lÆ°u
    @PostMapping("/admin-confirm")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ProductDetailResponse> confirm(@RequestBody ProductRequest req) {
        // req nÃ y chá»©a dá»¯ liá»‡u Admin Ä‘Ã£ chá»‘t (cÃ³ thá»ƒ khÃ¡c vá»›i AI gá»£i Ã½)
        return ResponseEntity.ok(productService.createProduct(req));
    }
}
