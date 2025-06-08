package com.greedann.chatservice.controller.implementation;

import com.greedann.chatservice.controller.api.ChatMemberController;
import com.greedann.chatservice.model.ChatMember;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
public class ChatMemberControllerImplementation implements ChatMemberController {
    @Override
    public ResponseEntity<ChatMember> addChatMember(@RequestBody ChatMember chatMember, @RequestHeader("Authorization") String authorizationHeader) {
        return null;
    }

    @Override
    public ResponseEntity<List<ChatMember>> getAllChatMembers(@PathVariable UUID chatId, @RequestHeader("Authorization") String authorizationHeader) {
        return ResponseEntity.ok(List.of());
    }

    @Override
    public ResponseEntity<Void> deleteChatMember(@PathVariable UUID chatId, @PathVariable UUID id, @RequestHeader("Authorization") String authorizationHeader) {
        return null;
    }

    @Override
    public ResponseEntity<ChatMember> updateChatMember(@PathVariable UUID chatId, @PathVariable UUID id,
            @RequestBody ChatMember chatMember, @RequestHeader("Authorization") String authorizationHeader) {
        return null;
    }

}
