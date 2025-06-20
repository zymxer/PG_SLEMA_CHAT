package com.greedann.chatservice.controller.implementation;

import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.RequiredArgsConstructor;
import org.springframework.lang.NonNull;
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
@RequiredArgsConstructor
public class ChatWebSocketHandler extends TextWebSocketHandler {

    private final MessageService messageService;
    private final ChatService chatService;
    private final WebSocketService webSocketService;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void afterConnectionEstablished(@NonNull WebSocketSession session) throws Exception {
        System.out.println("[WS_HANDLER] INFO: WebSocketSession established with ID: " + session.getId());
        String authorizationHeader = extractAuthorizationHeader(session);
        UUID userId = (UUID) session.getAttributes().get("userId");
        System.out.println("[WS_HANDLER] DEBUG: Auth Header: " + (authorizationHeader != null ? "Present" : "Missing") + ", User ID from session attributes: " + (userId != null ? userId : "Missing"));

        if (authorizationHeader == null || userId == null) {
            System.err.println("[WS_HANDLER] ERROR: Auth header or User ID missing for session " + session.getId() + ". Closing connection.");
            session.close(CloseStatus.SERVER_ERROR.withReason("Unauthorized or User ID missing"));
            return;
        }

        try {
            // Register the session by userId immediately for direct user-session mapping
            webSocketService.addSessionByUserId(userId, session);
            System.out.println("[WS_HANDLER] INFO: Session " + session.getId() + " registered by User ID " + userId + " in WebSocketService.");

            // Fetch and register the session for all existing chats the user is part of
            List<Chat> chats = chatService.getAllChats(authorizationHeader);
            System.out.println("[WS_HANDLER] DEBUG: Found " + chats.size() + " existing chats for user " + userId + ".");
            if (chats.isEmpty()) {
                System.out.println("[WS_HANDLER] INFO: No existing chats found for user " + userId + ". This is normal if the user has no chats yet.");
            }
            for (Chat chat : chats) {
                webSocketService.addSession(chat.getId(), session);
                System.out.println("[WS_HANDLER] DEBUG: Session " + session.getId() + " added to existing chat: " + chat.getId() + ".");
            }
            System.out.println("[WS_HANDLER] INFO: WebSocket session setup complete for " + session.getId() + ".");
        } catch (Exception e) {
            System.err.println("[WS_HANDLER] ERROR: Failed to initialize WebSocket session for " + session.getId() + ": " + e.getMessage());
            session.close(CloseStatus.SERVER_ERROR.withReason("Failed to initialize WebSocket session"));
        }
    }

    @Override
    protected void handleTextMessage(@NonNull WebSocketSession session,
                                     @NonNull TextMessage message) throws Exception {
        System.out.println("[WS_HANDLER] INFO: Received text message from session: " + session.getId());
        System.out.println("[WS_HANDLER] DEBUG: Message Payload: " + message.getPayload());

        String authorizationHeader = extractAuthorizationHeader(session);
        if (authorizationHeader == null) {
            System.err.println("[WS_HANDLER] ERROR: Auth header missing for session " + session.getId() + " during message handling. Closing connection.");
            session.close(CloseStatus.SERVER_ERROR.withReason("Unauthorized"));
            return;
        }

        try {
            WebSocketMessage webSocketMessage = objectMapper.readValue(message.getPayload(), WebSocketMessage.class);
            UUID chatUuid = UUID.fromString(webSocketMessage.getChatUuid());
            String text = webSocketMessage.getText();
            System.out.println("[WS_HANDLER] INFO: Parsed message for chat " + chatUuid + ", text: '" + text + "'.");

            messageService.sendMessage(chatUuid, text, null, authorizationHeader);
            System.out.println("[WS_HANDLER] INFO: Message successfully passed to MessageService for chat " + chatUuid + ".");

        } catch (JsonMappingException e) {
            System.err.println("[WS_HANDLER] ERROR: JSON mapping error for message from " + session.getId() + ": " + e.getMessage());
            System.err.println("[WS_HANDLER] DEBUG: Received JSON payload: " + message.getPayload());
            session.sendMessage(new TextMessage("Error: Invalid message format. " + e.getMessage()));
        } catch (Exception e) {
            System.err.println("[WS_HANDLER] ERROR: Unexpected error while handling message from " + session.getId() + ": " + e.getMessage());
            session.sendMessage(new TextMessage("Error: An unexpected error occurred."));
        }
    }

    @Override
    public void afterConnectionClosed(@NonNull WebSocketSession session,
                                      @NonNull CloseStatus status) {
        System.out.println("[WS_HANDLER] INFO: WebSocketSession closed: " + session.getId() + " Status: " + status.getCode() + " (" + status.getReason() + ")");
        webSocketService.removeSessionFromAllChats(session);
        System.out.println("[WS_HANDLER] INFO: Session " + session.getId() + " successfully removed from WebSocketService.");
    }

    private String extractAuthorizationHeader(WebSocketSession session) {
        Map<String, Object> attributes = session.getAttributes();
        String authHeader = (String) attributes.get("authorization");
        if (authHeader == null) {
            System.err.println("[WS_HANDLER] WARN: 'authorization' attribute not found in session " + session.getId() + " during header extraction.");
        }
        return authHeader;
    }
}