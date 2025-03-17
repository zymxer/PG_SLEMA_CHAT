package com.greedann.chatservice.repository;

import java.util.UUID;

import com.greedann.chatservice.model.MessageReadStatus;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MessageReadStatusRepository extends JpaRepository<MessageReadStatus, UUID> {

}
