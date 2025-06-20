package com.greedann.chatservice.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.UUID;
import java.util.ArrayList;
import java.util.Set;
import java.util.HashSet;
import java.util.stream.Collectors;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.socket.WebSocketSession;

import com.greedann.chatservice.dto.CreateOrUpdateChat;
import com.greedann.chatservice.model.Chat;
import com.greedann.chatservice.model.ChatMember;
import com.greedann.chatservice.model.User;
import com.greedann.chatservice.exception.ResourceNotFoundException;
import com.greedann.chatservice.exception.AuthenticationException;

import com.greedann.chatservice.repository.ChatRepository;
import com.greedann.chatservice.repository.ChatMemberRepository;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final UserService userService;
    private final ChatMemberRepository chatMemberRepository;
    private final ChatRepository chatRepository;
    private final WebSocketService webSocketService;

    public Chat createChat(CreateOrUpdateChat chatDto, String authorizationHeader) {
        System.out.println("[CHAT_SERVICE] INFO: Attempting to create chat.");
        System.out.println("[CHAT_SERVICE] DEBUG: Chat DTO Details -> Name: '" + chatDto.getName() + "', IsGroup: " + chatDto.getIsGroup() + ", InterlocutorUsername: '" + chatDto.getInterlocutorUsername() + "', Member IDs: " + chatDto.getMemberIds());

        String chatName = chatDto.getName();
        Boolean isGroup = chatDto.getIsGroup();
        String interlocutorUsername = chatDto.getInterlocutorUsername();
        List<UUID> memberIds = chatDto.getMemberIds();

        Chat newChat;
        Set<User> membersToRegisterSet = new HashSet<>(); // NEW: Re-initialize for every call

        User requestUser = userService.getRequestUser(authorizationHeader);
        System.out.println("[CHAT_SERVICE] DEBUG: Requesting user for chat creation: " + requestUser.getUsername() + " (ID: " + requestUser.getId() + ")");

        if (isGroup) {
            System.out.println("[CHAT_SERVICE] INFO: Creating a GROUP chat.");
            newChat = Chat.builder().name(chatName).isGroup(true).createdAt(LocalDateTime.now()).build();
            Chat savedChat = chatRepository.save(newChat);
            System.out.println("[CHAT_SERVICE] DEBUG: Group chat saved with ID: " + savedChat.getId() + ", Name: " + savedChat.getName());

            ChatMember creatorMember = ChatMember.builder().chat(savedChat).user(requestUser).role("creator")
                    .joinedAt(LocalDateTime.now()).build();
            chatMemberRepository.save(creatorMember);
            membersToRegisterSet.add(requestUser);
            System.out.println("[CHAT_SERVICE] DEBUG: Creator '" + requestUser.getUsername() + "' added to group chat members.");

            if (memberIds != null && !memberIds.isEmpty()) {
                System.out.println("[CHAT_SERVICE] DEBUG: Processing " + memberIds.size() + " additional member IDs for group chat.");
                List<User> groupMembers = userService.getUsersByIds(memberIds);
                for (User member : groupMembers) {
                    if (!member.equals(requestUser)) {
                        ChatMember groupChatMember = ChatMember.builder().chat(savedChat).user(member).role("member")
                                .joinedAt(LocalDateTime.now()).build();
                        chatMemberRepository.save(groupChatMember);
                        membersToRegisterSet.add(member);
                        System.out.println("[CHAT_SERVICE] DEBUG: Member '" + member.getUsername() + "' added to group chat.");
                    } else {
                        System.out.println("[CHAT_SERVICE] DEBUG: Skipping creator ID '" + member.getUsername() + "' from additional members list to avoid duplicate.");
                    }
                }
            } else {
                System.out.println("[CHAT_SERVICE] INFO: No additional member IDs provided for group chat, only creator added.");
            }
            newChat = savedChat;
        } else { // Handle private (non-group) chat creation
            System.out.println("[CHAT_SERVICE] INFO: Creating a PRIVATE chat.");
            newChat = Chat.builder().name(chatName).isGroup(false).createdAt(LocalDateTime.now()).build();
            try {
                User interlocutor = userService.getUser(interlocutorUsername);
                System.out.println("[CHAT_SERVICE] DEBUG: Interlocutor for private chat: '" + interlocutor.getUsername() + "' (ID: " + interlocutor.getId() + ")");

                if (interlocutor.equals(requestUser)) {
                    System.err.println("[CHAT_SERVICE] ERROR: Attempted to create private chat with self. Request user: " + requestUser.getUsername());
                    throw new ResourceNotFoundException(
                            "You can't add yourself to this chat, because you are already interlocutor");
                }

                chatRepository.save(newChat);
                System.out.println("[CHAT_SERVICE] DEBUG: Private chat saved with ID: " + newChat.getId() + ", Name: '" + newChat.getName() + "'");

                ChatMember chatMember1 = ChatMember.builder().chat(newChat).user(interlocutor).role("interlocutor")
                        .joinedAt(LocalDateTime.now()).build();
                ChatMember chatMember2 = ChatMember.builder().chat(newChat).user(requestUser).role("creator")
                        .joinedAt(LocalDateTime.now()).build();

                chatMemberRepository.save(chatMember1);
                chatMemberRepository.save(chatMember2);
                System.out.println("[CHAT_SERVICE] DEBUG: Added '" + interlocutor.getUsername() + "' and '" + requestUser.getUsername() + "' to private chat members.");

                membersToRegisterSet.add(requestUser);
                membersToRegisterSet.add(interlocutor);

            } catch (NoSuchElementException e) {
                System.err.println("[CHAT_SERVICE] ERROR: Interlocutor not found: '" + interlocutorUsername + "'. Exception: " + e.getMessage());
                throw new ResourceNotFoundException("Contact not found: " + interlocutorUsername);
            }
        }

        System.out.println("[CHAT_SERVICE] INFO: Attempting to register WebSocket sessions for chat " + newChat.getId() + " with " + membersToRegisterSet.size() + " members.");
        // Log the final members before iterating
        System.out.println("[CHAT_SERVICE] DEBUG: Final members for WebSocket registration: " + membersToRegisterSet.stream().map(User::getUsername).collect(Collectors.joining(", ")));

        for (User member : membersToRegisterSet) {
            System.out.println("[CHAT_SERVICE] DEBUG: Checking active session for user: '" + member.getUsername() + "' (ID: " + member.getId() + ")");
            WebSocketSession activeSession = webSocketService.getSessionByUserId(member.getId());
            if (activeSession != null && activeSession.isOpen()) {
                webSocketService.addSession(newChat.getId(), activeSession);
                System.out.println("[CHAT_SERVICE] INFO: Session for user '" + member.getUsername() + "' (" + activeSession.getId() + ") ADDED to new chat: " + newChat.getId());
            } else {
                System.out.println("[CHAT_SERVICE] WARN: User '" + member.getUsername() + "' (ID: " + member.getId() + ") does not have an active WebSocket session or it's closed. Session NOT REGISTERED for chat " + newChat.getId());
            }
        }
        System.out.println("[CHAT_SERVICE] INFO: Chat creation process finished for chat: " + newChat.getId() + ". Members processed (final list for logging): " + membersToRegisterSet.stream().map(User::getUsername).collect(Collectors.joining(", ")));
        return newChat;
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
        System.out.println("[CHAT_SERVICE] INFO: Starting getBroadcastChats for admin '" + requestUser.getUsername() + "'. Total users: " + allUsers.size());

        for (User user : allUsers) {
            if (!user.equals(requestUser)) {
                System.out.println("[CHAT_SERVICE] DEBUG: Checking broadcast chat with user: '" + user.getUsername() + "'");
                List<Chat> userChats = getAllChatsForUser(user.getUsername());
                System.out.println("[CHAT_SERVICE] DEBUG: User '" + user.getUsername() + "' has " + userChats.size() + " existing chats.");
                Chat broadCastChat = null;
                for (Chat chat : userChats) {
                    List<User> chatMembers = getChatMembers(chat.getId());
                    if (chatMembers.contains(requestUser)) {
                        broadCastChat = chat;
                        System.out.println("[CHAT_SERVICE] DEBUG: Found existing broadcast chat " + chat.getId() + " with '" + user.getUsername() + "'.");
                        break;
                    }
                }
                if (broadCastChat == null) {
                    System.out.println("[CHAT_SERVICE] INFO: No existing broadcast chat found with '" + user.getUsername() + "'. Creating new one.");
                    CreateOrUpdateChat newChatDto = CreateOrUpdateChat.builder()
                            .name("Administrator") // Default name for admin-created private chats
                            .isGroup(false) // This is always a private chat in this context
                            .interlocutorUsername(user.getUsername())
                            .build();
                    broadCastChat = createChat(newChatDto, authorizationHeader); // RECURSIVE CALL to createChat
                    System.out.println(
                            "[CHAT_SERVICE] INFO: New chat " + broadCastChat.getId() + " created between: '" + requestUser.getUsername() + "' and '" + user.getUsername() + "'.");
                }
                broadcastChats.add(broadCastChat);
            }
        }
        System.out.println("[CHAT_SERVICE] INFO: getBroadcastChats finished. Total broadcast chats to send message: " + broadcastChats.size());
        return broadcastChats;
    }

    public void updateChat(UUID id, CreateOrUpdateChat chat, String authorizationHeader) {
        User requestUser = userService.getRequestUser(authorizationHeader);
        Chat existingChat = chatRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Chat " + id + " not found"));

        ChatMember chatMember = chatMemberRepository.findByChatAndUser(existingChat, requestUser)
                .orElseThrow(() -> new AuthenticationException("You do not have permission to update this chat"));

        if (!"creator".equals(chatMember.getRole())) {
            throw new AuthenticationException("Only creators can update this chat");
        }

        existingChat.setName(chat.getName());
        existingChat.setIsGroup(chat.getIsGroup());
        chatRepository.save(existingChat);
    }
}