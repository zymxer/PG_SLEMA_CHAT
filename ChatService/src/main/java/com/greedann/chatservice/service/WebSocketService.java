package com.greedann.chatservice.service;

import org.springframework.stereotype.Service;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import com.greedann.chatservice.model.User;

@Service
public class WebSocketService {
    private final Map<UUID, Set<WebSocketSession>> sessions = new ConcurrentHashMap<>();

    public WebSocketService() {
    }

    public void addSession(UUID chatId, WebSocketSession session) {
        sessions.computeIfAbsent(chatId, k -> ConcurrentHashMap.newKeySet()).add(session);
    }

    public void removeSession(UUID chatId, WebSocketSession session) {
        Set<WebSocketSession> chatSessions = sessions.get(chatId);
        if (chatSessions != null) {
            chatSessions.remove(session);
            if (chatSessions.isEmpty()) {
                sessions.remove(chatId);
            }
        }
    }

    public void broadcastMessage(UUID chatId, TextMessage message, UUID senderId, UserService userService) throws Exception {
        Set<WebSocketSession> chatSessions = sessions.get(chatId);
        if (chatSessions != null) {
            for (WebSocketSession session : chatSessions) {
                if (session.isOpen()) {
                    String authHeader = extractAuthorizationHeader(session);
                    User sessionUser = userService.getRequestUser(authHeader);
                    
                    if (!sessionUser.getId().equals(senderId)) {
                        session.sendMessage(message);
                    }
                }
            }
        }
    }

    private String extractAuthorizationHeader(WebSocketSession session) {
        Map<String, Object> attributes = session.getAttributes();
        return (String) attributes.get("authorization");
    }
} 