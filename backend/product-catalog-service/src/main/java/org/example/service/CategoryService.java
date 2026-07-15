package org.example.service;

import org.example.dto.request.CategoryRequest;
import org.example.dto.response.CategoryResponse;

import java.util.List;

public interface CategoryService {

    CategoryResponse create(CategoryRequest request);

    CategoryResponse update(Long id, CategoryRequest request);

    CategoryResponse getById(Long id);

    void delete(Long id);

    List<CategoryResponse> getAll();
}
