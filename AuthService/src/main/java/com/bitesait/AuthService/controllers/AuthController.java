package com.bitesait.AuthService.controllers;

import com.bitesait.AuthService.DTO.LoginRequest;
import com.bitesait.AuthService.DTO.LoginResponse;
import com.bitesait.AuthService.DTO.RegisterRequest;
import com.bitesait.AuthService.services.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<Void> register(@RequestBody @Valid RegisterRequest request){
        authService.register(request);
        return ResponseEntity.status(201).build();
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login (@RequestBody @Valid LoginRequest request){
        LoginResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/verify")
    public ResponseEntity<?> verify(@RequestHeader("Authorization") String token){
        String username = authService.verifyToken(token);
        return ResponseEntity.ok(username);
    }
}
