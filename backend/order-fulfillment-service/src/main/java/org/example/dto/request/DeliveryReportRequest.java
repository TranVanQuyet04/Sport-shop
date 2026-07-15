package org.example.dto.request;

import lombok.Data;

@Data
public class DeliveryReportRequest {
    private String status;
    private String reason;
    private String note;
    private String evidenceImageUrl;
}
