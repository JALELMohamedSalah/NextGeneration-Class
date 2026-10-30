package com.ngclass.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.servlet.UserDetailsServiceAutoConfiguration;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

// Sign-in is our own JWT flow: no default in-memory user, and no generated password in the logs.
@SpringBootApplication(exclude = UserDetailsServiceAutoConfiguration.class)
@ConfigurationPropertiesScan
public class NgClassApplication {
	public static void main(String[] args) {
		SpringApplication.run(NgClassApplication.class, args);
	}
}
