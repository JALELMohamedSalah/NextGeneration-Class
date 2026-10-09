package com.ngclass.backend.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;

/** Background jobs (the homework "Manquant" job). */
@Configuration
@EnableScheduling
public class SchedulingConfig {
}
