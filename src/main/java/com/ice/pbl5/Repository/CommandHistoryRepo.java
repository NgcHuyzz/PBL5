package com.ice.pbl5.Repository;

import com.ice.pbl5.Entity.CommandHistory;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CommandHistoryRepo extends JpaRepository<CommandHistory, Long> {
}
