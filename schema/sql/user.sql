-- ============================================
-- 用户管理模块 - 用户表 (H2/MySQL/PostgreSQL 兼容)
-- ============================================

-- 创建用户表
CREATE TABLE IF NOT EXISTS users (
    -- 主键ID，自增
    id          BIGINT PRIMARY KEY AUTO_INCREMENT,

    -- 用户名：登录账号，全局唯一
    username    VARCHAR(64)  NOT NULL,

    -- 邮箱：用户邮箱地址，全局唯一
    email       VARCHAR(255) NOT NULL,

    -- 密码：加密存储的密码（如 bcrypt 哈希值）
    password    VARCHAR(255) NOT NULL,

    -- 软删除标志：0=未删除，1=已删除
    deleted     TINYINT      NOT NULL DEFAULT 0,

    -- 创建时间：记录用户创建时间
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- 更新时间：记录最后修改时间
    updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 唯一索引：用户名
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_username ON users (username);

-- 唯一索引：邮箱
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email ON users (email);

-- 普通索引：软删除标志（用于过滤查询）
CREATE INDEX IF NOT EXISTS idx_users_deleted ON users (deleted);

-- ============================================
-- 字段说明
-- ============================================
-- id:          主键标识，自增长，唯一标识每个用户
-- username:    用户登录名，6-64字符，支持字母数字下划线
-- email:       用户邮箱，用于登录、通知、找回密码
-- password:    加密后的密码，存储哈希值（bcrypt/argon2）
-- deleted:     软删除标记，0=正常，1=已删除，避免物理删除
-- created_at:  记录创建时间，审计追踪用
-- updated_at:  记录最后修改时间，通常由应用层更新
-- ============================================
