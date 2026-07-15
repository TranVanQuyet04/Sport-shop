package org.example.dto.response;

import lombok.AccessLevel;
import lombok.Builder;
import lombok.Data;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class BrandResponse {
     String brandName;
     String brandBanner;
     String slug;
     Long id;
     String logo;
     String description;
     boolean isActive;
}
