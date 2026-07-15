package org.example.controller;

import org.example.dto.response.BrandResponse;
import org.example.dto.response.CategoryResponse;
import org.example.dto.response.ProductDetailResponse;
import org.example.dto.response.ProductSummaryResponse;
import org.example.service.CategoryService;
import org.example.service.ProductService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
@Tag(name = "Public Product", description = "Public APIs for viewing products (Customers & Guests)")
public class PublicProductController {

    private final ProductService productService;
    private final CategoryService categoryService;

    @GetMapping
    @Operation(
            summary = "Get products",
            description = "Láº¥y danh sÃ¡ch sáº£n pháº©m, cÃ³ thá»ƒ filter theo categoryId, brandId, sportId"
    )
    public ResponseEntity<List<ProductSummaryResponse>> getProducts(
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) Long brandId,
            @RequestParam(required = false) Long sportId
    ) {
        return ResponseEntity.ok(
                productService.filterProducts(categoryId, brandId, sportId)
        );
    }

    @GetMapping("/{id}")
    @Operation(
            summary = "Get product detail",
            description = "Xem chi tiáº¿t má»™t sáº£n pháº©m kÃ¨m cÃ¡c biáº¿n thá»ƒ (size, mÃ u)"
    )
    public ResponseEntity<ProductDetailResponse> getProductDetail(@PathVariable Long id) {
        return ResponseEntity.ok(productService.getProductDetail(id));
    }

    @GetMapping("/brands")
    @Operation(
            summary = "Get brand",
            description = "Láº¥y danh sÃ¡ch cÃ¡c nhÃ£n hÃ ng"
    )
    public ResponseEntity<List<BrandResponse>> getBrand(){
        return ResponseEntity.ok(productService.getAllBrand());
    }

    @GetMapping("/categories")
    @Operation(
            summary = "Get categories",
            description = "Lay danh sach danh muc san pham"
    )
    public ResponseEntity<List<CategoryResponse>> getCategories() {
        return ResponseEntity.ok(categoryService.getAll());
    }
}
