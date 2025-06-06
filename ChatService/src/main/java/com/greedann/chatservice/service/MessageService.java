package com.greedann.chatservice.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.web.socket.TextMessage;
import com.fasterxml.jackson.databind.ObjectMapper;

import com.greedann.chatservice.model.Chat;
import com.greedann.chatservice.model.Message;
import com.greedann.chatservice.model.User;
import com.greedann.chatservice.repository.MessageRepository;
import com.greedann.chatservice.dto.WebSocketMessage;

@Service
public class MessageService {
    private final UserService userService;
    private final ChatService chatService;
    private final MessageRepository messageRepository;
    private final WebSocketService webSocketService;
    private final ObjectMapper objectMapper;

    public MessageService(UserService userService, ChatService chatService, MessageRepository messageRepository, 
                         WebSocketService webSocketService, ObjectMapper objectMapper) {
        this.userService = userService;
        this.chatService = chatService;
        this.messageRepository = messageRepository;
        this.webSocketService = webSocketService;
        this.objectMapper = objectMapper;
    }

    public Message sendMessage(UUID chatId, String message, String authorizationHeader) {
        User requestUser = userService.getRequestUser(authorizationHeader);
        Chat chat = chatService.getChat(chatId);
        Message newMessage = Message.builder().chat(chat).sender(requestUser).content(message)
                .timestamp(LocalDateTime.now()).isRead(false).build();

        Message savedMessage = messageRepository.save(newMessage);
        
        try {
            WebSocketMessage webSocketMessage = new WebSocketMessage(chatId.toString(), message);
            String messageJson = objectMapper.writeValueAsString(webSocketMessage);
            webSocketService.broadcastMessage(chatId, new TextMessage(messageJson), requestUser.getId(), userService);
        } catch (Exception e) {
            System.err.println("Error sending message through WebSocket: " + e.getMessage());
        }

        return savedMessage;
    }

    public List<Message> getAllMessages(UUID chatId) {
        Chat chat = chatService.getChat(chatId);
        return messageRepository.findAllByChat(chat);
    }
}
