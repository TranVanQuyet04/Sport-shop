package org.example.utils;

import org.example.dto.response.CollectionResponse;
import org.example.model.Collection;
import org.example.model.CollectionProduct;

import java.util.List;
import java.util.stream.Collectors;

public class CollectionMapper {
    public static CollectionResponse toResponse(Collection collection) {
        return CollectionResponse.builder()
                .id(collection.getId())
                .name(collection.getName())
                .slug(collection.getSlug())
                .description(collection.getDescription())
                .imageUrl(collection.getImageUrl())
                .type(collection.getType())
                .isActive(collection.getIsActive())
                .startDate(collection.getStartDate())
                .endDate(collection.getEndDate())
                .variants((collection.getCollectionProducts() == null ? List.<CollectionProduct>of() : collection.getCollectionProducts()).stream()
                        .map(cp -> ProductMapper.toVariantDto(cp.getVariant()))
                        .collect(Collectors.toList()))
                .build();
    }
}
