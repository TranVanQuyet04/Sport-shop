package org.example.controller;

import org.example.client.AuthServiceClient;
import org.example.client.AuthUser;
import org.example.dto.request.WorkShiftRequest;
import org.example.dto.response.WorkShiftResponse;
import org.example.model.WorkShift;
import org.example.repository.WorkShiftRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/admin/work-shifts")
@RequiredArgsConstructor
public class WorkShiftController {
    private final WorkShiftRepository workShiftRepository;
    private final AuthServiceClient authServiceClient;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN') or hasRole('SHOP_STAFF')")
    public List<WorkShiftResponse> getShifts(
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        LocalDate start = startDate != null ? startDate : LocalDate.now();
        LocalDate end = endDate != null ? endDate : start.plusDays(7);

        List<WorkShift> shifts = userId == null
                ? workShiftRepository.findByShiftDateBetweenOrderByShiftDateAsc(start, end)
                : workShiftRepository.findByUserIdAndShiftDateBetweenOrderByShiftDateAsc(userId, start, end);
        return shifts.stream().map(this::toResponse).toList();
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SHOP_STAFF')")
    public WorkShiftResponse getShift(@PathVariable Long id) {
        return toResponse(workShiftRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Work shift not found")));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public WorkShiftResponse createShift(@RequestBody WorkShiftRequest request) {
        AuthUser user = authServiceClient.getUser(request.getUserId());
        WorkShift shift = WorkShift.builder()
                .userId(user.id())
                .userFullName(user.fullName())
                .userRole(user.effectiveRole())
                .shiftDate(request.getShiftDate())
                .shiftCode(request.getShiftCode())
                .note(request.getNote())
                .build();
        return toResponse(workShiftRepository.save(shift));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public WorkShiftResponse updateShift(@PathVariable Long id, @RequestBody WorkShiftRequest request) {
        WorkShift shift = workShiftRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Work shift not found"));
        if (request.getUserId() != null) {
            AuthUser user = authServiceClient.getUser(request.getUserId());
            shift.setUserId(user.id());
            shift.setUserFullName(user.fullName());
            shift.setUserRole(user.effectiveRole());
        }
        if (request.getShiftDate() != null) shift.setShiftDate(request.getShiftDate());
        if (request.getShiftCode() != null) shift.setShiftCode(request.getShiftCode());
        if (request.getNote() != null) shift.setNote(request.getNote());
        return toResponse(workShiftRepository.save(shift));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public void deleteShift(@PathVariable Long id) {
        if (!workShiftRepository.existsById(id)) {
            throw new IllegalArgumentException("Work shift not found");
        }
        workShiftRepository.deleteById(id);
    }

    private WorkShiftResponse toResponse(WorkShift shift) {
        return WorkShiftResponse.builder()
                .id(shift.getId())
                .userId(shift.getUserId())
                .fullName(shift.getUserFullName())
                .roleName(shift.getUserRole())
                .shiftDate(shift.getShiftDate())
                .shiftCode(shift.getShiftCode())
                .note(shift.getNote())
                .createdAt(shift.getCreatedAt())
                .build();
    }
}
