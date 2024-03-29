package pg.slema.conversation.entity;

import jakarta.persistence.*;
import lombok.*;
import pg.slema.message.entity.Message;
import pg.slema.user.entity.User;

import java.util.List;
import java.util.UUID;


@Entity
@Builder
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode
@Getter
@Setter
@Table(name = "conversations")
public class Conversation {

    @Id
    private UUID id;

    private String title;

    @ManyToOne
    @JoinColumn(name = "initiator")
    private User initiator;

    @ManyToMany(mappedBy = "participatedConversations")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private List<User> participants;

    @OneToMany(mappedBy = "conversation", cascade = CascadeType.REMOVE)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private List<Message> messages;
}
