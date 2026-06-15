package com.team6.ecommercesystem.repository;

import com.team6.ecommercesystem.model.DeliveryReport;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DeliveryReportRepository extends JpaRepository<DeliveryReport, Long> {
    List<DeliveryReport> findByOrderIdOrderByCreatedAtDesc(Long orderId);
    List<DeliveryReport> findAllByOrderByCreatedAtDesc();
}
