package com.ngclass.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

@SpringBootApplication
@ConfigurationPropertiesScan
public class NgClassApplication {
	public static void main(String[] args) {
		SpringApplication.run(NgClassApplication.class, args);
	}
}
