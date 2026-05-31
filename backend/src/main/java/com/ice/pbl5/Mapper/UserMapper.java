package com.ice.pbl5.Mapper;

import com.ice.pbl5.DTO.Request.UserCreateRequest;
import com.ice.pbl5.DTO.Response.LoginResponse;
import com.ice.pbl5.DTO.Response.UserResponse;
import com.ice.pbl5.Entity.User;
import com.ice.pbl5.Enum.UserStatus;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
public class UserMapper {
    public User toEntity(UserCreateRequest userCreateRequest, String encodePassword)
    {
        User user = new User();
        user.setUsername(userCreateRequest.getUsername());
        user.setEmail(userCreateRequest.getEmail());
        user.setPasswordHash(encodePassword);
        user.setFullName(userCreateRequest.getFullName());
        user.setUserStatus(UserStatus.ACTIVE);
        LocalDateTime now = LocalDateTime.now();
        user.setCreateAt(now);
        user.setUpdateAt(now);

        return user;
    }

    public UserResponse toResponse(User user) {

        UserResponse response = new UserResponse();

        response.setUsername(user.getUsername());
        response.setEmail(user.getEmail());
        response.setFullName(user.getFullName());
        response.setStatus(user.getUserStatus());

        return response;
    }

    public LoginResponse toLoginResponse(User user, String accessToken, String tokenType, long expiresIn)
    {
        LoginResponse response = new LoginResponse();
        UserResponse userResponse = toResponse(user);
        response.setUser(userResponse);
        response.setAccessToken(accessToken);
        response.setTokenType(tokenType);
        response.setExpiresIn(expiresIn);

        return response;
    }
}
