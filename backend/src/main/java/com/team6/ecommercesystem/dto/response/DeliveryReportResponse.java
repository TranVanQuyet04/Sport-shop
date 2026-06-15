package com.team6.ecommercesystem.dto.response;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class DeliveryReportResponse {
    private Long id;
    private Long orderId;
    private Long reportedById;
    private String reportedByName;
    private String status;
    private String reason;
    private String note;
    private String evidenceImageUrl;
    private LocalDateTime createdAt;
}
