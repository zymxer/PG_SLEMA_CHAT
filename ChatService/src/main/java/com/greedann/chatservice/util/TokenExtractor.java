package com.greedann.chatservice.util;


import org.springframework.stereotype.Component;

@Component
public class TokenExtractor {
        public String getBearerToken(String authorizationHeader) {
            // The "Authorization" header will contain something like "Bearer <token>"
            if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
                // Extract the token (after "Bearer ")
                String token = authorizationHeader.substring(7);  // "Bearer " is 7 characters long
                return token;
            } else {
                return "No Bearer token found";
            }
        }
}
