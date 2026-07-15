package org.example.controller;

import org.example.dto.request.AddressRequest;
import org.example.dto.response.AddressResponse;
import org.example.service.AddressService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/user/addresses")
@RequiredArgsConstructor
@Tag(name = "User Address", description = "Manage delivery addresses")
public class AddressController {
    private final AddressService addressService;

    @GetMapping
    @Operation(summary = "Get my addresses")
    public ResponseEntity<List<AddressResponse>> getMyAddresses() {
        return ResponseEntity.ok(addressService.getMyAddresses());
    }

    @PostMapping
    @Operation(summary = "Create new address")
    public ResponseEntity<AddressResponse> createAddress(@Valid @RequestBody AddressRequest request) {
        return ResponseEntity.ok(addressService.createAddress(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update address")
    public ResponseEntity<AddressResponse> updateAddress(@PathVariable Long id, @Valid @RequestBody AddressRequest request) {
        return ResponseEntity.ok(addressService.updateAddress(id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete address")
    public ResponseEntity<Void> deleteAddress(@PathVariable Long id) {
        addressService.deleteAddress(id);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/default")
    @Operation(summary = "Set default address")
    public ResponseEntity<Void> setDefault(@PathVariable Long id) {
        addressService.setDefault(id);
        return ResponseEntity.ok().build();
    }
}
