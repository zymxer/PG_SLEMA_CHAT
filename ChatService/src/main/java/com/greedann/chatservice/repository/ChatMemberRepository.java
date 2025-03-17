package com.greedann.chatservice.repository;

import java.util.UUID;
import java.util.List;

import com.greedann.chatservice.model.ChatMember;
import com.greedann.chatservice.model.User;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ChatMemberRepository extends JpaRepository<ChatMember, UUID> {
    List<ChatMember> findAllByUser(User user);
}
