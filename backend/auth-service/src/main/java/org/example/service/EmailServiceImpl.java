package org.example.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.MailException;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.UnsupportedEncodingException;

@Slf4j
@Service
@RequiredArgsConstructor

public class EmailServiceImpl implements EmailService {
    private static final String PASSWORD_RESET_SUBJECT = "Đặt lại mật khẩu StrideX";
    private static final String PASSWORD_RESET_CONFIRMATION_SUBJECT = "Mật khẩu StrideX đã được thay đổi";
    private static final int TOKEN_EXPIRY_MINUTES = 5;

    private final JavaMailSender mailSender;

    @Value("${app.mail.from}")
    private String fromEmail;

    @Value("${app.mail.from-name:StrideX}")
    private String fromName;

    @Value("${app.mobile.reset-password-url}")
    private String mobileResetPasswordUrl;

    @Override
    @Async
    public void sendPasswordResetEmail(String to, String token) {

        log.info("Sending password reset email to: {}", to);

        try {
            String resetUrl = UriComponentsBuilder.fromUriString(mobileResetPasswordUrl)
                    .queryParam("token", token)
                    .build()
                    .encode()
                    .toUriString();
            sendHtmlEmail(to, PASSWORD_RESET_SUBJECT, buildPasswordResetEmailBody(resetUrl));
            log.info("Password reset email sent successfully to: {}", to);
        } catch (MailException | MessagingException | UnsupportedEncodingException e) {
            log.error("Failed to send password reset email to: {}", to, e);
            throw new RuntimeException("Failed to send password reset email", e);
        }
    }

    @Override
    @Async
    public void sendPasswordResetConfirmationEmail(String to) {
        try {
            sendHtmlEmail(to, PASSWORD_RESET_CONFIRMATION_SUBJECT, """
                    <h2>Mật khẩu đã được thay đổi</h2>
                    <p>Mật khẩu tài khoản StrideX của bạn vừa được đặt lại thành công.</p>
                    <p>Nếu bạn không thực hiện thay đổi này, hãy liên hệ quản trị viên ngay.</p>
                    """);
            log.info("Password reset confirmation email sent successfully to: {}", to);
        } catch (MailException | MessagingException | UnsupportedEncodingException e) {
            log.error("Failed to send password reset confirmation email to: {}", to, e);
        }
    }

    private void sendHtmlEmail(String to, String subject, String html)
            throws MessagingException, UnsupportedEncodingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, "UTF-8");
        helper.setFrom(fromEmail, fromName);
        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(wrapTemplate(html), true);
        mailSender.send(message);
    }

    private String buildPasswordResetEmailBody(String resetUrl) {
        return """
                <h2>Yêu cầu đặt lại mật khẩu</h2>
                <p>StrideX đã nhận được yêu cầu đặt lại mật khẩu cho tài khoản của bạn.</p>
                <p style="margin:28px 0"><a href="%s" style="background:#1769e0;color:#fff;padding:12px 22px;text-decoration:none;border-radius:6px">Đặt lại mật khẩu</a></p>
                <p>Liên kết chỉ có hiệu lực trong <strong>%d phút</strong>.</p>
                <p>Nếu bạn không gửi yêu cầu này, hãy bỏ qua email.</p>
                """.formatted(resetUrl, TOKEN_EXPIRY_MINUTES);
    }

    private String wrapTemplate(String content) {
        return """
                <!doctype html><html><body style="font-family:Arial,sans-serif;background:#f4f7fb;padding:24px">
                <div style="max-width:600px;margin:auto;background:white;padding:32px;border-radius:12px;border:1px solid #dde5ef">
                <div style="font-size:24px;font-weight:700;color:#14213d;margin-bottom:24px">StrideX</div>
                %s
                <hr style="border:0;border-top:1px solid #e5e7eb;margin-top:28px"><p style="color:#64748b;font-size:12px">Email tự động từ hệ thống StrideX.</p>
                </div></body></html>
                """.formatted(content);
    }
}
