package com.greedann.chatservice.controller.implementation;

import com.greedann.chatservice.controller.api.UserController;
import com.greedann.chatservice.dto.UserDto;
import com.greedann.chatservice.model.User;
import com.greedann.chatservice.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;

@RestController
public class UserControllerImplementation implements UserController {

    private final UserService userService;

    public UserControllerImplementation(UserService userService) {
        this.userService = userService;
    }

    //todo all except sender
    @Override
    public ResponseEntity<List<UserDto>> getAllUsers(String authorizationHeader) {
        List<User> users =  userService.getAllUsers();
        List<UserDto> userDtos = users.stream().map(UserDto::fromUser).toList();
        return ResponseEntity.ok().body(userDtos);
    }

    @Override
    public ResponseEntity<UserDto> getRequestUser(String authorizationHeader) {
        return ResponseEntity.ok().body(UserDto.fromUser(userService.getRequestUser(authorizationHeader)));
    }
}