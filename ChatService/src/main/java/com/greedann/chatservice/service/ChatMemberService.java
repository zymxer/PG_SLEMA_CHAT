package com.greedann.chatservice.service;

import org.springframework.stereotype.Service;

import com.greedann.chatservice.model.ChatMember;
import com.greedann.chatservice.model.User;

import com.greedann.chatservice.repository.ChatMemberRepository;

import java.util.List;

@Service
public class ChatMemberService {
    private final ChatMemberRepository chatMemberRepository;

    public ChatMemberService(ChatMemberRepository chatMemberRepository) {
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

}
