package com.ice.pbl5.DTO.Response;

import com.ice.pbl5.Enum.UserStatus;

import java.time.LocalDateTime;

public class UserResponse {
    private String username;
    private String email;
    private String fullName;
    private UserStatus status;

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public UserStatus getStatus() {
        return status;
    }

    public void setStatus(UserStatus status) {
        this.status = status;
    }
}
