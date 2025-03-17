package com.greedann.chatservice.repository;

import java.util.UUID;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.greedann.chatservice.model.Message;
import com.greedann.chatservice.model.Chat;

@Repository
public interface MessageRepository extends JpaRepository<Message, UUID> {
    List<Message> findAllByChat(Chat chat);

}
