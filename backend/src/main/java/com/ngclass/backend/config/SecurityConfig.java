package com.ngclass.backend.config;

import com.ngclass.backend.auth.filter.JwtAuthenticationFilter;
import com.ngclass.backend.auth.filter.PasswordChangeFilter;
import com.ngclass.backend.common.JsonErrorWriter;
import java.util.List;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
@EnableMethodSecurity
public class SecurityConfig {
	@Bean
	public PasswordEncoder passwordEncoder(AppProperties properties) {
		return new BCryptPasswordEncoder(properties.security().bcryptStrength());
	}

	@Bean
	public CorsConfigurationSource corsConfigurationSource(AppProperties properties) {
		CorsConfiguration config = new CorsConfiguration();
		config.setAllowedOriginPatterns(properties.allowedOrigins());
		config.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
		config.setAllowedHeaders(List.of("Authorization", "Content-Type", "Accept-Language"));
		UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
		source.registerCorsConfiguration("/**", config);
		return source;
	}

	@Bean
	public SecurityFilterChain apiSecurityFilterChain(
			HttpSecurity http,
			JwtAuthenticationFilter jwtAuthenticationFilter,
			PasswordChangeFilter passwordChangeFilter,
			CorsConfigurationSource corsConfigurationSource,
			JsonErrorWriter errorWriter) throws Exception {
		http.csrf(csrf -> csrf.disable())
				.cors(cors -> cors.configurationSource(corsConfigurationSource))
				.sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
				.authorizeHttpRequests(auth -> auth
						.requestMatchers(HttpMethod.POST, "/api/v1/auth/login", "/api/v1/auth/refresh", "/api/v1/auth/logout")
						.permitAll()
						.requestMatchers(HttpMethod.GET, "/actuator/health").permitAll()
						// Signed, short-lived links to documents (FileLinks): the signature is the permission.
						.requestMatchers(HttpMethod.GET, "/api/v1/files/*").permitAll()
						// The empty template of the pupils' import: no data in it.
						.requestMatchers(HttpMethod.GET, "/api/v1/students/import/template").permitAll()
						// The owner's dashboard: refused to everyone else before anything is read.
						.requestMatchers("/api/v1/admin/**").hasRole("ADMIN")
						.anyRequest().authenticated())
				.exceptionHandling(handling -> handling
						.authenticationEntryPoint((request, response, ex) ->
								errorWriter.write(request, response, HttpStatus.UNAUTHORIZED, "unauthorized"))
						.accessDeniedHandler((request, response, ex) ->
								errorWriter.write(request, response, HttpStatus.FORBIDDEN, "forbidden")))
				.addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
				.addFilterAfter(passwordChangeFilter, JwtAuthenticationFilter.class);
		return http.build();
	}
}
