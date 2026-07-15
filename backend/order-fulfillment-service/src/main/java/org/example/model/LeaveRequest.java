package org.example.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "leave_requests")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LeaveRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;
    private String userFullName;
    private String userRole;

    private LocalDate startDate;
    private Integer days;
    private String reason;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime decidedAt;

    @Column(name = "decided_by")
    private Long decidedById;

    @PrePersist
    void onCreate() {
        if (createdAt == null) createdAt = LocalDateTime.now();
        if (status == null || status.isBlank()) status = "PENDING";
    }
}
