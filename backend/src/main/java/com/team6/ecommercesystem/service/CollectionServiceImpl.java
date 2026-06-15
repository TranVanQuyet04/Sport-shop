package com.team6.ecommercesystem.service;

import com.team6.ecommercesystem.dto.request.CollectionRequest;
import com.team6.ecommercesystem.dto.response.CollectionResponse;
import com.team6.ecommercesystem.model.Collection;
import com.team6.ecommercesystem.model.CollectionProduct;
import com.team6.ecommercesystem.model.ProductVariant;
import com.team6.ecommercesystem.repository.CollectionRepository;
import com.team6.ecommercesystem.repository.ProductVariantRepository;
import com.team6.ecommercesystem.utils.CollectionMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CollectionServiceImpl implements CollectionService {
    private final CollectionRepository collectionRepository;
    private final ProductVariantRepository variantRepository;

    @Override
    public CollectionResponse createCollection(CollectionRequest request) {
        Collection collection = Collection.builder()
                .name(request.getName()).slug(request.getSlug())
                .description(request.getDescription()).imageUrl(request.getImageUrl())
                .type(request.getType()).isActive(request.getIsActive())
                .startDate(request.getStartDate()).endDate(request.getEndDate())
                .collectionProducts(new ArrayList<>())
                .build();

        if (request.getVariantIds() != null) {
            collection.setCollectionProducts(buildCollectionProducts(collection, request.getVariantIds()));
        }

        return CollectionMapper.toResponse(collectionRepository.save(collection));    }

    @Override
    public List<CollectionResponse> getAllCollections() {
        return collectionRepository.findAll().stream()
                .map(CollectionMapper::toResponse).collect(Collectors.toList());
    }

    @Override
    public CollectionResponse getCollectionById(Long id) {
        Collection collection = collectionRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Collection not found"));
        return CollectionMapper.toResponse(collection);
    }

    @Override
    public CollectionResponse getCollectionBySlug(String slug) {
        Collection collection = collectionRepository.findBySlug(slug)
                .orElseThrow(() -> new NoSuchElementException("Not found product with slug: " + slug));

        return CollectionMapper.toResponse(collection);    }

    @Override
    public CollectionResponse updateCollection(Long id, CollectionRequest request) {
        Collection collection = collectionRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Collection not found"));
        if (request.getName() != null) collection.setName(request.getName());
        if (request.getSlug() != null) collection.setSlug(request.getSlug());
        if (request.getDescription() != null) collection.setDescription(request.getDescription());
        if (request.getImageUrl() != null) collection.setImageUrl(request.getImageUrl());
        if (request.getType() != null) collection.setType(request.getType());
        if (request.getIsActive() != null) collection.setIsActive(request.getIsActive());
        if (request.getStartDate() != null) collection.setStartDate(request.getStartDate());
        if (request.getEndDate() != null) collection.setEndDate(request.getEndDate());
        if (request.getVariantIds() != null) {
            if (collection.getCollectionProducts() == null) {
                collection.setCollectionProducts(new ArrayList<>());
            }
            collection.getCollectionProducts().clear();
            collection.getCollectionProducts().addAll(buildCollectionProducts(collection, request.getVariantIds()));
        }
        return CollectionMapper.toResponse(collectionRepository.save(collection));
    }

    @Override
    public void deleteCollection(Long id) {
        Collection collection = collectionRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Collection not found"));
        collectionRepository.delete(collection);
    }

    private List<CollectionProduct> buildCollectionProducts(Collection collection, List<Long> variantIds) {
        return variantIds.stream().map(vId -> {
            ProductVariant variant = variantRepository.findById(vId)
                    .orElseThrow(() -> new RuntimeException("Variant not found"));
            return CollectionProduct.builder()
                    .collection(collection).variant(variant).sortOrder(0).build();
        }).collect(Collectors.toList());
    }
}
