package com.caioniehues.app.application.mapper;

import com.caioniehues.app.application.dto.response.UserResponse;
import com.caioniehues.app.domain.user.Role;
import com.caioniehues.app.domain.user.User;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;

import java.util.Set;
import java.util.stream.Collectors;

/**
 * MapStruct mapper for converting User entities to DTOs.
 * Handles the transformation between domain entities and response objects.
 */
@Mapper(componentModel = "spring")
public interface UserMapper {

    /**
     * Convert User entity to UserResponse DTO
     *
     * @param user The user entity to convert
     * @return UserResponse DTO with user information
     */
    @Mapping(target = "roles", source = "roles", qualifiedByName = "rolesToRoleResponses")
    @Mapping(target = "phoneNumber", ignore = true)  // Add when User entity has phone field
    UserResponse toResponse(User user);

    /**
     * Convert Role entities to RoleResponse DTOs
     */
    @Named("rolesToRoleResponses")
    default Set<UserResponse.RoleResponse> rolesToRoleResponses(Set<Role> roles) {
        if (roles == null) {
            return null;
        }
        return roles.stream()
            .map(role -> new UserResponse.RoleResponse(
                role.getName(),
                role.getDescription()
            ))
            .collect(Collectors.toSet());
    }
}