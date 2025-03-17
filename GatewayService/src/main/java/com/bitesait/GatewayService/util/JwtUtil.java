package com.bitesait.GatewayService.util;



import io.jsonwebtoken.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.Date;

@Component

public class JwtUtil {

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${jwt.expiration}")
    private Long jwtExpiration;

    public String generateToken(User user){
        return Jwts.builder()
                .setSubject(user.getUsername())
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + jwtExpiration))
                .signWith(SignatureAlgorithm.HS256, jwtSecret)
                .compact();

    }

    public String extractUsername(String token){
        return Jwts.parserBuilder()
                .setSigningKey(jwtSecret) // Use the correct signing key
                .build()
                .parseClaimsJws(token)  // Use parseClaimsJws for signed JWT (JWS)
                .getBody()
                .getSubject();
    }
    public boolean validateToken(String token){
        try{
            Claims claims = Jwts.parserBuilder()
                    .setSigningKey(jwtSecret)
                    .build()
                    .parseClaimsJws(token)
                    .getBody();

            Date expiration = claims.getExpiration();
            System.out.println(expiration);
            if (expiration.before(new Date())) {
                return false; // Token is expired
            }
            return true;
        } catch (ExpiredJwtException e) {
            System.out.println("Token is expired: " + e.getMessage());
            return false;
        } catch (MalformedJwtException e) {
            System.out.println("Malformed token: " + e.getMessage());
            return false;
        } catch (IllegalArgumentException e) {
            System.out.println("Illegal argument: " + e.getMessage());
            return false;
        } catch (JwtException e) {
            // Catch all other JWT exceptions (parse exceptions, etc.)
            System.out.println("Invalid JWT token: " + e.getMessage());
            return false;
        }
    }
}
