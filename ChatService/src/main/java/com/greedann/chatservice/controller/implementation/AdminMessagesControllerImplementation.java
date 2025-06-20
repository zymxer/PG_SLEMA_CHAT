package com.greedann.chatservice.controller.implementation;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;

import com.greedann.chatservice.controller.api.AdminMessagesController;
import com.greedann.chatservice.dto.MessageDto;
import com.greedann.chatservice.dto.SendedMessage;
import com.greedann.chatservice.model.Message;
import com.greedann.chatservice.service.MessageService;
import com.greedann.chatservice.model.Chat;
import com.greedann.chatservice.service.ChatService;

import java.util.List;
import java.util.stream.Collectors;

@RestController
public class AdminMessagesControllerImplementation implements AdminMessagesController {

    private final MessageService messageService;
    private final ChatService chatService;

    public AdminMessagesControllerImplementation(MessageService messageService, ChatService chatService) {
        this.messageService = messageService;
        this.chatService = chatService;
    }

    @Override
    public ResponseEntity<List<MessageDto>> broadcastMessage(SendedMessage message, String authorizationHeader) {
        List<Chat> chats = chatService.getBroadcastChats(message.getText(), authorizationHeader);
        if (chats.isEmpty()) {
            return ResponseEntity.noContent().build();
        }
        List<Message> sentMessages = chats.stream()
                .map(chat -> messageService.sendMessage(chat.getId(), message.getText(), message.getFile(),
                        authorizationHeader))
                .toList();

        List<MessageDto> messageDtos = sentMessages.stream()
                .map(MessageDto::fromMessage)
                .collect(Collectors.toList());
        return ResponseEntity.ok(messageDtos);
    }
}