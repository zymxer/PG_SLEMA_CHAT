package com.greedann.chatservice.controller.implementation;

import java.util.List;
import java.util.UUID;

import com.greedann.chatservice.util.TokenExtractor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.greedann.chatservice.controller.api.MessagesController;
import com.greedann.chatservice.dto.MessageDto;
import com.greedann.chatservice.dto.SendedMessage;
import com.greedann.chatservice.model.Message;
import com.greedann.chatservice.service.MessageService;

@RestController
public class MessagesControllerImplementation implements MessagesController {
    private final MessageService messageService;
    private final TokenExtractor tokenExtractor;

    public MessagesControllerImplementation(MessageService messageService, TokenExtractor tokenExtractor) {
        this.messageService = messageService;
        this.tokenExtractor = tokenExtractor;
    }

    @Override
    public ResponseEntity<?> addMessageWithFile(UUID chatId, String message, MultipartFile file, @RequestHeader("Authorization") String authorizationHeader) {
        Message newMessage = messageService.sendMessage(chatId, message, file, authorizationHeader);
        return ResponseEntity.ok().body(newMessage.getId());
    }

    @Override
    public ResponseEntity<?> addMessage(UUID chatId, SendedMessage message, @RequestHeader("Authorization") String authorizationHeader) {
        Message newMessage = messageService.sendMessage(chatId, message.getText(), null, authorizationHeader);
        return ResponseEntity.ok().body(newMessage.getId());
    }

    @Override
    public ResponseEntity<List<MessageDto>> getAllMessages(UUID chatId, @RequestHeader("Authorization") String authorizationHeader) {
        List<Message> messages = messageService.getAllMessages(chatId);
        List<MessageDto> messageDtos = messages.stream().map(MessageDto::fromMessage).toList();

        return ResponseEntity.ok().body(messageDtos);
    }

    @Override
    public ResponseEntity<Void> deleteMessage(UUID chatId, UUID id, @RequestHeader("Authorization") String authorizationHeader) {
        return null;
    }

    @Override
    public ResponseEntity<Message> updateMessage(UUID chatId, UUID id, Message message, @RequestHeader("Authorization") String authorizationHeader) {
        return null;
    }
}
