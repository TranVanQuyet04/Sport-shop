package org.example.service;

import org.example.dto.request.ProductRequest;
import org.example.dto.request.VariantRequest;
import org.example.dto.response.BrandResponse;
import org.example.dto.response.ProductDetailResponse;
import org.example.dto.response.ProductSummaryResponse;
import org.example.dto.response.VariantResponse;
import org.example.model.ProductVariant;

import java.util.List;

public interface ProductService {
    public ProductDetailResponse createProduct(ProductRequest request);
    public List<ProductSummaryResponse> getAllProducts();
    public ProductDetailResponse getProductDetail(Long id);
    public ProductSummaryResponse updateProduct(Long id, ProductRequest request);
    public void deleteProduct(Long id);

    public VariantResponse addVariant(Long productId, VariantRequest request);
    public VariantResponse updateVariant(Long id, VariantRequest request);
    public void deleteVariant(Long id);
    public void updateStock(Long variantId, Integer quantity);
    List<ProductSummaryResponse> filterProducts(
            Long categoryId,
            Long brandId,
            Long sportId
    );
    List<BrandResponse> getAllBrand();
}
