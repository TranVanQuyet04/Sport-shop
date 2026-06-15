package com.team6.ecommercesystem.dto.response;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
public class LeaveRequestResponse {
    private Long id;
    private Long userId;
    private String fullName;
    private String roleName;
    private LocalDate startDate;
    private Integer days;
    private String reason;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime decidedAt;
    private Long decidedById;
}
