package org.example.controller;

import org.example.client.AuthServiceClient;
import org.example.client.AuthUser;
import org.example.dto.request.LeaveDecisionRequest;
import org.example.dto.request.LeaveRequestRequest;
import org.example.dto.response.LeaveRequestResponse;
import org.example.model.LeaveRequest;
import org.example.repository.LeaveRequestRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class LeaveRequestController {
    private final LeaveRequestRepository leaveRequestRepository;
    private final AuthServiceClient authServiceClient;

    @GetMapping("/admin/leave-requests")
    @PreAuthorize("hasRole('ADMIN')")
    public List<LeaveRequestResponse> getAll() {
        return leaveRequestRepository.findAllByOrderByCreatedAtDesc().stream().map(this::toResponse).toList();
    }

    @GetMapping("/admin/leave-requests/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public LeaveRequestResponse getOneForAdmin(@PathVariable Long id) {
        return toResponse(findLeave(id));
    }

    @GetMapping("/user/leave-requests")
    public List<LeaveRequestResponse> getMine() {
        return leaveRequestRepository.findByUserIdOrderByCreatedAtDesc(getCurrentUserId()).stream().map(this::toResponse).toList();
    }

    @GetMapping("/user/leave-requests/{id}")
    public LeaveRequestResponse getMineById(@PathVariable Long id) {
        LeaveRequest leave = findLeave(id);
        ensureOwner(leave);
        return toResponse(leave);
    }

    @PostMapping("/user/leave-requests")
    public LeaveRequestResponse create(@RequestBody LeaveRequestRequest request) {
        Long currentUserId = getCurrentUserId();
        Long requestedUserId = request.getUserId() == null ? currentUserId : request.getUserId();
        if (!requestedUserId.equals(currentUserId) && !hasRole("ADMIN")) {
            throw new IllegalArgumentException("Only admin can create leave request for another user");
        }
        AuthUser user = authServiceClient.getUser(requestedUserId);
        LeaveRequest leave = LeaveRequest.builder()
                .userId(user.id())
                .userFullName(user.fullName())
                .userRole(user.effectiveRole())
                .startDate(request.getStartDate())
                .days(request.getDays())
                .reason(request.getReason())
                .status("PENDING")
                .build();
        return toResponse(leaveRequestRepository.save(leave));
    }

    @PutMapping("/user/leave-requests/{id}")
    public LeaveRequestResponse updateMine(@PathVariable Long id, @RequestBody LeaveRequestRequest request) {
        LeaveRequest leave = findLeave(id);
        ensureOwner(leave);
        ensurePending(leave);
        if (request.getStartDate() != null) leave.setStartDate(request.getStartDate());
        if (request.getDays() != null) leave.setDays(request.getDays());
        if (request.getReason() != null) leave.setReason(request.getReason());
        return toResponse(leaveRequestRepository.save(leave));
    }

    @PutMapping("/admin/leave-requests/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public LeaveRequestResponse updateForAdmin(@PathVariable Long id, @RequestBody LeaveRequestRequest request) {
        LeaveRequest leave = findLeave(id);
        if (request.getUserId() != null) {
            AuthUser user = authServiceClient.getUser(request.getUserId());
            leave.setUserId(user.id());
            leave.setUserFullName(user.fullName());
            leave.setUserRole(user.effectiveRole());
        }
        if (request.getStartDate() != null) leave.setStartDate(request.getStartDate());
        if (request.getDays() != null) leave.setDays(request.getDays());
        if (request.getReason() != null) leave.setReason(request.getReason());
        return toResponse(leaveRequestRepository.save(leave));
    }

    @PatchMapping("/admin/leave-requests/{id}/decision")
    @PreAuthorize("hasRole('ADMIN')")
    public LeaveRequestResponse decide(@PathVariable Long id, @RequestBody LeaveDecisionRequest request) {
        LeaveRequest leave = findLeave(id);
        String status = request.getStatus() == null ? "" : request.getStatus().trim().toUpperCase();
        if (!status.equals("APPROVED") && !status.equals("REJECTED")) {
            throw new IllegalArgumentException("Status must be APPROVED or REJECTED");
        }
        leave.setStatus(status);
        leave.setDecidedAt(LocalDateTime.now());
        leave.setDecidedById(getCurrentUserId());
        return toResponse(leaveRequestRepository.save(leave));
    }

    @DeleteMapping("/user/leave-requests/{id}")
    public void deleteMine(@PathVariable Long id) {
        LeaveRequest leave = findLeave(id);
        ensureOwner(leave);
        ensurePending(leave);
        leaveRequestRepository.delete(leave);
    }

    @DeleteMapping("/admin/leave-requests/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public void deleteForAdmin(@PathVariable Long id) {
        LeaveRequest leave = findLeave(id);
        leaveRequestRepository.delete(leave);
    }

    private LeaveRequest findLeave(Long id) {
        return leaveRequestRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Leave request not found"));
    }

    private Long getCurrentUserId() {
        return Long.parseLong(SecurityContextHolder.getContext().getAuthentication().getName());
    }

    private void ensureOwner(LeaveRequest leave) {
        if (!leave.getUserId().equals(getCurrentUserId())) {
            throw new IllegalArgumentException("Leave request not found");
        }
    }

    private void ensurePending(LeaveRequest leave) {
        if (!"PENDING".equalsIgnoreCase(leave.getStatus())) {
            throw new IllegalArgumentException("Only pending leave requests can be changed");
        }
    }

    private boolean hasRole(String role) {
        return SecurityContextHolder.getContext().getAuthentication().getAuthorities().stream()
                .anyMatch(authority -> authority.getAuthority().equals("ROLE_" + role));
    }

    private LeaveRequestResponse toResponse(LeaveRequest leave) {
        return LeaveRequestResponse.builder()
                .id(leave.getId())
                .userId(leave.getUserId())
                .fullName(leave.getUserFullName())
                .roleName(leave.getUserRole())
                .startDate(leave.getStartDate())
                .days(leave.getDays())
                .reason(leave.getReason())
                .status(leave.getStatus())
                .createdAt(leave.getCreatedAt())
                .decidedAt(leave.getDecidedAt())
                .decidedById(leave.getDecidedById())
                .build();
    }
}
