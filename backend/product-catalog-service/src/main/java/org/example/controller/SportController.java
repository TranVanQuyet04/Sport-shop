package org.example.controller;

import org.example.dto.request.SportRequest;
import org.example.dto.response.SportResponse;
import org.example.service.SportService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping("/api/admin/sports")
@RequiredArgsConstructor
public class SportController {

    private final SportService sportService;

    // GET ALL
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<SportResponse>> getAll() {
        return ResponseEntity.ok(sportService.getAllSport());
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<SportResponse> create(@RequestBody SportRequest request) {
        return ResponseEntity.ok(sportService.createSport(request));
    }

    @GetMapping("/{sportId}")
    public ResponseEntity<SportResponse> getSportById(@PathVariable Long sportId) {
        return ResponseEntity.ok(sportService.getSportById(sportId));
    }

    // UPDATE
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<SportResponse> update(
            @PathVariable Long id,
            @RequestBody SportRequest request) {

        return ResponseEntity.ok(sportService.updateSport(id, request));
    }

    // DELETE
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        sportService.deleteSport(id);
        return ResponseEntity.noContent().build();
    }
}
