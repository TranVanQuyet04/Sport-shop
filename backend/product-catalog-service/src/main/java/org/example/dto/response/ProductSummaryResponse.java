package org.example.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProductSummaryResponse {
    private Long id;
    private String productName;
    private String categoryName;
    private String brandName;
    private String sportName;
    private BigDecimal price;
    private String image_url;
    private List<String> colors;
}
