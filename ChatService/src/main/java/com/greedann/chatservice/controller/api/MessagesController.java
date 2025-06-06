package com.greedann.chatservice.controller.api;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

import com.greedann.chatservice.dto.MessageDto;
import com.greedann.chatservice.dto.SendedMessage;
import com.greedann.chatservice.model.Message;

@RequestMapping("/api/chat/{chatId}/messages")
public interface MessagesController {

    @PostMapping(consumes = {"multipart/form-data"})
    public ResponseEntity<?> addMessageWithFile(
        @PathVariable UUID chatId,
        @RequestPart(value = "message") String message,
        @RequestPart(value = "file", required = false) MultipartFile file,
        @RequestHeader("Authorization") String authorizationHeader);

    @PostMapping(consumes = {"application/json"})
    public ResponseEntity<?> addMessage(
        @PathVariable UUID chatId,
        @RequestBody SendedMessage message,
        @RequestHeader("Authorization") String authorizationHeader);

    @GetMapping
    @ResponseStatus(HttpStatus.OK)
    public ResponseEntity<List<MessageDto>> getAllMessages(@PathVariable UUID chatId, @RequestHeader("Authorization") String authorizationHeader);

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMessage(@PathVariable UUID chatId, @PathVariable UUID id, @RequestHeader("Authorization") String authorizationHeader);

    @PatchMapping("/{id}")
    public ResponseEntity<Message> updateMessage(@PathVariable UUID chatId, @PathVariable UUID id,
            @RequestBody Message message, @RequestHeader("Authorization") String authorizationHeader);
}