package com.greedann.chatservice.controller.api;

import com.greedann.chatservice.dto.UserDto;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;

import java.util.List;

@RequestMapping("/api/user")
public interface UserController {

    @GetMapping
    @ResponseStatus(HttpStatus.OK)
    public ResponseEntity<List<UserDto>> getAllUsers(@RequestHeader("Authorization") String authorizationHeader);

    @GetMapping("/of-request")
    @ResponseStatus(HttpStatus.OK)
    public ResponseEntity<UserDto> getRequestUser(@RequestHeader("Authorization") String authorizationHeader);
}
