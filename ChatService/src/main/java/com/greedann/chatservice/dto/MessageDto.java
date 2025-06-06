package com.greedann.chatservice.dto;

import java.time.LocalDateTime;
import java.util.UUID;

import com.greedann.chatservice.model.Message;

import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class MessageDto {
    private String text;
    private UUID authorUuid;
    private UUID chatUuid;
    private UUID messageUuid;
    private LocalDateTime timestamp;
    private String fileName;
    private String fileType;
    private String fileUrl;

    public static MessageDto fromMessage(Message message) {
        return MessageDto.builder()
                .text(message.getContent())
                .authorUuid(message.getSender().getId())
                .chatUuid(message.getChat().getId())
                .messageUuid(message.getId())
                .timestamp(message.getTimestamp())
                .fileName(message.getFileName())
                .fileType(message.getFileType())
                .fileUrl(message.getFileUrl())
                .build();
    }
}
