package com.caioniehues.app.infrastructure.security;

import com.caioniehues.app.infrastructure.persistence.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    /**
     * Load user by username or email for authentication.
     * Method is cached for performance optimization.
     *
     * @param usernameOrEmail Username or email to search for
     * @return UserDetails for Spring Security authentication
     * @throws UsernameNotFoundException if user not found
     */
    @Override
    @Transactional(readOnly = true)
    @Cacheable(value = "userDetails", key = "#usernameOrEmail", unless = "#result == null")
    public UserDetails loadUserByUsername(String usernameOrEmail) throws UsernameNotFoundException {
        log.debug("Loading user by username/email: {}", usernameOrEmail);

        if (usernameOrEmail == null) {
            log.error("Username/email is null");
            throw new UsernameNotFoundException("User not found: null");
        }

        // Trim whitespace from input
        String trimmedInput = usernameOrEmail.trim();

        if (trimmedInput.isEmpty()) {
            log.error("Username/email is empty");
            throw new UsernameNotFoundException("User not found: " + usernameOrEmail);
        }

        // Try to find user by username first
        return userRepository.findByUsernameWithRoles(trimmedInput)
                .or(() -> {
                    // If not found by username, try email
                    log.debug("User not found by username, trying email: {}", trimmedInput);
                    return userRepository.findByEmailWithRoles(trimmedInput);
                })
                .map(user -> {
                    log.debug("User found: {} with {} roles", user.getUsername(), user.getRoles().size());
                    return (UserDetails) user;
                })
                .orElseThrow(() -> {
                    log.error("User not found: {}", trimmedInput);
                    return new UsernameNotFoundException("User not found: " + usernameOrEmail);
                });
    }
}