package org.example.repository;

import org.example.model.LeaveRequest;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LeaveRequestRepository extends JpaRepository<LeaveRequest, Long> {
    List<LeaveRequest> findAllByOrderByCreatedAtDesc();
    List<LeaveRequest> findByUserIdOrderByCreatedAtDesc(Long userId);
}
