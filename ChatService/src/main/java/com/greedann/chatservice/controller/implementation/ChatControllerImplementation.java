package com.greedann.chatservice.controller.implementation;

import com.greedann.chatservice.controller.api.ChatController;
import com.greedann.chatservice.dto.CreateOrUpdateChat;
import com.greedann.chatservice.model.Chat;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

import com.greedann.chatservice.service.ChatService;

import java.util.List;

@RestController
public class ChatControllerImplementation implements ChatController {
    private final ChatService chatService;

    public ChatControllerImplementation(ChatService chatService) {
        this.chatService = chatService;
    }

    @Override
    public ResponseEntity<Chat> createChat(@RequestBody CreateOrUpdateChat chat, @RequestHeader("Authorization") String authorizationHeader) {
        Chat newChat = chatService.createChat(chat, authorizationHeader);
        return ResponseEntity.ok().body(newChat);
    }

    @Override
    public ResponseEntity<List<Chat>> getAllChats(@RequestHeader("Authorization") String authorizationHeader) {
        List<Chat> chats = chatService.getAllChats(authorizationHeader);
        return ResponseEntity.ok().body(chats);
    }

    @Override
    public ResponseEntity<Void> deleteChat(@PathVariable Long id, @RequestHeader("Authorization") String authorizationHeader) {
        return null;
    }

}
