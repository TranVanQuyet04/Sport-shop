package org.example.service;

import org.example.dto.request.CategoryRequest;
import org.example.dto.response.CategoryResponse;
import org.example.model.Category;
import org.example.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.NoSuchElementException;

@Service
@RequiredArgsConstructor
@Transactional
public class CategoryServiceImpl implements CategoryService {

    private final CategoryRepository categoryRepository;

    @Override
    public CategoryResponse create(CategoryRequest request) {

        Category parent = null;

        if (request.getParentId() != null) {
            parent = categoryRepository.findById(request.getParentId())
                    .orElseThrow(() -> new NoSuchElementException("KhÃ´ng tÃ¬m tháº¥y parent category"));
        }

        Category category = new Category();
        category.setCategoryName(request.getCategoryName());
        category.setDescription(request.getDescription());
        category.setParent(parent);

        return toResponse(categoryRepository.save(category));
    }

    @Override
    public CategoryResponse update(Long id, CategoryRequest request) {

        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("KhÃ´ng tÃ¬m tháº¥y category"));

        Category parent = null;
        if (request.getParentId() != null) {

            if (request.getParentId().equals(id)) {
                throw new RuntimeException("Category khÃ´ng thá»ƒ lÃ  parent cá»§a chÃ­nh nÃ³");
            }

            parent = categoryRepository.findById(request.getParentId())
                    .orElseThrow(() -> new NoSuchElementException("KhÃ´ng tÃ¬m tháº¥y parent category"));
        }

        category.setCategoryName(request.getCategoryName());
        category.setDescription(request.getDescription());
        category.setParent(parent);

        return toResponse(categoryRepository.save(category));
    }

    @Override
    @Transactional(readOnly = true)
    public CategoryResponse getById(Long id) {

        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("KhÃ´ng tÃ¬m tháº¥y category"));

        return toResponse(category);
    }

    @Override
    public void delete(Long id) {

        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("KhÃ´ng tÃ¬m tháº¥y category"));

        if (category.getChildren() != null && !category.getChildren().isEmpty()) {
            throw new RuntimeException("KhÃ´ng thá»ƒ xoÃ¡ category Ä‘ang cÃ³ category con");
        }

        if (category.getProducts() != null && !category.getProducts().isEmpty()) {
            throw new RuntimeException("KhÃ´ng thá»ƒ xoÃ¡ category Ä‘ang Ä‘Æ°á»£c product sá»­ dá»¥ng");
        }

        categoryRepository.delete(category);
    }

    @Override
    @Transactional(readOnly = true)
    public List<CategoryResponse> getAll() {
        return categoryRepository.findAll()
                .stream()
                .map(this::toResponse)
                .toList();
    }

    private CategoryResponse toResponse(Category category) {
        return CategoryResponse.builder()
                .id(category.getId())
                .categoryName(category.getCategoryName())
                .description(category.getDescription())
                .parentId(category.getParent() != null ? category.getParent().getId() : null)
                .build();
    }
}
