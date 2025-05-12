package com.greedann.chatservice.controller.implementation;

import com.fasterxml.jackson.databind.ObjectMapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Set;
import java.util.List;

import com.greedann.chatservice.service.MessageService;
import com.greedann.chatservice.dto.WebSocketMessage;
import com.greedann.chatservice.model.Chat;
import com.greedann.chatservice.service.ChatService;

@Component
public class ChatWebSocketHandler extends TextWebSocketHandler {

    @Autowired
    private MessageService messageService;
    @Autowired
    private ChatService chatService;

    private final ObjectMapper objectMapper = new ObjectMapper();
    // Store sessions for each chat
    private static final Map<UUID, Set<WebSocketSession>> sessions = new ConcurrentHashMap<>();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        List<Chat> chats = chatService.getAllChats(extractAuthorizationHeader(session));
        for (Chat chat : chats) {
            UUID chatId = chat.getId();
            sessions.computeIfAbsent(chatId, k -> ConcurrentHashMap.newKeySet()).add(session);
        }
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        WebSocketMessage webSocketMessage = objectMapper.readValue(message.getPayload(), WebSocketMessage.class);
        UUID chatUuid = UUID.fromString(webSocketMessage.getChatUuid());
        String text = webSocketMessage.getText();

        messageService.sendMessage(chatUuid, text, extractAuthorizationHeader(session));

        // Broadcast the message to all sessions in the chat
        Set<WebSocketSession> chatSessions = sessions.get(chatUuid);
        if (chatSessions != null) {
            for (WebSocketSession chatSession : chatSessions) {
                if (chatSession.isOpen() && chatSession!=session) {
                    chatSession.sendMessage(new TextMessage(message.getPayload()));
                }
            }
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        List<Chat> chats = chatService.getAllChats(extractAuthorizationHeader(session));
        for (Chat chat : chats) {
            UUID chatId = chat.getId();
            Set<WebSocketSession> chatSessions = sessions.get(chatId);
            if (chatSessions != null) {
                chatSessions.remove(session);
                if (chatSessions.isEmpty()) {
                    sessions.remove(chatId);
                }
            }
        }
        
    }

    private String extractAuthorizationHeader(WebSocketSession session) {
        Map<String, Object> attributes = session.getAttributes();
        return (String) attributes.get("authorization");
    }

}
