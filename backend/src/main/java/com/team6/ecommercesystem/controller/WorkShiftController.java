package com.team6.ecommercesystem.controller;

import com.team6.ecommercesystem.dto.request.WorkShiftRequest;
import com.team6.ecommercesystem.dto.response.WorkShiftResponse;
import com.team6.ecommercesystem.model.User;
import com.team6.ecommercesystem.model.WorkShift;
import com.team6.ecommercesystem.repository.UserRepository;
import com.team6.ecommercesystem.repository.WorkShiftRepository;
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
    private final UserRepository userRepository;

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
        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        WorkShift shift = WorkShift.builder()
                .user(user)
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
            User user = userRepository.findById(request.getUserId())
                    .orElseThrow(() -> new IllegalArgumentException("User not found"));
            shift.setUser(user);
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
        User user = shift.getUser();
        return WorkShiftResponse.builder()
                .id(shift.getId())
                .userId(user.getId())
                .fullName(user.getFullName())
                .roleName(user.getRole() != null ? user.getRole().getRoleCode() : "")
                .shiftDate(shift.getShiftDate())
                .shiftCode(shift.getShiftCode())
                .note(shift.getNote())
                .createdAt(shift.getCreatedAt())
                .build();
    }
}
