package com.bitesait.AuthService.controllers;


import com.bitesait.AuthService.DTO.LoginRequest;
import com.bitesait.AuthService.DTO.LoginResponse;
import com.bitesait.AuthService.DTO.RegisterRequest;
import com.bitesait.AuthService.models.User;
import com.bitesait.AuthService.services.AuthService;
import com.bitesait.AuthService.util.JwtUtil;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
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


//    public AuthController(AuthService authService){
//        this.authService = authService;
//    }


    @PostMapping("/register")
    public ResponseEntity<User> register(@RequestBody @Valid RegisterRequest request){
        User user = authService.register(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(user);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login (@RequestBody @Valid LoginRequest request){
        Optional<User> user = authService.findByUsername(request.getUsername());
        if(user.isPresent() == false)
            throw(new UsernameNotFoundException("User not found"));
        if(!passwordEncoder.matches(request.getPassword(), user.get().getPassword()))
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid credentials");
        String token = jwtUtil.generateToken(user.get());
        return ResponseEntity.ok(new LoginResponse(token));
    }

    @GetMapping("/verify")
    public ResponseEntity<?> verify(@RequestHeader("Authorization") String token){
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();
        return ResponseEntity.ok(username);
    }
}
