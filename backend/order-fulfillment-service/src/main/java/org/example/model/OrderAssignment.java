package org.example.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "order_assignments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderAssignment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false, unique = true)
    private Order order;

    @Column(name = "staff_id", nullable = false)
    private Long staffId;
    private String staffName;
    private String staffRole;

    @Column(name = "assigned_by")
    private Long assignedById;

    private LocalDateTime assignedAt;
    private String note;

    @PrePersist
    @PreUpdate
    void onSave() {
        if (assignedAt == null) assignedAt = LocalDateTime.now();
    }
}
