package org.example.dto.request;

import lombok.Data;

@Data
public class OrderAssignmentRequest {
    private Long orderId;
    private Long staffId;
    private String note;
}
