package org.example.controller;

import org.example.client.AuthServiceClient;
import org.example.client.AuthUser;
import org.example.dto.request.OrderAssignmentRequest;
import org.example.dto.response.OrderAssignmentResponse;
import org.example.model.Order;
import org.example.model.OrderAssignment;
import org.example.repository.OrderAssignmentRepository;
import org.example.repository.OrderRepository;
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
    private final AuthServiceClient authServiceClient;

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
        AuthUser staff = authServiceClient.getUser(request.getStaffId());

        OrderAssignment assignment = assignmentRepository.findByOrderId(orderId)
                .orElseGet(() -> OrderAssignment.builder().order(order).build());
        assignment.setStaffId(staff.id());
        assignment.setStaffName(staff.fullName());
        assignment.setStaffRole(staff.effectiveRole());
        assignment.setAssignedById(getCurrentUserId());
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
            AuthUser staff = authServiceClient.getUser(request.getStaffId());
            assignment.setStaffId(staff.id());
            assignment.setStaffName(staff.fullName());
            assignment.setStaffRole(staff.effectiveRole());
        }
        if (request.getNote() != null) assignment.setNote(request.getNote());
        assignment.setAssignedById(getCurrentUserId());
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

    private Long getCurrentUserId() {
        return Long.parseLong(SecurityContextHolder.getContext().getAuthentication().getName());
    }

    private OrderAssignmentResponse toResponse(OrderAssignment assignment) {
        return OrderAssignmentResponse.builder()
                .id(assignment.getId())
                .orderId(assignment.getOrder().getId())
                .staffId(assignment.getStaffId())
                .staffName(assignment.getStaffName())
                .staffRole(assignment.getStaffRole())
                .assignedById(assignment.getAssignedById())
                .assignedAt(assignment.getAssignedAt())
                .note(assignment.getNote())
                .build();
    }
}
