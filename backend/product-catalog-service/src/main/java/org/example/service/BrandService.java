package org.example.service;

import org.example.dto.request.CreateBrandDTO;
import org.example.dto.request.UpdateBrandDTO;
import org.example.model.Brand;
import org.example.repository.BrandRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BrandService {

    private final BrandRepository brandRepository;

    public List<Brand> getAll() {
        return brandRepository.findAll();
    }

    public Brand getById(Long id) {
        return brandRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Brand not found"));
    }

    public Brand create(CreateBrandDTO dto) {
        Brand brand = Brand.builder()
                .brandName(dto.getName())
                .slug(dto.getSlug())
                .logo(dto.getLogo())
                .description(dto.getDescription())
                .banner(dto.getBanner())
                .isActive(dto.getIsActive() != null ? dto.getIsActive() : true)
                .build();

        return brandRepository.save(brand);
    }

    public Brand update(Long id, UpdateBrandDTO dto) {
        Brand brand = brandRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Brand khÃ´ng tá»“n táº¡i"));

        if (dto.getName() != null) brand.setBrandName(dto.getName());
        if (dto.getSlug() != null) brand.setSlug(dto.getSlug());
        if (dto.getLogo() != null) brand.setLogo(dto.getLogo());
        if (dto.getDescription() != null) brand.setDescription(dto.getDescription());
        if (dto.getBanner() != null) brand.setBanner(dto.getBanner());
        if (dto.getIsActive() != null) brand.setIsActive(dto.getIsActive());

        return brandRepository.save(brand);
    }

    public void delete(Long id) {
        brandRepository.deleteById(id);
    }
}
