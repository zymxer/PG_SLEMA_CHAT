package com.greedann.chatservice.config;

import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.HandshakeInterceptor;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.server.ServletServerHttpRequest;

import com.greedann.chatservice.service.UserService;
import com.greedann.chatservice.model.User;

@Component
public class WebSocketAuthInterceptor implements HandshakeInterceptor {

    @Autowired
    private UserService userService;

    @Override
    public boolean beforeHandshake(ServerHttpRequest request, ServerHttpResponse response,
            WebSocketHandler wsHandler, Map<String, Object> attributes) throws Exception {

        if (request instanceof ServletServerHttpRequest) {
            ServletServerHttpRequest servletRequest = (ServletServerHttpRequest) request;
            String token = extractToken(servletRequest.getServletRequest());
            
            if (token != null) {
                User user = userService.getRequestUser(token);
                attributes.put("authorization", token);
                attributes.put("username", user.getUsername());
                attributes.put("userId", user.getId());
                return true;
            }
        }
        return false;
    }

    @Override
    public void afterHandshake(ServerHttpRequest request, ServerHttpResponse response,
            WebSocketHandler wsHandler, Exception exception) {
    }

    private String extractToken(HttpServletRequest request) {
        String header = request.getHeader("Authorization");
        if (header != null && header.startsWith("Bearer ")) {
            return header;
        }
        return null;
    }
}