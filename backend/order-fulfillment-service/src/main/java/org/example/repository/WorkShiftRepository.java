package org.example.repository;

import org.example.model.WorkShift;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface WorkShiftRepository extends JpaRepository<WorkShift, Long> {
    List<WorkShift> findByShiftDateBetweenOrderByShiftDateAsc(LocalDate startDate, LocalDate endDate);
    List<WorkShift> findByUserIdAndShiftDateBetweenOrderByShiftDateAsc(Long userId, LocalDate startDate, LocalDate endDate);
}
