package com.example.user.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

/**
 * 用户实体类
 * 对应数据库表：users
 */
@Entity
@Table(name = "users")
@EntityListeners(AuditingEntityListener.class)
@SQLDelete(sql = "UPDATE users SET deleted = 1 WHERE id = ?")
@SQLRestriction("deleted = 0")
@Getter
@Setter
@NoArgsConstructor
public class User {

    /**
     * 主键ID，自增
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 用户名：登录账号，全局唯一
     */
    @Column(name = "username", nullable = false, length = 64, unique = true)
    private String username;

    /**
     * 邮箱：用户邮箱地址，全局唯一
     */
    @Column(name = "email", nullable = false, length = 255, unique = true)
    private String email;

    /**
     * 密码：加密存储的密码（bcrypt/argon2 哈希值）
     */
    @Column(name = "password", nullable = false, length = 255)
    private String password;

    /**
     * 软删除标志：0=未删除，1=已删除
     * @SQLDelete 会自动将删除操作改为更新此字段
     */
    @Column(name = "deleted", nullable = false)
    private Integer deleted = 0;

    /**
     * 创建时间：记录用户创建时间
     * 由 @CreatedDate 自动填充
     */
    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    /**
     * 更新时间：记录最后修改时间
     * 由 @LastModifiedDate 自动填充
     */
    @LastModifiedDate
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

}
