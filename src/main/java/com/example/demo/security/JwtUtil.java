package com.example.demo.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;

/**
 * JWT 工具类
 */
@Slf4j
@Component
public class JwtUtil {

    @Value("${app.jwt.secret:your-jwt-secret-key-must-be-at-least-32-characters-long}")
    private String jwtSecret;

    @Value("${app.jwt.expiration:86400000}")
    private Long jwtExpiration;

    private SecretKey getSigningKey() {
        byte[] keyBytes = Decoders.BASE64.decode(jwtSecret);
        return Keys.hmacShaKeyFor(keyBytes);
    }

    /**
     * 生成 JWT Token
     */
    public String generateToken(Long userId, String username) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + jwtExpiration);

        return Jwts.builder()
                .subject(String.valueOf(userId))
                .claim("username", username)
                .issuedAt(now)
                .expiration(expiryDate)
                .signWith(getSigningKey(), Jwts.SIG.HS256)
                .compact();
    }

    /**
     * 从 Token 中提取用户ID
     */
    public Long extractUserId(String token) {
        Claims claims = extractAllClaims(token);
        return Long.valueOf(claims.getSubject());
    }

    /**
     * 从 Token 中提取用户名
     */
    public String extractUsername(String token) {
        Claims claims = extractAllClaims(token);
        return claims.get("username", String.class);
    }

    /**
     * 验证 Token 是否有效
     */
    public boolean validateToken(String token) {
        try {
            Jwts.parser()
                    .verifyWith(getSigningKey())
                    .build()
                    .parseSignedClaims(token);
            return true;
        } catch (ExpiredJwtException e) {
            log.error("JWT Token 已过期: {}", e.getMessage());
        } catch (UnsupportedJwtException e) {
            log.error("JWT Token 格式不支持: {}", e.getMessage());
        } catch (MalformedJwtException e) {
            log.error("JWT Token 格式错误: {}", e.getMessage());
        } catch (SignatureException e) {
            log.error("JWT Token 签名无效: {}", e.getMessage());
        } catch (IllegalArgumentException e) {
            log.error("JWT Token 为空或非法: {}", e.getMessage());
        }
        return false;
    }

    /**
     * 提取所有 Claims
     */
    private Claims extractAllClaims(String token) {
        return Jwts.parser()
                .verifyWith(getSigningKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    /**
     * 获取 Token 过期时间
     */
    public Long getExpiration() {
        return jwtExpiration;
    }
}
