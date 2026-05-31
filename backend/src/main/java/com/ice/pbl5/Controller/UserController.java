package com.ice.pbl5.Controller;

import com.ice.pbl5.DTO.Request.UserCreateRequest;
import com.ice.pbl5.DTO.Request.UserLoginRequest;
import com.ice.pbl5.DTO.Response.ApiResponse;
import com.ice.pbl5.DTO.Response.LoginResponse;
import com.ice.pbl5.DTO.Response.UserResponse;
import com.ice.pbl5.Service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<UserResponse>> register(@RequestBody @Valid UserCreateRequest user)
    {
        UserResponse userResponse = userService.createUser(user);

        return ResponseEntity.ok(ApiResponse.success(
                "Register successfully",
                userResponse
        ));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<LoginResponse>> login(@RequestBody @Valid UserLoginRequest userLoginRequest)
    {
        LoginResponse loginResponse = userService.verity(userLoginRequest);

        return ResponseEntity.ok(ApiResponse.success(
                "Login successfully",
                loginResponse
        ));
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> getUser(Authentication authentication)
    {
        String username = authentication.getName();
        UserResponse userResponse = userService.getUserByUsername(username);

        return ResponseEntity.ok(ApiResponse.success(
                "User fetched successfully",
                userResponse
        ));
    }
}
