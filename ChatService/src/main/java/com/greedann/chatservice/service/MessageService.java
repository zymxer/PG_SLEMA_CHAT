package com.greedann.chatservice.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.greedann.chatservice.model.Chat;
import com.greedann.chatservice.model.Message;
import com.greedann.chatservice.model.User;
import com.greedann.chatservice.repository.MessageRepository;

@Service
public class MessageService {
    private final UserService userService;
    private final ChatService chatService;
    private final MessageRepository messageRepository;

    public MessageService(UserService userService, ChatService chatService, MessageRepository messageRepository) {
        this.userService = userService;
        this.chatService = chatService;
        this.messageRepository = messageRepository;
    }

    public Message sendMessage(UUID chatId, String message, String authorizationHeader) {
        User requestUser = userService.getRequestUser(authorizationHeader);
        Chat chat = chatService.getChat(chatId);
        Message newMessage = Message.builder().chat(chat).sender(requestUser).content(message)
                .timestamp(LocalDateTime.now()).isRead(false).build();

       return messageRepository.save(newMessage);
    }

    public List<Message> getAllMessages(UUID chatId) {
        Chat chat = chatService.getChat(chatId);
        return messageRepository.findAllByChat(chat);
    }
}
