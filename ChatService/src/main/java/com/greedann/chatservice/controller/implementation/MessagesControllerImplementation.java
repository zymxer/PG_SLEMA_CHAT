package com.greedann.chatservice.controller.implementation;

import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.greedann.chatservice.controller.api.MessagesController;
import com.greedann.chatservice.dto.MessageDto; // Assuming this is used for GET all messages
import com.greedann.chatservice.dto.SendedMessage; // Used for incoming JSON message body
import com.greedann.chatservice.model.Message; // Your main Message entity
import com.greedann.chatservice.service.MessageService;

@RestController
public class MessagesControllerImplementation implements MessagesController {
    private final MessageService messageService;

    public MessagesControllerImplementation(MessageService messageService) {
        this.messageService = messageService;
    }

    @Override
    public ResponseEntity<Message> addMessageWithFile(UUID chatId, String message, MultipartFile file, @RequestHeader("Authorization") String authorizationHeader) {
        Message newMessage = messageService.sendMessage(chatId, message, file, authorizationHeader);
        return ResponseEntity.ok().body(newMessage);
    }

    @Override
    public ResponseEntity<Message> addMessage(UUID chatId, SendedMessage message, @RequestHeader("Authorization") String authorizationHeader) {
        Message newMessage = messageService.sendMessage(chatId, message.getText(), null, authorizationHeader);
        return ResponseEntity.ok().body(newMessage);
    }

    @Override
    public ResponseEntity<List<MessageDto>> getAllMessages(UUID chatId, @RequestHeader("Authorization") String authorizationHeader) {
        List<Message> messages = messageService.getAllMessages(chatId);
        List<MessageDto> messageDtos = messages.stream().map(MessageDto::fromMessage).toList();

        return ResponseEntity.ok().body(messageDtos);
    }

    @Override
    public ResponseEntity<Void> deleteMessage(UUID chatId, UUID id, @RequestHeader("Authorization") String authorizationHeader) {
        // TODO: Implement deleteMessage logic
        return ResponseEntity.status(HttpStatus.NOT_IMPLEMENTED).build();
    }

    @Override
    public ResponseEntity<Message> updateMessage(UUID chatId, UUID id, Message message, @RequestHeader("Authorization") String authorizationHeader) {
        // TODO: Implement updateMessage logic
        return ResponseEntity.status(HttpStatus.NOT_IMPLEMENTED).build();
    }
}