package com.caioniehues.app.domain.user;

import com.caioniehues.app.domain.common.BaseEntity;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "roles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@ToString(exclude = "users")
public class Role extends BaseEntity {

    @NotBlank
    @Size(max = 50)
    @Column(unique = true, nullable = false)
    private String name;

    @Size(max = 255)
    private String description;

    @ManyToMany(mappedBy = "roles", fetch = FetchType.LAZY)
    @Builder.Default
    private Set<User> users = new HashSet<>();

    public enum RoleName {
        ADMIN("Administrator with full access"),
        USER("Regular family member"),
        VIEWER("Read-only access");

        private final String description;

        RoleName(String description) {
            this.description = description;
        }

        public String getDescription() {
            return description;
        }
    }
}