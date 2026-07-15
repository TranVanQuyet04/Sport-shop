package org.example.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserSummaryResponse {
    private Long id;
    private String fullName;
    private String email;
    private String phoneNumber;
    private String role;
    private String roleName;
    private String roleDisplayName;
    private Boolean status; // True: Active, False: Banned
    private LocalDateTime lockTime;
    private LocalDateTime lastLoginDate;
}

