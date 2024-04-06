package pg.slema.conversation.factory;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import pg.slema.chat.dto.ReceivedChatMessage;
import pg.slema.chat.mapper.ReceivedChatMessageConversationMapper;
import pg.slema.conversation.entity.Conversation;
import pg.slema.conversation.service.ConversationService;
import pg.slema.user.entity.User;
import pg.slema.user.service.UserService;

import java.util.Optional;
import java.util.UUID;

@Component
public class ConversationFactoryImpl implements ConversationFactory {

    private final ConversationService conversationService;

    private final UserService userService;

    private final ReceivedChatMessageConversationMapper conversationMapper;

    @Autowired
    public ConversationFactoryImpl(ConversationService conversationService,
                                   UserService userService, ReceivedChatMessageConversationMapper conversationMapper) {
        this.conversationService = conversationService;
        this.userService = userService;
        this.conversationMapper = conversationMapper;
    }

    @Override
    public Conversation getConversationForReceivedMessage(ReceivedChatMessage message) {
        ReceivedChatMessage.Conversation messageConversation = message.getConversation();
        Optional<User> sender = userService.find(message.getSenderId());
        Optional<Conversation> conversation = conversationService.find(messageConversation.getId());

        if(sender.isEmpty()) {
            throw new RuntimeException("Incorrect message sender"); //TODO make this exception checked
        }

        if(conversation.isEmpty()) {
            Conversation createdConversation = conversationMapper.apply(message.getSenderId(), messageConversation);
            createdConversation.setInitiator(sender.get());
            conversationService.create(createdConversation);
            return createdConversation;
        }
        else {
            Conversation existingConversation = conversation.get();
            conversationService.addParticipantToConversationIfNecessary(existingConversation, sender.get());
            return existingConversation;
        }
    }
}
