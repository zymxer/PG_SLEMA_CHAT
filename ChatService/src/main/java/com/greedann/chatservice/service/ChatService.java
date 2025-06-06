package com.greedann.chatservice.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.UUID;
import java.util.ArrayList;

import org.springframework.stereotype.Service;

import com.greedann.chatservice.dto.CreateOrUpdateChat;
import com.greedann.chatservice.model.Chat;
import com.greedann.chatservice.model.ChatMember;
import com.greedann.chatservice.model.User;
import com.greedann.chatservice.exception.ResourceNotFoundException;
import com.greedann.chatservice.exception.AuthenticationException;

import com.greedann.chatservice.repository.ChatRepository;
import com.greedann.chatservice.repository.ChatMemberRepository;

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
            Chat savedChat = chatRepository.save(newChat);
            User requestUser = userService.getRequestUser(authorizationHeader);
            ChatMember chatMember = ChatMember.builder().chat(savedChat).user(requestUser).role("creator")
                    .joinedAt(LocalDateTime.now()).build();
            chatMemberRepository.save(chatMember);
            return newChat;
        } else {
            Chat newChat = Chat.builder().name(chatName).isGroup(false).createdAt(LocalDateTime.now()).build();
            try {
                User interlocutor = userService.getUser(interlocutorUsername);
                User requestUser = userService.getRequestUser(authorizationHeader);
                if (interlocutor.equals(requestUser)) {
                    throw new ResourceNotFoundException(
                            "You can't add yourself to this chat, because you are already interlocutor");
                }
                ChatMember chatMember1 = ChatMember.builder().chat(newChat).user(interlocutor).role("interlocutor")
                        .joinedAt(LocalDateTime.now()).build();
                ChatMember chatMember2 = ChatMember.builder().chat(newChat).user(requestUser).role("creator")
                        .joinedAt(LocalDateTime.now()).build();
                chatRepository.save(newChat);
                chatMemberRepository.save(chatMember1);
                chatMemberRepository.save(chatMember2);
            } catch (NoSuchElementException e) {
                throw new ResourceNotFoundException("Contact not found: " + interlocutorUsername); // change exception
            }
            return newChat;
        }
    }

    public List<Chat> getAllChats(String authorizationHeader) {
        User requestUser = userService.getRequestUser(authorizationHeader);
        List<ChatMember> chatMembers = chatMemberRepository.findAllByUser(requestUser);
        List<Chat> chats = new ArrayList<>();
        for (ChatMember chatMember : chatMembers) {
            chats.add(chatMember.getChat());
        }
        return chats;
    }

    public Chat getChat(UUID id) {
        return chatRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Chat " + id + " not found"));
    }

    public void deleteChat(UUID id, String authorizationHeader) {
        User requestUser = userService.getRequestUser(authorizationHeader);
        Chat chat = chatRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Chat " + id + " not found"));

        ChatMember chatMember = chatMemberRepository.findByChatAndUser(chat, requestUser)
                .orElseThrow(() -> new AuthenticationException("You do not have permission to delete this chat"));

        if (!"creator".equals(chatMember.getRole())) {
            throw new AuthenticationException("Only creators can delete this chat");
        }

        // Not good but mne vpadlu perepisywat' model chat & chatMember
        List<ChatMember> chatMembers = chatMemberRepository.findAllByChat(chat);
        chatMemberRepository.deleteAll(chatMembers);

        chatRepository.delete(chat);
    }

    public List<Chat> getAllChatsForUser(String username) {
        User user = userService.getUser(username);
        List<ChatMember> chatMembers = chatMemberRepository.findAllByUser(user);
        List<Chat> chats = new ArrayList<>();
        for (ChatMember chatMember : chatMembers) {
            chats.add(chatMember.getChat());
        }
        return chats;
    }

    public List<User> getChatMembers(UUID chatId) {
        Chat chat = chatRepository.findById(chatId)
                .orElseThrow(() -> new ResourceNotFoundException("Chat " + chatId + " not found"));

        List<ChatMember> chatMembers = chatMemberRepository.findAllByChat(chat);
        List<User> users = new ArrayList<>();
        for (ChatMember chatMember : chatMembers) {
            users.add(chatMember.getUser());
        }
        return users;
    }

    public List<Chat> getBroadcastChats(String message, String authorizationHeader) {
        User requestUser = userService.getRequestUser(authorizationHeader);
        if (!userService.isAdmin(requestUser)) {
            throw new AuthenticationException("Only administrators can send messages to all users");
        }

        List<User> allUsers = userService.getAllUsers();
        List<Chat> broadcastChats = new ArrayList<>();

        for (User user : allUsers) {
            if (!user.equals(requestUser)) {
                // check if the user has chat with the requestUser
                List<Chat> userChats = getAllChatsForUser(user.getUsername());
                System.out.println("User chats: " + userChats.size());
                Chat broadCastChat = null;
                for (Chat chat : userChats) {
                    List<User> chatMembers = getChatMembers(chat.getId());
                    if (chatMembers.contains(requestUser)) {
                        broadCastChat = chat;
                        break; // Exit loop if chat exists
                    }
                }
                if (broadCastChat == null) {
                    // If chat does not exist, create a new one
                    CreateOrUpdateChat newChat = CreateOrUpdateChat.builder()
                            .name("Administrator")
                            .isGroup(false)
                            .interlocutorUsername(user.getUsername())
                            .build();
                    broadCastChat = createChat(newChat, authorizationHeader);
                    System.out.println(
                            "New chat created between: " + requestUser.getUsername() + " and " + user.getUsername());
                }
                broadcastChats.add(broadCastChat);
            }
        }

        return broadcastChats;
    }
}
