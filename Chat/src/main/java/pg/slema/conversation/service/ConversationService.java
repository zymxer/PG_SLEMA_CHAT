package pg.slema.conversation.service;

import pg.slema.conversation.entity.Conversation;
import pg.slema.user.entity.User;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ConversationService {
    Optional<Conversation> find(UUID id);
    List<Conversation> findAll();
    List<Conversation> findAllByInitiator(UUID userId);
    List<Conversation> findAllByParticipant(UUID userId);
    void create(Conversation conversation);
    void replace(Conversation conversation);
    void addParticipantToConversationIfNecessary(Conversation conversation, User user);
}
