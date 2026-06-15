package com.team6.ecommercesystem.service;

import com.team6.ecommercesystem.dto.request.CollectionRequest;
import com.team6.ecommercesystem.dto.response.CollectionResponse;

import java.util.List;

public interface CollectionService {
    CollectionResponse createCollection(CollectionRequest request);
    List<CollectionResponse> getAllCollections();
    CollectionResponse getCollectionById(Long id);
    CollectionResponse getCollectionBySlug(String slug);
    CollectionResponse updateCollection(Long id, CollectionRequest request);
    void deleteCollection(Long id);
}
