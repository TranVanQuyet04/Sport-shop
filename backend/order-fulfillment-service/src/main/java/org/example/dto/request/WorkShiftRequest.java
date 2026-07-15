package org.example.dto.request;

import lombok.Data;

import java.time.LocalDate;

@Data
public class WorkShiftRequest {
    private Long userId;
    private LocalDate shiftDate;
    private String shiftCode;
    private String note;
}
