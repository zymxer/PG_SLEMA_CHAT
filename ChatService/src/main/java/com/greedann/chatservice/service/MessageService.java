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

    public Message sendMessage(UUID chatId, String messageContent, MultipartFile file, String authorizationHeader) {
        User requestUser = userService.getRequestUser(authorizationHeader);
        Chat chat = chatService.getChat(chatId);

        // --- FIX 1 (Backend): Set content to empty string if it's a file message or null ---
        // Ensures content is not null or "Required" string if no actual text
        String finalContent = (messageContent != null && !messageContent.trim().isEmpty()) ? messageContent.trim() : "";
        // --- END FIX 1 ---

        Message.MessageBuilder messageBuilder = Message.builder()
                .chat(chat)
                .sender(requestUser)
                .content(finalContent) // Use the cleaned content
                .timestamp(LocalDateTime.now())
                .isRead(false);

        if (file != null && !file.isEmpty()) {
            try {
                String originalFileName = file.getOriginalFilename();
                String fileExtension = "";
                if (originalFileName != null && originalFileName.contains(".")) {
                    fileExtension = originalFileName.substring(originalFileName.lastIndexOf("."));
                }
                String uniqueFileName = UUID.randomUUID().toString() + fileExtension; // Use original extension

                Path uploadPath = Paths.get(uploadDir);
                if (!Files.exists(uploadPath)) {
                    Files.createDirectories(uploadPath);
                }

                Path filePath = uploadPath.resolve(uniqueFileName);
                Files.copy(file.getInputStream(), filePath);

                // --- FIX 2 (Backend): Determine and set correct fileType ---
                String determinedFileType = file.getContentType(); // Start with what MultipartFile gives

                // Fallback 1: Use Files.probeContentType
                if (determinedFileType == null || determinedFileType.equals("application/octet-stream")) {
                    try {
                        String probedType = Files.probeContentType(filePath);
                        if (probedType != null && !probedType.isEmpty()) {
                            determinedFileType = probedType;
                        }
                    } catch (IOException e) {
                        System.err.println("Error probing content type for " + filePath + ": " + e.getMessage());
                    }
                }

                // Fallback 2: Infer from file extension if still unknown or generic
                if (determinedFileType == null || determinedFileType.equals("application/octet-stream")) {
                    if (originalFileName != null) {
                        String lowerCaseFileName = originalFileName.toLowerCase();
                        if (lowerCaseFileName.endsWith(".jpg") || lowerCaseFileName.endsWith(".jpeg")) {
                            determinedFileType = "image/jpeg";
                        } else if (lowerCaseFileName.endsWith(".png")) {
                            determinedFileType = "image/png";
                        } else if (lowerCaseFileName.endsWith(".gif")) {
                            determinedFileType = "image/gif";
                        } else if (lowerCaseFileName.endsWith(".bmp")) {
                            determinedFileType = "image/bmp";
                        } else if (lowerCaseFileName.endsWith(".webp")) {
                            determinedFileType = "image/webp";
                        }
                        // Add more image/video/audio types if needed
                    }
                }
                // Final fallback if all else fails (though should be rare for common images from picker)
                if (determinedFileType == null || determinedFileType.isEmpty() || determinedFileType.equals("application/octet-stream")) {
                    // Default to a common image type if it's likely an image by extension
                    if (originalFileName != null && (originalFileName.toLowerCase().endsWith(".jpg") || originalFileName.toLowerCase().endsWith(".jpeg") || originalFileName.toLowerCase().endsWith(".png") || originalFileName.toLowerCase().endsWith(".gif") || originalFileName.toLowerCase().endsWith(".bmp") || originalFileName.toLowerCase().endsWith(".webp"))) {
                        determinedFileType = "image/jpeg"; // Most common image type
                    } else {
                        determinedFileType = "application/octet-stream"; // Keep generic if still unsure
                    }
                }
                // --- END FIX 2 ---

                messageBuilder
                        .fileName(originalFileName) // Original filename for display
                        .fileType(determinedFileType) // Use the determined type
                        .fileUrl("/uploads/" + uniqueFileName); // Unique filename for URL
            } catch (IOException e) {
                System.err.println("Error storing file " + file.getOriginalFilename() + ": " + e.getMessage());
                throw new RuntimeException("Could not store file " + file.getOriginalFilename(), e);
            }
        }

        Message newMessage = messageBuilder.build();
        Message finalSavedMessage = messageRepository.save(newMessage); // Ensure final version from DB

        try {
            String messageJson = objectMapper.writeValueAsString(finalSavedMessage);
            webSocketService.broadcastMessage(chatId, new TextMessage(messageJson), requestUser.getId(), userService);
        } catch (Exception e) {
            System.err.println("Error sending message through WebSocket: " + e.getMessage());
        }

        return finalSavedMessage;
    }

    public List<Message> getAllMessages(UUID chatId) {
        Chat chat = chatService.getChat(chatId);
        return messageRepository.findAllByChat(chat);
    }
}