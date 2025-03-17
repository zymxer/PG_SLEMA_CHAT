package com.greedann.chatservice.controller.api;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import com.greedann.chatservice.model.ChatMember;

@RequestMapping("/api/chat/{chatId}/members")
public interface ChatMemberController {
    @PostMapping
    public ResponseEntity<ChatMember> addChatMember(@RequestBody ChatMember chatMember, @RequestHeader("Authorization") String authorizationHeader);

    @GetMapping
    @ResponseStatus(HttpStatus.OK)
    public ResponseEntity<List<ChatMember>> getAllChatMembers(@PathVariable Long chatId, @RequestHeader("Authorization") String authorizationHeader);

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteChatMember(@PathVariable Long chatId, @PathVariable Long id,@RequestHeader("Authorization") String authorizationHeader);

    @PatchMapping("/{id}")
    public ResponseEntity<ChatMember> updateChatMember(@PathVariable Long chatId, @PathVariable Long id,
            @RequestBody ChatMember chatMember, @RequestHeader("Authorization") String authorizationHeader);

}
