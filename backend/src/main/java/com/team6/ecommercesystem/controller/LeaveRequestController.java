package com.team6.ecommercesystem.controller;

import com.team6.ecommercesystem.dto.request.LeaveDecisionRequest;
import com.team6.ecommercesystem.dto.request.LeaveRequestRequest;
import com.team6.ecommercesystem.dto.response.LeaveRequestResponse;
import com.team6.ecommercesystem.model.LeaveRequest;
import com.team6.ecommercesystem.model.User;
import com.team6.ecommercesystem.repository.LeaveRequestRepository;
import com.team6.ecommercesystem.repository.UserRepository;
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
    private final UserRepository userRepository;

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
        User user = getCurrentUser();
        return leaveRequestRepository.findByUserIdOrderByCreatedAtDesc(user.getId()).stream().map(this::toResponse).toList();
    }

    @GetMapping("/user/leave-requests/{id}")
    public LeaveRequestResponse getMineById(@PathVariable Long id) {
        LeaveRequest leave = findLeave(id);
        ensureOwner(leave);
        return toResponse(leave);
    }

    @PostMapping("/user/leave-requests")
    public LeaveRequestResponse create(@RequestBody LeaveRequestRequest request) {
        User currentUser = getCurrentUser();
        User user = request.getUserId() == null || request.getUserId().equals(currentUser.getId())
                ? currentUser
                : userRepository.findById(request.getUserId()).orElseThrow(() -> new IllegalArgumentException("User not found"));
        if (!user.getId().equals(currentUser.getId()) && !isAdmin(currentUser)) {
            throw new IllegalArgumentException("Only admin can create leave request for another user");
        }
        LeaveRequest leave = LeaveRequest.builder()
                .user(user)
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
            User user = userRepository.findById(request.getUserId())
                    .orElseThrow(() -> new IllegalArgumentException("User not found"));
            leave.setUser(user);
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
        leave.setDecidedBy(getCurrentUser());
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

    private User getCurrentUser() {
        Long userId = Long.parseLong(SecurityContextHolder.getContext().getAuthentication().getName());
        return userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found"));
    }

    private void ensureOwner(LeaveRequest leave) {
        User currentUser = getCurrentUser();
        if (!leave.getUser().getId().equals(currentUser.getId())) {
            throw new IllegalArgumentException("Leave request not found");
        }
    }

    private void ensurePending(LeaveRequest leave) {
        if (!"PENDING".equalsIgnoreCase(leave.getStatus())) {
            throw new IllegalArgumentException("Only pending leave requests can be changed");
        }
    }

    private boolean isAdmin(User user) {
        return user.getRole() != null && "ADMIN".equals(user.getRole().getRoleCode());
    }

    private LeaveRequestResponse toResponse(LeaveRequest leave) {
        User user = leave.getUser();
        return LeaveRequestResponse.builder()
                .id(leave.getId())
                .userId(user.getId())
                .fullName(user.getFullName())
                .roleName(user.getRole() != null ? user.getRole().getRoleCode() : "")
                .startDate(leave.getStartDate())
                .days(leave.getDays())
                .reason(leave.getReason())
                .status(leave.getStatus())
                .createdAt(leave.getCreatedAt())
                .decidedAt(leave.getDecidedAt())
                .decidedById(leave.getDecidedBy() != null ? leave.getDecidedBy().getId() : null)
                .build();
    }
}
