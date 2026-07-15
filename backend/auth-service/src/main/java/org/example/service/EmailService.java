package org.example.service;

public interface EmailService {
    void sendPasswordResetEmail(String to, String token);

    void sendPasswordResetConfirmationEmail(String to);
}

