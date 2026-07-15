package org.example.repository;

import org.example.model.OrderAssignment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface OrderAssignmentRepository extends JpaRepository<OrderAssignment, Long> {
    Optional<OrderAssignment> findByOrderId(Long orderId);
    List<OrderAssignment> findByStaffIdOrderByAssignedAtDesc(Long staffId);
}
