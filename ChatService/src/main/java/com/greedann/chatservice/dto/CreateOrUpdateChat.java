package com.greedann.chatservice.dto;

import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class CreateOrUpdateChat {
    String name;
    Boolean isGroup;
    String interlocutorUsername;
}
