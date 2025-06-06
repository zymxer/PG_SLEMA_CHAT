package com.greedann.chatservice.dto;

import lombok.Builder;
import lombok.Value;
import org.springframework.web.multipart.MultipartFile;

@Value
@Builder
public class SendedMessage {
    private String text;
    private MultipartFile file;
}
