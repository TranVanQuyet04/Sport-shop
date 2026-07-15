package org.example.controller;

import org.example.dto.request.CategoryRequest;
import org.example.dto.response.CategoryResponse;
import org.example.service.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/categories")
@RequiredArgsConstructor
public class CategoryController {

    private final CategoryService categoryService;

    // GET ALL
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public List<CategoryResponse> getAll() {
        return categoryService.getAll();
    }

    // GET BY ID
    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public CategoryResponse getById(@PathVariable Long id) {
        return categoryService.getById(id);
    }

    // CREATE
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public CategoryResponse create(@RequestBody CategoryRequest request) {
        return categoryService.create(request);
    }

    // UPDATE
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public CategoryResponse update(
            @PathVariable Long id,
            @RequestBody CategoryRequest request) {
        return categoryService.update(id, request);
    }

    // DELETE
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public void delete(@PathVariable Long id) {
        categoryService.delete(id);
    }
}
