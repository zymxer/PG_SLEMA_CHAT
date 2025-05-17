package com.greedann.chatservice.controller.api;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

import com.greedann.chatservice.dto.CreateOrUpdateChat;
import com.greedann.chatservice.model.Chat;

@RequestMapping("/api/chat")
public interface ChatController {

    @PostMapping
    public ResponseEntity<Chat> createChat(@RequestBody CreateOrUpdateChat chat, @RequestHeader("Authorization") String authorizationHeader);

    @GetMapping
    @ResponseStatus(HttpStatus.OK)
    public ResponseEntity<List<Chat>> getAllChats(@RequestHeader("Authorization") String authorizationHeader);

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteChat(@PathVariable UUID id, @RequestHeader("Authorization") String authorizationHeader);

}
