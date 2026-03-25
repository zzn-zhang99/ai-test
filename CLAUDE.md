# 项目技术栈

## 基础信息
- **项目名称**: Spring Boot Template
- **版本**: 1.0.0
- **创建日期**: 2025-03-25

## 核心技术栈

### JDK & Build
| 技术 | 版本 | 说明 |
|------|------|------|
| JDK | 17 | Java Development Kit |
| Maven | 3.9+ | 构建工具 |

### Spring Boot 生态
| 技术 | 版本 | 说明 |
|------|------|------|
| Spring Boot | 3.2.12 | 核心框架 |
| Spring Web | 3.2.12 | Web 开发 |
| Spring Data JPA | 3.2.12 | 数据持久层 |
| Spring Security | 3.2.12 | 安全认证 |
| Spring Validation | 3.2.12 | 参数校验 |

### 数据库
| 技术 | 版本 | 说明 |
|------|------|------|
| H2 | 2.x | 开发测试内存数据库 |
| MySQL Connector | 8.x | MySQL 驱动 |
| PostgreSQL | 42.x | PostgreSQL 驱动 |
| Hibernate | 6.x | JPA 实现 |

### 安全与认证
| 技术 | 版本 | 说明 |
|------|------|------|
| JJWT | 0.12.5 | JWT Token 生成与验证 |
| BCrypt | - | 密码加密（Spring Security 内置） |

### 开发工具
| 技术 | 版本 | 说明 |
|------|------|------|
| Lombok | 1.18.x | 代码简化 |
| MapStruct | 1.5.5 | 对象映射 |

### 测试
| 技术 | 版本 | 说明 |
|------|------|------|
| JUnit 5 | 5.10.x | 单元测试 |
| Testcontainers | 1.19.7 | 集成测试 |

## 项目结构

```
src/main/java/com/example/demo/
├── DemoApplication.java          # 启动类
├── common/                       # 通用组件
│   ├── Result.java              # 统一返回格式
│   └── exception/               # 异常处理
├── config/                       # 配置类
├── controller/                   # 控制器层
├── domain/                       # 实体层
├── dto/                          # 数据传输对象
├── repository/                   # 数据访问层
├── security/                     # 安全认证
│   ├── JwtUtil.java             # JWT 工具
│   └── SecurityConfig.java      # 安全配置
└── service/                      # 业务层
    └── impl/                    # 实现类

src/main/resources/
├── application.yml              # 主配置
└── schema.sql                   # 数据库脚本
```

## 编码规范

### 命名规范
- 包名: `com.example.demo` (小写)
- 类名: 大驼峰 (PascalCase)
- 方法/变量: 小驼峰 (camelCase)
- 常量: 大写下划线 (UPPER_SNAKE_CASE)

### API 规范
- 统一返回格式: `Result<T>`
- HTTP 状态码: 200 成功, 400 参数错误, 401 未认证, 403 无权限, 500 服务器错误
- 响应格式:
  ```json
  {
    "code": 200,
    "message": "success",
    "data": {}
  }
  ```

### 依赖注入
- 使用 `@RequiredArgsConstructor` + `final` 字段（推荐）
- 或 `@Autowired` 字段注入

### 事务管理
- 查询方法: `@Transactional(readOnly = true)`
- 写操作: `@Transactional`

## 配置文件

### application.yml 关键配置
- 服务器端口: 8080
- 数据库: H2 (dev) / MySQL (prod)
- JPA: `ddl-auto: update`
- JWT Secret: `your-jwt-secret-key` (生产环境需修改)

## 更新记录

| 日期 | 版本 | 变更内容 |
|------|------|----------|
| 2025-03-25 | 1.0.0 | 初始化项目骨架，添加用户认证模块 |
