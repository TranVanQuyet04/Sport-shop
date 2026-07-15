package org.example.service;

import org.example.dto.response.NavigationCategoryDTO;
import org.example.model.Category;
import org.example.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NavigationService {

    private final CategoryRepository categoryRepository;

    public List<NavigationCategoryDTO> getMainNavigation() {
        List<Category> rootCategories = categoryRepository.findByParentIsNull();

        return rootCategories.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    private NavigationCategoryDTO convertToDTO(Category category) {
        return new NavigationCategoryDTO(
                category.getId(),
                category.getCategoryName(),
                category.getChildren() != null
                        ? category.getChildren()
                        .stream()
                        .map(this::convertToDTO)
                        .collect(Collectors.toList())
                        : List.of()
        );
    }
}
