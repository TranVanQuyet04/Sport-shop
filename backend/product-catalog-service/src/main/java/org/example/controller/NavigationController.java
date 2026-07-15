package org.example.controller;

import org.example.dto.response.NavigationCategoryDTO;
import org.example.service.NavigationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/navigation")
@RequiredArgsConstructor
public class NavigationController {

    private final NavigationService navigationService;

    @GetMapping("/main")
    public List<NavigationCategoryDTO> getMainNavigation() {
        return navigationService.getMainNavigation();
    }
}
