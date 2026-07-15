package org.example.controller;

import lombok.RequiredArgsConstructor;
import org.example.dto.response.AddressResponse;
import org.example.dto.response.UserDetailResponse;
import org.example.repository.UserRepository;
import org.example.service.AddressService;
import org.example.service.UserService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/internal/users")
@RequiredArgsConstructor
public class InternalUserController {
    private final UserService userService;
    private final AddressService addressService;
    private final UserRepository userRepository;

    @GetMapping("/{id}")
    @PreAuthorize("#id.toString() == authentication.name or hasAnyRole('ADMIN','SHOP_STAFF')")
    public UserDetailResponse getUser(@PathVariable Long id) {
        return userService.getUserDetail(id);
    }

    @GetMapping("/me/addresses")
    public List<AddressResponse> getMyAddresses() {
        return addressService.getMyAddresses();
    }

    @GetMapping("/count")
    @PreAuthorize("hasRole('ADMIN')")
    public long countCreatedBetween(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime start,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime end) {
        return userRepository.countNewUsers(start, end);
    }
}
