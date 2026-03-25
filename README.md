# Spring Boot Template

一个基于 Spring Boot 3.2 的标准化项目模板，集成用户认证、数据持久化和 RESTful API 功能。

## 项目简介

本项目提供了一个开箱即用的 Spring Boot 项目骨架，包含：
- 用户注册/登录认证（JWT Token）
- CRUD 用户管理接口
- 统一响应格式封装
- 全局异常处理
- 软删除支持
- 多环境配置（dev/prod/test）

## 技术栈

| 技术 | 版本 | 说明 |
|------|------|------|
| JDK | 17 | Java Development Kit |
| Spring Boot | 3.2.12 | 核心框架 |
| Spring Data JPA | 3.2.12 | 数据持久层 |
| Spring Security | 3.2.12 | 安全认证 |
| H2 Database | 2.x | 开发测试内存数据库 |
| MySQL Connector | 8.x | MySQL 驱动 |
| PostgreSQL | 42.x | PostgreSQL 驱动 |
| JJWT | 0.12.5 | JWT Token 生成与验证 |
| Lombok | 1.18.x | 代码简化 |
| MapStruct | 1.5.5 | 对象映射 |
| JUnit 5 | 5.10.x | 单元测试 |
| Testcontainers | 1.19.7 | 集成测试 |

## 快速启动

### 环境要求
- JDK 17+
- Maven 3.9+

### 本地运行

```bash
# 克隆/下载项目后进入目录
cd spring-boot-template

# 使用 Maven 运行
./mvnw spring-boot:run

# 或编译后运行
./mvnw clean package
java -jar target/spring-boot-template-1.0.0.jar
```

应用启动后访问：
- API 基础地址：`http://localhost:8080`
- H2 控制台：`http://localhost:8080/h2-console`

### 多环境运行

```bash
# 开发环境（默认）
./mvnw spring-boot:run -Pdev

# 生产环境
./mvnw spring-boot:run -Pprod

# 测试环境
./mvnw spring-boot:run -Ptest
```

### 打包部署

```bash
# 打包（包含所有依赖）
./mvnw clean package

# 跳过测试打包
./mvnw clean package -DskipTests
```

## 目录结构

```
spring-boot-template/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/example/demo/
│   │   │       ├── DemoApplication.java          # 启动类
│   │   │       ├── common/                       # 通用组件
│   │   │       │   ├── Result.java              # 统一返回格式
│   │   │       │   └── exception/               # 异常处理
│   │   │       │       ├── BusinessException.java
│   │   │       │       └── GlobalExceptionHandler.java
│   │   │       ├── config/                       # 配置类
│   │   │       │   └── JpaAuditingConfig.java
│   │   │       ├── controller/                   # 控制器层
│   │   │       │   ├── AuthController.java      # 认证接口
│   │   │       │   └── UserController.java      # 用户接口
│   │   │       ├── domain/                       # 实体层
│   │   │       │   └── User.java                # 用户实体
│   │   │       ├── dto/                          # 数据传输对象
│   │   │       │   ├── LoginRequest.java        # 登录请求
│   │   │       │   ├── LoginResponse.java       # 登录响应
│   │   │       │   └── RegisterRequest.java     # 注册请求
│   │   │       ├── repository/                   # 数据访问层
│   │   │       │   └── UserRepository.java
│   │   │       ├── security/                     # 安全认证
│   │   │       │   ├── JwtUtil.java             # JWT 工具
│   │   │       │   └── SecurityConfig.java      # 安全配置
│   │   │       └── service/                      # 业务层
│   │   │           ├── AuthService.java         # 认证业务接口
│   │   │           ├── UserService.java         # 用户业务接口
│   │   │           └── impl/                    # 实现类
│   │   │               ├── AuthServiceImpl.java
│   │   │               └── UserServiceImpl.java
│   │   └── resources/
│   │       ├── application.yml                  # 主配置
│   │       ├── application-dev.yml              # 开发环境配置
│   │       ├── application-prod.yml             # 生产环境配置
│   │       └── schema.sql                       # 数据库初始化脚本
│   └── test/
│       └── java/
│           └── com/example/demo/
│               └── controller/                  # 单元测试
├── docs/
│   └── API.md                                   # API 接口文档
├── pom.xml                                      # Maven 配置
└── README.md                                    # 项目说明
```

## API 文档

详见 [docs/API.md](docs/API.md)

## 配置说明

### 数据库配置

默认使用 H2 内存数据库，适合开发和测试。生产环境可切换为 MySQL 或 PostgreSQL：

```yaml
# application-prod.yml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/your_db
    username: your_username
    password: your_password
    driver-class-name: com.mysql.cj.jdbc.Driver
```

### JWT 配置

```yaml
# application.yml
jwt:
  secret: your-jwt-secret-key  # 生产环境需修改为强密钥
  expiration: 86400000         # Token 有效期（毫秒）
```

## 许可证

MIT License
