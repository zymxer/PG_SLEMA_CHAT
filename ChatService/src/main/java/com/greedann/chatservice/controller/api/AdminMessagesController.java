package com.greedann.chatservice.controller.api;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import com.greedann.chatservice.dto.MessageDto;
import com.greedann.chatservice.dto.SendedMessage;

@RequestMapping("/api/admin/messages")
public interface AdminMessagesController {
    
    @PostMapping("/broadcast")
    @ResponseStatus(HttpStatus.OK)
    public ResponseEntity<List<MessageDto>> broadcastMessage(@RequestBody SendedMessage message, @RequestHeader("Authorization") String authorizationHeader);
} 