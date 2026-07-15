package org.example.controller;

import org.example.client.AuthServiceClient;
import org.example.client.AuthUser;
import org.example.dto.request.DeliveryReportRequest;
import org.example.dto.response.DeliveryReportResponse;
import org.example.model.DeliveryReport;
import org.example.model.Order;
import org.example.model.enums.OrderStatus;
import org.example.repository.DeliveryReportRepository;
import org.example.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class DeliveryReportController {
    private final DeliveryReportRepository reportRepository;
    private final OrderRepository orderRepository;
    private final AuthServiceClient authServiceClient;

    @GetMapping("/admin/delivery-reports")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SHOP_STAFF')")
    public List<DeliveryReportResponse> getAll() {
        return reportRepository.findAllByOrderByCreatedAtDesc().stream().map(this::toResponse).toList();
    }

    @GetMapping("/admin/delivery-reports/{id}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SHOP_STAFF')")
    public DeliveryReportResponse getOne(@PathVariable Long id) {
        return toResponse(findReport(id));
    }

    @GetMapping("/orders/{orderId}/delivery-reports")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SHOP_STAFF') or hasRole('SHIPPER')")
    public List<DeliveryReportResponse> getByOrder(@PathVariable Long orderId) {
        return reportRepository.findByOrderIdOrderByCreatedAtDesc(orderId).stream().map(this::toResponse).toList();
    }

    @PostMapping("/orders/{orderId}/delivery-reports")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SHIPPER')")
    public DeliveryReportResponse create(@PathVariable Long orderId, @RequestBody DeliveryReportRequest request) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found"));
        String status = request.getStatus() == null ? "FAILED" : request.getStatus().trim().toUpperCase();
        if (!status.equals("FAILED") && !status.equals("RETURNED")) {
            throw new IllegalArgumentException("Status must be FAILED or RETURNED");
        }

        AuthUser reporter = authServiceClient.getUser(getCurrentUserId());
        DeliveryReport report = DeliveryReport.builder()
                .order(order)
                .reportedById(reporter.id())
                .reportedByName(reporter.fullName())
                .status(status)
                .reason(request.getReason())
                .note(request.getNote())
                .evidenceImageUrl(request.getEvidenceImageUrl())
                .build();

        if (status.equals("FAILED") || status.equals("RETURNED")) {
            order.setStatus(OrderStatus.CANCELLED);
            orderRepository.save(order);
        }

        return toResponse(reportRepository.save(report));
    }

    @PutMapping("/admin/delivery-reports/{id}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SHOP_STAFF')")
    public DeliveryReportResponse update(@PathVariable Long id, @RequestBody DeliveryReportRequest request) {
        DeliveryReport report = findReport(id);
        String status = normalizeStatus(request.getStatus(), report.getStatus());
        report.setStatus(status);
        if (request.getReason() != null) report.setReason(request.getReason());
        if (request.getNote() != null) report.setNote(request.getNote());
        if (request.getEvidenceImageUrl() != null) report.setEvidenceImageUrl(request.getEvidenceImageUrl());
        return toResponse(reportRepository.save(report));
    }

    @DeleteMapping("/admin/delivery-reports/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public void delete(@PathVariable Long id) {
        reportRepository.delete(findReport(id));
    }

    private DeliveryReport findReport(Long id) {
        return reportRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Delivery report not found"));
    }

    private String normalizeStatus(String requestedStatus, String defaultStatus) {
        String status = requestedStatus == null ? defaultStatus : requestedStatus.trim().toUpperCase();
        if (!status.equals("FAILED") && !status.equals("RETURNED")) {
            throw new IllegalArgumentException("Status must be FAILED or RETURNED");
        }
        return status;
    }

    private Long getCurrentUserId() {
        return Long.parseLong(SecurityContextHolder.getContext().getAuthentication().getName());
    }

    private DeliveryReportResponse toResponse(DeliveryReport report) {
        return DeliveryReportResponse.builder()
                .id(report.getId())
                .orderId(report.getOrder().getId())
                .reportedById(report.getReportedById())
                .reportedByName(report.getReportedByName())
                .status(report.getStatus())
                .reason(report.getReason())
                .note(report.getNote())
                .evidenceImageUrl(report.getEvidenceImageUrl())
                .createdAt(report.getCreatedAt())
                .build();
    }
}
