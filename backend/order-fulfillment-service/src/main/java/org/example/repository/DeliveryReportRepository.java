package org.example.repository;

import org.example.model.DeliveryReport;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DeliveryReportRepository extends JpaRepository<DeliveryReport, Long> {
    List<DeliveryReport> findByOrderIdOrderByCreatedAtDesc(Long orderId);
    List<DeliveryReport> findAllByOrderByCreatedAtDesc();
}
