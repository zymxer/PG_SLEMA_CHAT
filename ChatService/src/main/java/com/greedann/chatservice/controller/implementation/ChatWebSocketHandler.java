package com.greedann.chatservice.controller.implementation;

import com.fasterxml.jackson.databind.ObjectMapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.util.List;
import java.util.UUID;
import java.util.Map;

import com.greedann.chatservice.service.MessageService;
import com.greedann.chatservice.service.WebSocketService;
import com.greedann.chatservice.dto.WebSocketMessage;
import com.greedann.chatservice.model.Chat;
import com.greedann.chatservice.service.ChatService;

@Component
public class ChatWebSocketHandler extends TextWebSocketHandler {

    @Autowired
    private MessageService messageService;
    
    @Autowired
    private ChatService chatService;
    
    @Autowired
    private WebSocketService webSocketService;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        List<Chat> chats = chatService.getAllChats(extractAuthorizationHeader(session));
        for (Chat chat : chats) {
            webSocketService.addSession(chat.getId(), session);
        }
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        WebSocketMessage webSocketMessage = objectMapper.readValue(message.getPayload(), WebSocketMessage.class);
        UUID chatUuid = UUID.fromString(webSocketMessage.getChatUuid());
        String text = webSocketMessage.getText();

        messageService.sendMessage(chatUuid, text, extractAuthorizationHeader(session));
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        List<Chat> chats = chatService.getAllChats(extractAuthorizationHeader(session));
        for (Chat chat : chats) {
            webSocketService.removeSession(chat.getId(), session);
        }
    }

    private String extractAuthorizationHeader(WebSocketSession session) {
        Map<String, Object> attributes = session.getAttributes();
        return (String) attributes.get("authorization");
    }
}
