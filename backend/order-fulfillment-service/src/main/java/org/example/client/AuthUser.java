package org.example.client;

public record AuthUser(Long id, String fullName, String email, String phoneNumber,
                       String role, String roleName, String roleDisplayName, Boolean status) {
    public String effectiveRole() {
        return roleName != null && !roleName.isBlank() ? roleName : role;
    }
}
