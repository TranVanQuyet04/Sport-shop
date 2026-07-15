package org.example.dto.response;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class OrderAssignmentResponse {
    private Long id;
    private Long orderId;
    private Long staffId;
    private String staffName;
    private String staffRole;
    private Long assignedById;
    private LocalDateTime assignedAt;
    private String note;
}
