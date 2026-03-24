package com.ice.pbl5.Service;


import com.ice.pbl5.Entity.System;
import com.ice.pbl5.Entity.User;
import com.ice.pbl5.Repository.SystemRepo;

import java.util.UUID;

public interface SystemAccessService {
    public System getOwnedSystem(UUID systemId, String username);
}
