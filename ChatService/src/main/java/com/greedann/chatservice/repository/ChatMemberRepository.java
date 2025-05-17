package com.greedann.chatservice.repository;

import java.util.UUID;
import java.util.List;
import java.util.Optional;

import com.greedann.chatservice.model.ChatMember;
import com.greedann.chatservice.model.User;
import com.greedann.chatservice.model.Chat;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ChatMemberRepository extends JpaRepository<ChatMember, UUID> {
    List<ChatMember> findAllByUser(User user);
    Optional<ChatMember> findByChatAndUser(Chat chat, User user);
    List<ChatMember> findAllByChat(Chat chat);
}
