package com.greedann.chatservice.controller.api;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

import com.greedann.chatservice.dto.ChatMemberDto;
import com.greedann.chatservice.model.ChatMember;

@RequestMapping("/api/chat/{chatId}/members")
public interface ChatMemberController {
    @PostMapping
    public ResponseEntity<ChatMember> addChatMember(@PathVariable UUID chatId, @RequestBody ChatMemberDto chatMember, @RequestHeader("Authorization") String authorizationHeader);

    @GetMapping
    @ResponseStatus(HttpStatus.OK)
    public ResponseEntity<List<ChatMember>> getAllChatMembers(@PathVariable UUID chatId, @RequestHeader("Authorization") String authorizationHeader);

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteChatMember(@PathVariable UUID chatId, @PathVariable UUID id,@RequestHeader("Authorization") String authorizationHeader);

    @PatchMapping("/{id}")
    public ResponseEntity<ChatMember> updateChatMember(@PathVariable UUID chatId, @PathVariable UUID id,
            @RequestBody ChatMember chatMember, @RequestHeader("Authorization") String authorizationHeader);

}
