package org.example.service;

import com.nimbusds.jose.JOSEException;
import org.example.dto.JwtInfo;
import org.example.dto.TokenPayLoad;
import org.example.model.User;

import java.text.ParseException;

public interface JwtService {
    TokenPayLoad generateAccessToken(User user);
    TokenPayLoad generateRefreshToken(User user);
    boolean verifyToken(String token) throws ParseException, JOSEException;
    boolean verifyToken(String token, boolean checkBlacklist) throws ParseException, JOSEException;
    JwtInfo parseToken(String token) throws ParseException;
}

