package com.greedann.chatservice.service;

import org.springframework.stereotype.Service;

import com.greedann.chatservice.model.Chat;
import com.greedann.chatservice.model.ChatMember;
import com.greedann.chatservice.model.User;

import com.greedann.chatservice.repository.ChatMemberRepository;

import java.util.List;
import java.util.UUID;

@Service
public class ChatMemberService {
    private final ChatMemberRepository chatMemberRepository;
    private final ChatService chatService;

    public ChatMemberService(ChatMemberRepository chatMemberRepository, ChatService chatService) {
        this.chatService = chatService;
        this.chatMemberRepository = chatMemberRepository;
    }

    public List<ChatMember> getChatMembersByUser(User user) {
        return chatMemberRepository.findAllByUser(user);
    }

    public ChatMember createChatMember(ChatMember chatMember) {
        return chatMemberRepository.save(chatMember);
    }

    public void deleteChatMember(ChatMember chatMember) {
        chatMemberRepository.delete(chatMember);
    }

    public List<ChatMember> getAllChatMembersByChatId(UUID chatId) {
        Chat chat = chatService.getChat(chatId);
        if (chat == null) {
            throw new IllegalArgumentException("Chat with ID " + chatId + " does not exist.");
        }
        return chatMemberRepository.findAllByChat(chat);
    }

    public boolean isUserAlreadyInChat(UUID chatId, UUID userId) {
        return chatMemberRepository.existsByChatIdAndUserId(chatId, userId);
    }

}
