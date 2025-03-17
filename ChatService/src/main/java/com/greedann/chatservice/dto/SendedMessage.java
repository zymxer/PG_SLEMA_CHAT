package com.greedann.chatservice.dto;

import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class SendedMessage {
    private String text;
}
