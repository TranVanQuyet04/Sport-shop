package org.example.service;

import org.example.dto.request.ProductRequest;
import org.example.dto.request.VariantRequest;
import org.example.dto.response.BrandResponse;
import org.example.dto.response.ProductDetailResponse;
import org.example.dto.response.ProductSummaryResponse;
import org.example.dto.response.VariantResponse;
import org.example.model.*;
import org.example.repository.*;
import org.example.utils.ProductMapper;
import org.example.utils.SkuGenerator;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.HashSet;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService{
    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final BrandRepository brandRepository;
    private final SportRepository sportRepository;
    private final ProductVariantRepository variantRepository;

    @Transactional
    @Override
    public ProductDetailResponse createProduct(ProductRequest request) {

        Long categoryId = categoryRepository.findIdByCategoryName(request.getCategoryName());
        Long brandId = brandRepository.findIdByBrandName(request.getBrandName());
        Long sportId = sportRepository.findIdBySportName(request.getSportName());

        Product product = Product.builder()
                .productName(request.getProductName())
                .description(request.getDescription())
                .category(
                        categoryRepository.findById(categoryId)
                                .orElseThrow(() ->
                                        new NoSuchElementException("Không tìm thấy Category với ID: " + categoryId)
                                )
                )
                .brand(
                        brandRepository.findById(brandId)
                                .orElseThrow(() ->
                                        new NoSuchElementException("Không tìm thấy Brand với ID: " + brandId)
                                )
                )
                .sport(
                        sportRepository.findById(sportId)
                                .orElseThrow(() ->
                                        new NoSuchElementException("Không tìm thấy Sport với ID: " + sportId)
                                )
                )
                .build();

        Set<ProductVariant> variants = request.getVariants().stream().map(vReq -> {

            String sku = (vReq.getSku() == null || vReq.getSku().isBlank())
                    ? SkuGenerator.generateSku(
                    product.getProductName(),
                    vReq.getColor(),
                    vReq.getSize())
                    : vReq.getSku();

            ProductVariant variant = ProductVariant.builder()
                    .sku(sku)
                    .size(vReq.getSize())
                    .color(vReq.getColor())
                    .price(vReq.getPrice())
                    .stockQuantity(vReq.getStockQuantity())
                    .product(product)
                    .build();

            if (vReq.getImageUrls() != null && !vReq.getImageUrls().isEmpty()) {

                Set<ProductImage> images = new HashSet<>();

                for (int i = 0; i < vReq.getImageUrls().size(); i++) {
                    images.add(
                            ProductImage.builder()
                                    .imageUrl(vReq.getImageUrls().get(i))
                                    .variant(variant)
                                    .isPrimary(i == 0)
                                    .build()
                    );
                }

                variant.setImages(images);
            }

            return variant;

        }).collect(Collectors.toSet());

        product.setVariants(variants);

        Product saved = productRepository.save(product);

        return ProductMapper.toDetailDto(saved);
    }

    @Transactional(readOnly = true)
    @Override
    public List<ProductSummaryResponse> getAllProducts() {
        return productRepository.findAll().stream().map(ProductMapper::toSummaryDto).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    @Override
    public ProductDetailResponse getProductDetail(Long id) {
        return ProductMapper.toDetailDto(productRepository.findById(id).orElseThrow());
    }

    @Transactional(readOnly = true)
    @Override
    public List<ProductDetailResponse> getChatCatalog() {
        return productRepository.findAllForChatBot().stream()
                .map(ProductMapper::toDetailDto)
                .toList();
    }

    @Transactional
    @Override
    public ProductSummaryResponse updateProduct(Long id, ProductRequest request) {

        Long categoryId = categoryRepository.findIdByCategoryName(request.getCategoryName());
        Long brandId = brandRepository.findIdByBrandName(request.getBrandName());
        Long sportId = sportRepository.findIdBySportName(request.getSportName());

        Product p = productRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Không tìm thấy product"));

        // ===== Update product info =====
        p.setProductName(request.getProductName());
        p.setDescription(request.getDescription());

        p.setCategory(categoryRepository.findById(categoryId)
                .orElseThrow(() -> new NoSuchElementException("Không tìm thấy Category")));

        p.setBrand(brandRepository.findById(brandId)
                .orElseThrow(() -> new NoSuchElementException("Không tìm thấy Brand")));

        p.setSport(sportRepository.findById(sportId)
                .orElseThrow(() -> new NoSuchElementException("Không tìm thấy Sport")));

        // ===== Update / Add variants =====
        if (request.getVariants() != null) {

            for (VariantRequest vReq : request.getVariants()) {

                ProductVariant variant;

                if (vReq.getId() != null) {

                    variant = variantRepository.findById(vReq.getId())
                            .orElseThrow(() -> new NoSuchElementException("Không tìm thấy variant"));

                    variant.setSize(vReq.getSize());
                    variant.setColor(vReq.getColor());
                    variant.setPrice(vReq.getPrice());
                    variant.setStockQuantity(vReq.getStockQuantity());

                }

                else {

                    String sku = (vReq.getSku() == null || vReq.getSku().isBlank())
                            ? SkuGenerator.generateSku(
                            p.getProductName(),
                            vReq.getColor(),
                            vReq.getSize())
                            : vReq.getSku();

                    variant = ProductVariant.builder()
                            .sku(sku)
                            .size(vReq.getSize())
                            .color(vReq.getColor())
                            .price(vReq.getPrice())
                            .stockQuantity(vReq.getStockQuantity())
                            .product(p)
                            .build();

                    p.getVariants().add(variant);
                }

                // ===== Images =====
                if (vReq.getImageUrls() != null) {

                    variant.getImages().clear();

                    Set<ProductImage> images = new HashSet<>();

                    for (int i = 0; i < vReq.getImageUrls().size(); i++) {

                        images.add(
                                ProductImage.builder()
                                        .imageUrl(vReq.getImageUrls().get(i))
                                        .variant(variant)
                                        .isPrimary(i == 0)
                                        .build()
                        );
                    }

                    variant.getImages().clear();
                    variant.getImages().addAll(images);
                }
            }
        }

        Product saved = productRepository.save(p);

        return ProductMapper.toSummaryDto(saved);
    }

    @Transactional
    @Override
    public void deleteProduct(Long id) {
        productRepository.deleteById(id);
    }

    @Transactional
    @Override
    public VariantResponse addVariant(Long productId, VariantRequest request) {

        Product p = productRepository.findById(productId)
                .orElseThrow(() -> new NoSuchElementException("Không tìm thấy product"));

        String sku = SkuGenerator.generateSku(
                p.getProductName(),
                request.getColor(),
                request.getSize()
        );

        ProductVariant variant = ProductVariant.builder()
                .sku(sku)
                .size(request.getSize())
                .color(request.getColor())
                .price(request.getPrice())
                .stockQuantity(request.getStockQuantity())
                .product(p)
                .build();

        if (request.getImageUrls() != null && !request.getImageUrls().isEmpty()) {

            Set<ProductImage> images = new HashSet<>();

            for (int i = 0; i < request.getImageUrls().size(); i++) {
                images.add(
                        ProductImage.builder()
                                .imageUrl(request.getImageUrls().get(i))
                                .variant(variant)
                                .isPrimary(i == 0)
                                .build()
                );
            }

            variant.setImages(images);
        }

        ProductVariant saved = variantRepository.save(variant);

        return ProductMapper.toVariantDto(saved);
    }

    @Transactional
    @Override
    public VariantResponse updateVariant(Long id, VariantRequest request) {
        ProductVariant v = variantRepository.findById(id).orElseThrow();
        v.setSize(request.getSize()); v.setColor(request.getColor());
        v.setPrice(request.getPrice()); v.setStockQuantity(request.getStockQuantity());
        if (request.getImageUrls() != null) {
            v.getImages().clear();
            v.getImages().addAll(request.getImageUrls().stream().map(url -> ProductImage.builder()
                    .imageUrl(url).variant(v).isPrimary(request.getImageUrls().indexOf(url) == 0).build()).collect(Collectors.toList()));
        }
        return ProductMapper.toVariantDto(variantRepository.save(v));
    }

    @Transactional
    @Override
    public void deleteVariant(Long id) {
        variantRepository.deleteById(id);
    }

    @Transactional
    @Override
    public void updateStock(Long variantId, Integer quantity) {
        ProductVariant v = variantRepository.findById(variantId).orElseThrow();
        v.setStockQuantity(quantity);
        variantRepository.save(v);
    }

    @Transactional(readOnly = true)
    @Override
    public List<ProductSummaryResponse> filterProducts(
            Long categoryId,
            Long brandId,
            Long sportId
    ) {

        List<Product> products = productRepository
                .filterProducts(categoryId, brandId, sportId);

        return products.stream()
                .map(ProductMapper::toSummaryDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    @Override
    public List<BrandResponse> getAllBrand(){
        List<Brand> brands = brandRepository.findAll();
        return brands.stream()
                .map(brand -> BrandResponse.builder()
                        .brandName(brand.getBrandName())
                        .brandBanner(brand.getBanner())
                        .slug(brand.getSlug())
                        .logo(brand.getLogo())
                        .isActive(brand.getIsActive())
                        .id(brand.getId())
                        .description(brand.getDescription())
                        .build())
                .toList();
    };
}
