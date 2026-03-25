package com.example.user.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

/**
 * JPA 审计配置类
 * 启用 @CreatedDate 和 @LastModifiedDate 自动填充功能
 */
@Configuration
@EnableJpaAuditing
public class JpaAuditingConfig {
}
