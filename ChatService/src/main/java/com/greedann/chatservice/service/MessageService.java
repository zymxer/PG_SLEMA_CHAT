package com.greedann.chatservice.service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.socket.TextMessage;
import com.fasterxml.jackson.databind.ObjectMapper;

import com.greedann.chatservice.model.Chat;
import com.greedann.chatservice.model.Message;
import com.greedann.chatservice.model.User;
import com.greedann.chatservice.repository.MessageRepository;

@Service
public class MessageService {
    private final UserService userService;
    private final ChatService chatService;
    private final MessageRepository messageRepository;
    private final WebSocketService webSocketService;
    private final ObjectMapper objectMapper;

    @Value("${file.upload-dir}")
    private String uploadDir;

    public MessageService(UserService userService, ChatService chatService, MessageRepository messageRepository, 
                         WebSocketService webSocketService, ObjectMapper objectMapper) {
        this.userService = userService;
        this.chatService = chatService;
        this.messageRepository = messageRepository;
        this.webSocketService = webSocketService;
        this.objectMapper = objectMapper;
    }

    public Message sendMessage(UUID chatId, String message, MultipartFile file, String authorizationHeader) {
        User requestUser = userService.getRequestUser(authorizationHeader);
        Chat chat = chatService.getChat(chatId);
        
        Message newMessage = Message.builder()
                .chat(chat)
                .sender(requestUser)
                .content(message)
                .timestamp(LocalDateTime.now())
                .isRead(false)
                .build();

        if (file != null && !file.isEmpty()) {
            try {
                String fileName = UUID.randomUUID().toString() + "_" + file.getOriginalFilename();
                Path uploadPath = Paths.get(uploadDir);
                if (!Files.exists(uploadPath)) {
                    Files.createDirectories(uploadPath);
                }
                
                Path filePath = uploadPath.resolve(fileName);
                Files.copy(file.getInputStream(), filePath);
                
                newMessage.setFileName(file.getOriginalFilename());
                newMessage.setFileType(file.getContentType());
                newMessage.setFileUrl("/uploads/" + fileName);
            } catch (IOException e) {
                throw new RuntimeException("Could not store file " + file.getOriginalFilename(), e);
            }
        }

        Message savedMessage = messageRepository.save(newMessage);
        
        try {
            String messageJson = objectMapper.writeValueAsString(savedMessage);
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
