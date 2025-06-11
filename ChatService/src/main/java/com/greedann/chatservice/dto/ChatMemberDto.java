package com.greedann.chatservice.dto;


import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import lombok.Builder;


@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Builder
public class ChatMemberDto {
    private String username;
    private String role;

}
