package com.greedann.chatservice.controller.implementation;

import com.greedann.chatservice.controller.api.ChatMemberController;
import com.greedann.chatservice.model.ChatMember;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
public class ChatMemberControllerImplementation implements ChatMemberController {
    @Override
    public ResponseEntity<ChatMember> addChatMember(@RequestBody ChatMember chatMember, @RequestHeader("Authorization") String authorizationHeader) {
        return null;
    }

    @Override
    public ResponseEntity<List<ChatMember>> getAllChatMembers(@PathVariable Long chatId, @RequestHeader("Authorization") String authorizationHeader) {
        return ResponseEntity.ok().body(List.of(ChatMember.builder().build(), ChatMember.builder().build()));
    }

    @Override
    public ResponseEntity<Void> deleteChatMember(@PathVariable Long chatId, @PathVariable Long id, @RequestHeader("Authorization") String authorizationHeader) {
        return null;
    }

    @Override
    public ResponseEntity<ChatMember> updateChatMember(@PathVariable Long chatId, @PathVariable Long id,
            @RequestBody ChatMember chatMember, @RequestHeader("Authorization") String authorizationHeader) {
        return null;
    }

}
