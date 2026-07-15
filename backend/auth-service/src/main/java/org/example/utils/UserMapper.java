package org.example.utils;

import org.example.dto.response.UserDetailResponse;
import org.example.dto.response.UserResponse;
import org.example.dto.response.UserSummaryResponse;
import org.example.model.User;

public class UserMapper {
    public static UserSummaryResponse toSummaryDto(User user) {
        String roleCode = roleCode(user);
        String roleDisplayName = roleDisplayName(user);

        return UserSummaryResponse.builder()
                .id(user.getId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .phoneNumber(user.getPhoneNumber())
                .role(roleCode)
                .roleName(roleCode)
                .roleDisplayName(roleDisplayName)
                .status(user.getStatus())
                .lastLoginDate(user.getLastLoginDate())
                .lockTime(user.getLockTime())
                .build();
    }

    public static UserDetailResponse toDetailDto(User user) {
        String roleCode = roleCode(user);
        String roleDisplayName = roleDisplayName(user);

        return UserDetailResponse.builder()
                .id(user.getId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .phoneNumber(user.getPhoneNumber())
                .role(roleCode)
                .roleName(roleCode)
                .roleDisplayName(roleDisplayName)
                .status(user.getStatus())
                .lastLoginDate(user.getLastLoginDate())
                .lastPasswordChangeDate(user.getLastPasswordChangeDate())
                .failedLoginAttempts(user.getFailedLoginAttempts())
                .lockTime(user.getLockTime())
                .build();
    }

    public static UserResponse toUserResponse(User user) {
        String roleCode = roleCode(user);
        String roleDisplayName = roleDisplayName(user);

        return UserResponse.builder()
                .id(user.getId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .phoneNumber(user.getPhoneNumber())
                .status(user.getStatus())
                .role(roleCode)
                .roleName(roleCode)
                .roleDisplayName(roleDisplayName)
                .build();
    }

    private static String roleCode(User user) {
        return user.getRole() != null ? user.getRole().getRoleCode() : "N/A";
    }

    private static String roleDisplayName(User user) {
        return user.getRole() != null ? user.getRole().getRoleName() : "N/A";
    }
}

