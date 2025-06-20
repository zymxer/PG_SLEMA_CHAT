package com.greedann.chatservice.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.ArrayList; // Added for safe iteration

import com.greedann.chatservice.model.User;

@Service
@RequiredArgsConstructor
public class WebSocketService {
    private final Map<UUID, Set<WebSocketSession>> sessions = new ConcurrentHashMap<>();
    private final Map<UUID, WebSocketSession> activeSessionsByUserId = new ConcurrentHashMap<>();

    public void addSession(UUID chatId, WebSocketSession session) {
        sessions.computeIfAbsent(chatId, k -> ConcurrentHashMap.newKeySet()).add(session);
        System.out.println("[WS_SERVICE] DEBUG: Session " + session.getId() + " added to chat " + chatId + ". Total sessions for chat: " + sessions.get(chatId).size());
    }

    public void addSessionByUserId(UUID userId, WebSocketSession session) {
        if (userId != null) {
            activeSessionsByUserId.put(userId, session);
            System.out.println("[WS_SERVICE] INFO: Session " + session.getId() + " ADDED to activeSessionsByUserId for user " + userId + ". Total active users: " + activeSessionsByUserId.size());
        } else {
            System.err.println("[WS_SERVICE] ERROR: userId is null when attempting to add session " + session.getId() + " to activeSessionsByUserId.");
        }
    }

    public void removeSession(UUID chatId, WebSocketSession session) {
        Set<WebSocketSession> chatSessions = sessions.get(chatId);
        if (chatSessions != null) {
            chatSessions.remove(session);
            if (chatSessions.isEmpty()) {
                sessions.remove(chatId);
                System.out.println("[WS_SERVICE] DEBUG: Chat " + chatId + " removed as no sessions left.");
            }
            System.out.println("[WS_SERVICE] DEBUG: Session " + session.getId() + " removed from chat " + chatId + ". Remaining for chat: " + (sessions.containsKey(chatId) ? sessions.get(chatId).size() : 0));
        }
    }

    public void removeSessionFromAllChats(WebSocketSession session) {
        UUID userId = (UUID) session.getAttributes().get("userId");
        if (userId != null) {
            activeSessionsByUserId.remove(userId);
            System.out.println("[WS_SERVICE] INFO: Session " + session.getId() + " REMOVED from activeSessionsByUserId for user " + userId + ". Total active users: " + activeSessionsByUserId.size());
        } else {
            System.err.println("[WS_SERVICE] ERROR: userId is null when attempting to remove session " + session.getId() + " from activeSessionsByUserId.");
        }

        // Iterate over a copy to prevent ConcurrentModificationException
        for (Set<WebSocketSession> chatSessions : new ArrayList<>(sessions.values())) {
            chatSessions.remove(session);
        }
        sessions.entrySet().removeIf(entry -> entry.getValue().isEmpty());
        System.out.println("[WS_SERVICE] DEBUG: Session " + session.getId() + " removed from all chat-specific session sets.");
    }

    public void broadcastMessage(UUID chatId, TextMessage message, UUID senderId, UserService userService) throws Exception {
        Set<WebSocketSession> chatSessions = sessions.get(chatId);
        if (chatSessions != null && !chatSessions.isEmpty()) {
            System.out.println("[WS_SERVICE] INFO: Broadcasting message to chat " + chatId + ". Found " + chatSessions.size() + " active sessions.");
            for (WebSocketSession session : chatSessions) {
                if (session.isOpen()) {
                    String authHeader = extractAuthorizationHeader(session);
                    // Re-verifying user on every message broadcast is inefficient. Consider caching or passing User object.
                    User sessionUser = userService.getRequestUser(authHeader);

                    if (!sessionUser.getId().equals(senderId)) {
                        session.sendMessage(message);
                        System.out.println("[WS_SERVICE] DEBUG: Message sent to session " + session.getId() + " (user: " + sessionUser.getUsername() + ").");
                    } else {
                        System.out.println("[WS_SERVICE] DEBUG: Skipped sending message to sender (" + sessionUser.getUsername() + ") in session " + session.getId() + ".");
                    }
                } else {
                    System.out.println("[WS_SERVICE] WARN: Session " + session.getId() + " is closed. Cannot send message. Consider cleaning up dead sessions.");
                }
            }
        } else {
            System.out.println("[WS_SERVICE] INFO: No active sessions found for chat " + chatId + " to broadcast message.");
        }
    }

    public WebSocketSession getSessionByUserId(UUID userId) {
        WebSocketSession session = activeSessionsByUserId.get(userId);
        System.out.println("[WS_SERVICE] DEBUG: getSessionByUserId for user " + userId + ": " + (session != null ? "Found (ID: " + session.getId() + ", Open: " + session.isOpen() + ")" : "Not found"));
        return session;
    }

    private String extractAuthorizationHeader(WebSocketSession session) {
        Map<String, Object> attributes = session.getAttributes();
        String authHeader = (String) attributes.get("authorization");
        if (authHeader == null) {
            System.err.println("[WS_SERVICE] WARN: 'authorization' attribute not found in session " + session.getId() + " during header extraction.");
        }
        return authHeader;
    }
}