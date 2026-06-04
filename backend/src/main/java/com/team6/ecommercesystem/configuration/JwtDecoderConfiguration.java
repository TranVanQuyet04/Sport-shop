package com.team6.ecommercesystem.configuration;

import com.nimbusds.jose.JOSEException;
import com.team6.ecommercesystem.service.JwtServiceImpl;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.*;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.text.ParseException;
import java.time.Duration;

@Slf4j
@Component
@RequiredArgsConstructor
public class JwtDecoderConfiguration implements JwtDecoder {
    private static final String JWT_ALGORITHM = "HS512";
    private static final int MINIMUM_KEY_LENGTH_BYTES = 64;

    @Value("${jwt.secret-key}")
    private String secretKey;

    private final JwtServiceImpl jwtServiceImpl;
    private NimbusJwtDecoder nimbusJwtDecoder;

    @PostConstruct
    public void init() {
        validateSecretKey();
        try {
            SecretKey key = new SecretKeySpec(
                    secretKey.getBytes(StandardCharsets.UTF_8),
                    JWT_ALGORITHM
            );

            // Tạo validator cho phép lệch 60 giây (quan trọng nhất)
            JwtTimestampValidator timestampValidator = new JwtTimestampValidator(Duration.ofSeconds(60));

            this.nimbusJwtDecoder = NimbusJwtDecoder.withSecretKey(key)
                    .macAlgorithm(MacAlgorithm.HS512)
                    .build();

            // Gắn validator vào decoder
            this.nimbusJwtDecoder.setJwtValidator(timestampValidator);

            log.info("Jwt decoder successfully initialized with 60s clock skew leeway");
        } catch (Exception e){
            log.error("Failed to initialized JWT decoder", e);
            throw new IllegalStateException("Failed to initialized JWT decoder");
        }
    }

    private void validateSecretKey(){
        if (secretKey == null || secretKey.isBlank()){
            throw new IllegalStateException("JWT secret key is not configured");
        }

        byte[] keyBytes = secretKey.getBytes(StandardCharsets.UTF_8);
        if (keyBytes.length < MINIMUM_KEY_LENGTH_BYTES){
            throw new IllegalStateException(
                    String.format("JWT secret key must be at least %d bytes for %s algorithm. Current length: %d bytes,",
                            MINIMUM_KEY_LENGTH_BYTES,JWT_ALGORITHM,keyBytes.length)
            );
        }
    }

    @Override
    public Jwt decode(String token) throws JwtException {
        try {
            if (!jwtServiceImpl.verifyToken(token))  {
                log.warn("Token verification failed");
                throw new JwtException("Invalid or expired jwt token");
            }

            return nimbusJwtDecoder.decode(token);
        } catch (Exception e) {
            log.error("JWT Decoding failed: {}", e.getMessage());
            throw new JwtException(e.getMessage());
        }
    }
}
