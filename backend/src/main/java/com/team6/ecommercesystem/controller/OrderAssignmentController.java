package com.team6.ecommercesystem.controller;

import com.team6.ecommercesystem.dto.request.OrderAssignmentRequest;
import com.team6.ecommercesystem.dto.response.OrderAssignmentResponse;
import com.team6.ecommercesystem.model.Order;
import com.team6.ecommercesystem.model.OrderAssignment;
import com.team6.ecommercesystem.model.User;
import com.team6.ecommercesystem.repository.OrderAssignmentRepository;
import com.team6.ecommercesystem.repository.OrderRepository;
import com.team6.ecommercesystem.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/order-assignments")
@RequiredArgsConstructor
public class OrderAssignmentController {
    private final OrderAssignmentRepository assignmentRepository;
    private final OrderRepository orderRepository;
    private final UserRepository userRepository;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN') or hasRole('SHOP_STAFF') or hasRole('SHIPPER')")
    public List<OrderAssignmentResponse> getAssignments(@RequestParam(required = false) Long staffId) {
        List<OrderAssignment> assignments = staffId == null
                ? assignmentRepository.findAll()
                : assignmentRepository.findByStaffIdOrderByAssignedAtDesc(staffId);
        return assignments.stream().map(this::toResponse).toList();
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SHOP_STAFF') or hasRole('SHIPPER')")
    public OrderAssignmentResponse getById(@PathVariable Long id) {
        return toResponse(findAssignment(id));
    }

    @GetMapping("/orders/{orderId}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SHOP_STAFF') or hasRole('SHIPPER')")
    public OrderAssignmentResponse getByOrder(@PathVariable Long orderId) {
        return assignmentRepository.findByOrderId(orderId)
                .map(this::toResponse)
                .orElseThrow(() -> new IllegalArgumentException("Assignment not found"));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN') or hasRole('SHOP_STAFF')")
    public OrderAssignmentResponse create(@RequestBody OrderAssignmentRequest request) {
        if (request.getOrderId() == null) {
            throw new IllegalArgumentException("Order id is required");
        }
        return assign(request.getOrderId(), request);
    }

    @PutMapping("/orders/{orderId}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SHOP_STAFF')")
    public OrderAssignmentResponse assign(@PathVariable Long orderId, @RequestBody OrderAssignmentRequest request) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found"));
        User staff = userRepository.findById(request.getStaffId())
                .orElseThrow(() -> new IllegalArgumentException("Staff not found"));

        OrderAssignment assignment = assignmentRepository.findByOrderId(orderId)
                .orElseGet(() -> OrderAssignment.builder().order(order).build());
        assignment.setStaff(staff);
        assignment.setAssignedBy(getCurrentUser());
        assignment.setNote(request.getNote());
        return toResponse(assignmentRepository.save(assignment));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SHOP_STAFF')")
    public OrderAssignmentResponse update(@PathVariable Long id, @RequestBody OrderAssignmentRequest request) {
        OrderAssignment assignment = findAssignment(id);
        if (request.getOrderId() != null && !request.getOrderId().equals(assignment.getOrder().getId())) {
            Order order = orderRepository.findById(request.getOrderId())
                    .orElseThrow(() -> new IllegalArgumentException("Order not found"));
            assignment.setOrder(order);
        }
        if (request.getStaffId() != null) {
            User staff = userRepository.findById(request.getStaffId())
                    .orElseThrow(() -> new IllegalArgumentException("Staff not found"));
            assignment.setStaff(staff);
        }
        if (request.getNote() != null) assignment.setNote(request.getNote());
        assignment.setAssignedBy(getCurrentUser());
        return toResponse(assignmentRepository.save(assignment));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SHOP_STAFF')")
    public void delete(@PathVariable Long id) {
        assignmentRepository.delete(findAssignment(id));
    }

    @DeleteMapping("/orders/{orderId}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SHOP_STAFF')")
    public void deleteByOrder(@PathVariable Long orderId) {
        OrderAssignment assignment = assignmentRepository.findByOrderId(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Assignment not found"));
        assignmentRepository.delete(assignment);
    }

    private OrderAssignment findAssignment(Long id) {
        return assignmentRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Assignment not found"));
    }

    private User getCurrentUser() {
        String principal = SecurityContextHolder.getContext().getAuthentication().getName();
        try {
            Long userId = Long.parseLong(principal);
            return userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found"));
        } catch (NumberFormatException ignored) {
            return userRepository.findByEmail(principal).orElseThrow(() -> new RuntimeException("User not found"));
        }
    }

    private OrderAssignmentResponse toResponse(OrderAssignment assignment) {
        User staff = assignment.getStaff();
        return OrderAssignmentResponse.builder()
                .id(assignment.getId())
                .orderId(assignment.getOrder().getId())
                .staffId(staff.getId())
                .staffName(staff.getFullName())
                .staffRole(staff.getRole() != null ? staff.getRole().getRoleCode() : "")
                .assignedById(assignment.getAssignedBy() != null ? assignment.getAssignedBy().getId() : null)
                .assignedAt(assignment.getAssignedAt())
                .note(assignment.getNote())
                .build();
    }
}
