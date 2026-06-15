package com.team6.ecommercesystem.repository;

import com.team6.ecommercesystem.model.OrderAssignment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface OrderAssignmentRepository extends JpaRepository<OrderAssignment, Long> {
    Optional<OrderAssignment> findByOrderId(Long orderId);
    List<OrderAssignment> findByStaffIdOrderByAssignedAtDesc(Long staffId);
}
