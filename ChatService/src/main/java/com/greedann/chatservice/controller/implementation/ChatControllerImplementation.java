package com.greedann.chatservice.controller.implementation;

import com.greedann.chatservice.controller.api.ChatController;
import com.greedann.chatservice.dto.CreateOrUpdateChat;
import com.greedann.chatservice.model.Chat;
import com.greedann.chatservice.exception.ResourceNotFoundException;
import com.greedann.chatservice.exception.AuthenticationException;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

import com.greedann.chatservice.service.ChatService;

import java.util.List;
import java.util.UUID;

@RestController
public class ChatControllerImplementation implements ChatController {
    private final ChatService chatService;

    public ChatControllerImplementation(ChatService chatService) {
        this.chatService = chatService;
    }

    @Override
    public ResponseEntity<Chat> createChat(@RequestBody CreateOrUpdateChat chat, @RequestHeader("Authorization") String authorizationHeader) {
        try {
            Chat newChat = chatService.createChat(chat, authorizationHeader);
            return ResponseEntity.ok().body(newChat);
        } catch (ResourceNotFoundException e) {
            throw new ResourceNotFoundException("Resource Error: " + e.getMessage());
        } catch (AuthenticationException e) {
            throw new AuthenticationException("Auth Error " + e.getMessage());
        }
    }

    @Override
    public ResponseEntity<List<Chat>> getAllChats(@RequestHeader("Authorization") String authorizationHeader) {
        try {
            List<Chat> chats = chatService.getAllChats(authorizationHeader);
            return ResponseEntity.ok().body(chats);
        } catch (AuthenticationException e) {
            throw new AuthenticationException("Auth Error: " + e.getMessage());
        }
    }

    @Override
    public ResponseEntity<Void> deleteChat(@PathVariable UUID id, @RequestHeader("Authorization") String authorizationHeader) {
        try {
            chatService.deleteChat(id, authorizationHeader);
            return ResponseEntity.ok().build();
        } catch (ResourceNotFoundException e) {
            throw new ResourceNotFoundException("Error: " + e.getMessage());
        } catch (AuthenticationException e) {
            throw new AuthenticationException("Auth Error: " + e.getMessage());
        }
    }
}
