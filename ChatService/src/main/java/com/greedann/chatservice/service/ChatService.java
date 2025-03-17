package com.greedann.chatservice.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.ArrayList;

import org.springframework.stereotype.Service;

import com.greedann.chatservice.dto.CreateOrUpdateChat;
import com.greedann.chatservice.model.Chat;
import com.greedann.chatservice.model.ChatMember;
import com.greedann.chatservice.model.User;

import com.greedann.chatservice.repository.ChatRepository;
import com.greedann.chatservice.repository.ChatMemberRepository;
import org.springframework.web.bind.annotation.RequestHeader;

@Service
public class ChatService {
    private final UserService userService;
    private final ChatMemberRepository chatMemberRepository;
    private final ChatRepository chatRepository;

    public ChatService(UserService userService, ChatMemberRepository chatMemberRepository,
            ChatRepository chatRepository) {
        this.userService = userService;
        this.chatMemberRepository = chatMemberRepository;
        this.chatRepository = chatRepository;
    }

    public Chat createChat(CreateOrUpdateChat chat, String authorizationHeader) {
        String chatName = chat.getName();
        Boolean isGroup = chat.getIsGroup();
        String interlocutorUsername = chat.getInterlocutorUsername();
        if (isGroup) {
            Chat newChat = Chat.builder().name(chatName).isGroup(true).createdAt(LocalDateTime.now()).build();
            User requestUser = userService.getRequestUser(authorizationHeader);
            ChatMember chatMember = ChatMember.builder().chat(newChat).user(requestUser).role("creator")
                    .joinedAt(LocalDateTime.now()).build();
            chatRepository.save(newChat);
            chatMemberRepository.save(chatMember);
            return newChat;
        } else {
            Chat newChat = Chat.builder().name(chatName).isGroup(false).createdAt(LocalDateTime.now()).build();
            User interlocutor = userService.getUser(interlocutorUsername);
            // TODO: return error if interlocutor is null
            User requestUser = userService.getRequestUser(authorizationHeader);
            // Add interlocutorUuid and requestUserUuid to newChat
            ChatMember chatMember1 = ChatMember.builder().chat(newChat).user(interlocutor).role("interlocutor")
                    .joinedAt(LocalDateTime.now()).build();
            ChatMember chatMember2 = ChatMember.builder().chat(newChat).user(requestUser).role("creator")
                    .joinedAt(LocalDateTime.now()).build();
            chatRepository.save(newChat);
            chatMemberRepository.save(chatMember1);
            chatMemberRepository.save(chatMember2);
            return newChat;
        }
    }

    public List<Chat> getAllChats(String authorizationHeader) {
        User requestUser = userService.getRequestUser(authorizationHeader);
        // ret all ChatMembers where user = requestUser
        List<ChatMember> chatMembers = chatMemberRepository.findAllByUser(requestUser);
        // ret all Chats where chatMembers contains chat
        List<Chat> chats = new ArrayList<>();
        for (ChatMember chatMember : chatMembers) {
            chats.add(chatMember.getChat());
        }
        return chats;
    }

    public Chat getChat(UUID id) {
        return chatRepository.findById(id).orElse(null);
    }

}
