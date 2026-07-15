package org.example.dto.request;

import lombok.Data;

import java.time.LocalDate;

@Data
public class LeaveRequestRequest {
    private Long userId;
    private LocalDate startDate;
    private Integer days;
    private String reason;
}
