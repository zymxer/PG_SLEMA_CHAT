package com.greedann.chatservice.dto;

import lombok.Builder;
import lombok.Value;

import java.util.List;
import java.util.UUID;

@Value
@Builder
public class CreateOrUpdateChat {
    String name;
    Boolean isGroup;
    String interlocutorUsername;
    List<UUID> memberIds;
}
