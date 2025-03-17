package com.greedann.chatservice.dto;

import com.greedann.chatservice.model.User;
import lombok.Builder;
import lombok.Value;

import java.util.UUID;

@Value
@Builder
public class UserDto {
    UUID id;
    String name;
    // todo image

    public static UserDto fromUser(User user) {
        return UserDto.builder()
                .id(user.getId())
                .name(user.getUsername())
                .build();
    }
}