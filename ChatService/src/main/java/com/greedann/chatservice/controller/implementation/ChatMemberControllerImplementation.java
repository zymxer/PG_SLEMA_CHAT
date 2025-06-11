package com.greedann.chatservice.controller.implementation;

import com.greedann.chatservice.controller.api.ChatMemberController;
import com.greedann.chatservice.dto.ChatMemberDto;
import com.greedann.chatservice.dto.CreateOrUpdateChat;
import com.greedann.chatservice.model.ChatMember;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;
import java.time.LocalDateTime;

import com.greedann.chatservice.service.ChatMemberService;
import com.greedann.chatservice.service.ChatService;
import com.greedann.chatservice.service.UserService;
import com.greedann.chatservice.model.Chat;

@RestController
public class ChatMemberControllerImplementation implements ChatMemberController {
    private final ChatMemberService chatMemberService;
    private final UserService userService;
    private final ChatService chatService;

    public ChatMemberControllerImplementation(ChatMemberService chatMemberService, UserService userService, ChatService chatService) {
        this.chatMemberService = chatMemberService;
        this.userService = userService;
        this.chatService = chatService;
    }

    @Override
    public ResponseEntity<ChatMember> addChatMember(@PathVariable UUID chatId, @RequestBody ChatMemberDto chatMember, @RequestHeader("Authorization") String authorizationHeader) {
        if (chatMember == null || chatMember.getUsername() == null) {
            return ResponseEntity.badRequest().build();
        }

        ChatMember newChatMember = new ChatMember();
        newChatMember.setUser(userService.getUser(chatMember.getUsername()));
        
        if (newChatMember.getUser() == null) {
            return ResponseEntity.notFound().build();
        }

        if (chatMemberService.isUserAlreadyInChat(chatId, newChatMember.getUser().getId())) {
            return ResponseEntity.status(409).build(); // Conflict: user already in chat
        }
        newChatMember.setRole(chatMember.getRole());
        newChatMember.setJoinedAt(LocalDateTime.now());
        newChatMember.setChat(chatService.getChat(chatId));
        Chat chat = newChatMember.getChat();
        if (chatMemberService.getAllChatMembersByChatId(chatId).size() >2){
            CreateOrUpdateChat newChat = CreateOrUpdateChat.builder()
                    .name(chat.getName())
                    .isGroup(true)
                    .interlocutorUsername(chatMember.getUsername())
                    .build();
            chatService.updateChat(chatId, newChat, authorizationHeader);
        }

        ChatMember createdChatMember = chatMemberService.createChatMember(newChatMember);
        return ResponseEntity.status(201).body(createdChatMember);
    }

    @Override
    public ResponseEntity<List<ChatMember>> getAllChatMembers(@PathVariable UUID chatId, @RequestHeader("Authorization") String authorizationHeader) {
        List<ChatMember> chatMembers = chatMemberService.getAllChatMembersByChatId(chatId);
        if (chatMembers.isEmpty()) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(chatMembers);
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
