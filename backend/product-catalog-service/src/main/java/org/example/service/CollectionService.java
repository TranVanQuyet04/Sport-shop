package org.example.service;

import org.example.dto.request.CollectionRequest;
import org.example.dto.response.CollectionResponse;

import java.util.List;

public interface CollectionService {
    CollectionResponse createCollection(CollectionRequest request);
    List<CollectionResponse> getAllCollections();
    CollectionResponse getCollectionById(Long id);
    CollectionResponse getCollectionBySlug(String slug);
    CollectionResponse updateCollection(Long id, CollectionRequest request);
    void deleteCollection(Long id);
}
