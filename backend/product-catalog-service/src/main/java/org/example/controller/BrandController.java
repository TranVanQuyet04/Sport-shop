package org.example.controller;


import org.example.dto.request.CreateBrandDTO;
import org.example.dto.request.UpdateBrandDTO;
import org.example.model.Brand;
import org.example.service.BrandService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/brands")
@RequiredArgsConstructor
public class BrandController {

    private final BrandService brandService;

    // GET ALL
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public Map<String, Object> getAll() {
        List<Brand> brands = brandService.getAll();

        Map<String, Object> response = new HashMap<>();
        Map<String, Object> data = new HashMap<>();

        data.put("brands", brands);
        data.put("count", brands.size());

        response.put("data", data);

        return response;
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Map<String, Object> getById(@PathVariable Long id) {
        Brand brand = brandService.getById(id);

        Map<String, Object> response = new HashMap<>();
        response.put("data", brand);

        return response;
    }

    // CREATE
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public Map<String, Object> create(@RequestBody CreateBrandDTO dto) {
        Brand brand = brandService.create(dto);

        Map<String, Object> response = new HashMap<>();
        response.put("data", brand);

        return response;
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Map<String, Object> update(
            @PathVariable Long id,
            @RequestBody UpdateBrandDTO dto
    ) {
        Brand brand = brandService.update(id, dto);

        Map<String, Object> response = new HashMap<>();
        response.put("data", brand);

        return response;
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Map<String, Object> delete(@PathVariable Long id) {
        brandService.delete(id);

        Map<String, Object> response = new HashMap<>();
        response.put("message", "XÃ³a thÃ nh cÃ´ng");

        return response;
    }
}
