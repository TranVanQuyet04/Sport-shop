package com.team6.ecommercesystem.dto.response;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
public class WorkShiftResponse {
    private Long id;
    private Long userId;
    private String fullName;
    private String roleName;
    private LocalDate shiftDate;
    private String shiftCode;
    private String note;
    private LocalDateTime createdAt;
}
