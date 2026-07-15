package org.example.service;

import org.example.dto.request.ProfileUpdateRequest;
import org.example.dto.request.RegisterRequest;
import org.example.dto.request.UserRequest;
import org.example.dto.request.UserUpdateRequest;
import org.example.dto.response.UserDetailResponse;
import org.example.dto.response.UserResponse;
import org.example.dto.response.UserSummaryResponse;

import java.util.List;

public interface UserService {
    UserResponse createUser(UserRequest request);
    List<UserSummaryResponse> getAllUsers();
    UserDetailResponse getUserDetail(Long id);
    UserDetailResponse updateUser(Long id, UserUpdateRequest request);
    void deleteUser(Long id);
    UserDetailResponse getMyProfile();
    UserDetailResponse updateMyProfile(ProfileUpdateRequest request);
}

