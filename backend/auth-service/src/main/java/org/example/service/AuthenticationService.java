package org.example.service;

import com.nimbusds.jose.JOSEException;
import org.example.dto.request.*;
import org.example.dto.response.LoginResponse;
import org.example.dto.response.UserResponse;

import java.text.ParseException;

public interface AuthenticationService {
    void logout(String token) throws ParseException;
    LoginResponse login(LoginRequest request);
    LoginResponse refreshToken(String refreshToken) throws ParseException, JOSEException;
    void changePassword(Long userId, ChangePasswordRequest request);
    void forgotPassword(ForgotPasswordRequest request);
    void resetPassword(ResetPasswordRequest request);
    public UserResponse register(RegisterRequest request);
}


