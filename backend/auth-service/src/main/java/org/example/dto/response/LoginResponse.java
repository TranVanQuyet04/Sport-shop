package org.example.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class LoginResponse {
    private String accessToken;
    private String refreshToken;
    private String role;
    private String roleName;
    private String roleDisplayName;
    private UserResponse user;
}

