package com.ngclass.backend.auth.repository;

import com.ngclass.backend.auth.domain.Role;
import com.ngclass.backend.auth.domain.User;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface UserRepository extends JpaRepository<User, UUID> {
	Optional<User> findByUsername(String username);

	Optional<User> findByPhone(String phone);

	boolean existsByUsername(String username);

	boolean existsByRole(Role role);

	List<User> findByRoleOrderByCreatedAtAsc(Role role);

	boolean existsByPhone(String phone);

	boolean existsByPhoneAndIdNot(String phone, UUID id);

	boolean existsByUsernameAndIdNot(String username, UUID id);

	/** Usernames starting with this base, to pick the next free suffix ("prenom.nom2"). */
	@Query("select u.username from User u where u.username = :base or u.username like concat(:base, '%')")
	List<String> findUsernamesLike(@Param("base") String base);

	@Query("select u.mustChangePassword from User u where u.id = :id")
	Optional<Boolean> findMustChangePassword(@Param("id") UUID id);
}
