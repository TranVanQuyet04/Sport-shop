package com.team6.ecommercesystem.controller;

import com.team6.ecommercesystem.dto.request.SystemSettingRequest;
import com.team6.ecommercesystem.dto.response.SystemSettingResponse;
import com.team6.ecommercesystem.model.SystemSetting;
import com.team6.ecommercesystem.repository.SystemSettingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/settings")
@RequiredArgsConstructor
public class SystemSettingController {
    private final SystemSettingRepository settingRepository;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public List<SystemSettingResponse> getAll() {
        return settingRepository.findAll().stream().map(this::toResponse).toList();
    }

    @GetMapping("/{key}")
    @PreAuthorize("hasRole('ADMIN')")
    public SystemSettingResponse getOne(@PathVariable String key) {
        return toResponse(findSetting(key));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public SystemSettingResponse create(@RequestParam String key, @RequestBody SystemSettingRequest request) {
        if (settingRepository.existsById(key)) {
            throw new IllegalArgumentException("Setting already exists");
        }
        SystemSetting setting = SystemSetting.builder()
                .key(key)
                .value(request.getValue())
                .description(request.getDescription())
                .build();
        return toResponse(settingRepository.save(setting));
    }

    @PutMapping("/{key}")
    @PreAuthorize("hasRole('ADMIN')")
    public SystemSettingResponse upsert(@PathVariable String key, @RequestBody SystemSettingRequest request) {
        SystemSetting setting = settingRepository.findById(key)
                .orElseGet(() -> SystemSetting.builder().key(key).build());
        setting.setValue(request.getValue());
        setting.setDescription(request.getDescription());
        return toResponse(settingRepository.save(setting));
    }

    @DeleteMapping("/{key}")
    @PreAuthorize("hasRole('ADMIN')")
    public void delete(@PathVariable String key) {
        settingRepository.delete(findSetting(key));
    }

    private SystemSetting findSetting(String key) {
        return settingRepository.findById(key)
                .orElseThrow(() -> new IllegalArgumentException("Setting not found"));
    }

    private SystemSettingResponse toResponse(SystemSetting setting) {
        return SystemSettingResponse.builder()
                .key(setting.getKey())
                .value(setting.getValue())
                .description(setting.getDescription())
                .build();
    }
}
