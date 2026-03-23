package com.ice.pbl5.DTO.Request;

import com.ice.pbl5.Enum.SystemAction;
import jakarta.validation.constraints.NotNull;

public class SystemControlRequest {
    @NotNull(message = "action must not be null")
    private SystemAction action;

    public SystemAction getAction() {
        return action;
    }

    public void setAction(SystemAction action) {
        this.action = action;
    }
}
