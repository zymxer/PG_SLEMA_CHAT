package com.greedann.chatservice.config;

import java.util.Map;

import lombok.RequiredArgsConstructor;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.HandshakeInterceptor;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.server.ServletServerHttpRequest;

import com.greedann.chatservice.service.UserService;
import com.greedann.chatservice.model.User;

@Component
@RequiredArgsConstructor
public class WebSocketAuthInterceptor implements HandshakeInterceptor {

    private final UserService userService;

    @Override
    public boolean beforeHandshake(@NonNull ServerHttpRequest request,
                                   @NonNull ServerHttpResponse response,
                                   @NonNull WebSocketHandler wsHandler,
                                   @NonNull Map<String, Object> attributes) {

        if (request instanceof ServletServerHttpRequest servletRequest) {
            String token = extractToken(servletRequest.getServletRequest());

            if (token != null) {
                try {
                    User user = userService.getRequestUser(token);
                    if (user != null) {
                        // Store user details in WebSocket session attributes for later access
                        attributes.put("authorization", token);
                        attributes.put("username", user.getUsername());
                        attributes.put("userId", user.getId());
                        return true;
                    } else {
                        response.setStatusCode(org.springframework.http.HttpStatus.UNAUTHORIZED);
                        return false;
                    }
                } catch (Exception e) {
                    System.err.println("Error during user authentication for WebSocket handshake: " + e.getMessage());
                    response.setStatusCode(org.springframework.http.HttpStatus.UNAUTHORIZED);
                    return false;
                }
            } else {
                response.setStatusCode(org.springframework.http.HttpStatus.UNAUTHORIZED);
                return false;
            }
        }
        // If the request is not a servlet request (unlikely in typical web scenarios)
        response.setStatusCode(org.springframework.http.HttpStatus.BAD_REQUEST);
        return false;
    }

    // This method is called after the handshake, regardless of success or failure.
    // Useful for final logging or cleanup, but often left empty.
    @Override
    public void afterHandshake(@NonNull ServerHttpRequest request,
                               @NonNull ServerHttpResponse response,
                               @NonNull WebSocketHandler wsHandler,
                               Exception exception) {
        if (exception != null) {
            System.err.println("Exception occurred after WebSocket handshake: " + exception.getMessage());
        }
    }

    private String extractToken(HttpServletRequest request) {
        String header = request.getHeader("Authorization");
        if (header != null && header.startsWith("Bearer ")) {
            return header;
        }
        return null;
    }
}