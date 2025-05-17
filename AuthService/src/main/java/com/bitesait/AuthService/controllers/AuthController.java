package com.bitesait.AuthService.controllers;


import com.bitesait.AuthService.DTO.LoginRequest;
import com.bitesait.AuthService.DTO.LoginResponse;
import com.bitesait.AuthService.DTO.RegisterRequest;
import com.bitesait.AuthService.exceptions.EmailAlreadyExistsException;
import com.bitesait.AuthService.models.User;
import com.bitesait.AuthService.services.AuthService;
import com.bitesait.AuthService.util.JwtUtil;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;
    private final JwtUtil jwtUtil;
    private final PasswordEncoder passwordEncoder;

    @PostMapping("/register")
    public ResponseEntity<Void> register(@RequestBody @Valid RegisterRequest request){
        authService.register(request);
        return new ResponseEntity<>(HttpStatus.CREATED);
    }
    @PostMapping("/login")
    public ResponseEntity<?> login (@RequestBody @Valid LoginRequest request){
        Optional<User> user = authService.findByUsername(request.getUsername());
        if(user.isEmpty())
            throw(new UsernameNotFoundException("User not found"));
        if(!passwordEncoder.matches(request.getPassword(), user.get().getPassword()))
            throw new BadCredentialsException("Invalid password");
        String token = jwtUtil.generateToken(user.get());
        return ResponseEntity.ok(new LoginResponse(token));
    }

    @GetMapping("/verify")
    public ResponseEntity<?> verify(@RequestHeader("Authorization") String token){
        if (token == null || !token.startsWith("Bearer ")) {
            throw new BadCredentialsException("Invalid token");
        }
        token = token.substring(7); // Remove "Bearer " prefix
        String username = jwtUtil.extractUsername(token);
        return ResponseEntity.ok(username);
    }
}
