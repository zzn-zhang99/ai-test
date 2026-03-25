# Spring Boot Template 部署文档

## 系统要求

### 环境依赖

| 组件 | 最低版本 | 推荐版本 | 说明 |
|------|---------|---------|------|
| JDK | 17 | 17 LTS | 必需 |
| Maven | 3.8+ | 3.9+ | 必需 |
| MySQL | 8.0+ | 8.0+ | 生产环境可选 |
| PostgreSQL | 14+ | 15+ | 生产环境可选 |

### 检查环境

```bash
# 检查 Java 版本
java -version
# 输出应包含 "17" 或更高版本

# 检查 Maven 版本
mvn -version
# 输出应包含 "Apache Maven 3.8+"
```

## 快速开始

### 1. 克隆项目

```bash
git clone <your-repository-url>
cd aitest
```

### 2. 启动应用

#### Linux/Mac

```bash
# 使用默认配置启动（H2 内存数据库，8080 端口）
./scripts/start.sh

# 指定端口和环境
./scripts/start.sh -p 8081 -e prod

# 查看所有选项
./scripts/start.sh --help
```

#### Windows

```bash
# 使用默认配置启动
scripts\start.bat

# 指定端口和环境
scripts\start.bat -p 8081 -e prod

# 查看所有选项
scripts\start.bat --help
```

## 部署方式

### 本地开发部署（H2 内存数据库）

适用于快速体验或本地开发测试。

```bash
# 使用开发环境配置，自动使用 H2 内存数据库
./scripts/start.sh -e dev
```

访问 http://localhost:8080/h2-console 可查看 H2 控制台。

### 生产环境部署（MySQL）

#### 1. 准备 MySQL 数据库

```sql
-- 创建数据库
CREATE DATABASE userdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 创建用户（可选）
CREATE USER 'app_user'@'%' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON userdb.* TO 'app_user'@'%';
FLUSH PRIVILEGES;
```

#### 2. 配置数据库连接

编辑 `src/main/resources/application.yml`，取消 MySQL 配置注释：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/userdb?useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
    username: app_user
    password: your_secure_password
    driver-class-name: com.mysql.cj.jdbc.Driver

  jpa:
    database-platform: org.hibernate.dialect.MySQL8Dialect
    hibernate:
      ddl-auto: update  # 首次部署可用 update，之后建议改为 validate
```

#### 3. 启动应用

```bash
# 使用生产环境配置
./scripts/start.sh -e prod -p 8080

# 或后台运行
./scripts/start.sh -e prod -d
```

### Docker 部署

#### 1. 构建镜像

```bash
# 使用 Maven 构建 JAR
./scripts/start.sh -s -b

# 构建 Docker 镜像
docker build -t spring-boot-template:latest .
```

#### 2. 运行容器

```bash
# H2 模式（开发测试）
docker run -d -p 8080:8080 --name app spring-boot-template:latest

# MySQL 模式（生产）
docker run -d -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=prod \
  -e DB_URL=jdbc:mysql://host.docker.internal:3306/userdb \
  -e DB_USERNAME=app_user \
  -e DB_PASSWORD=your_password \
  --name app spring-boot-template:latest
```

#### 3. 使用 Docker Compose（推荐）

创建 `docker-compose.yml`：

```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - DB_URL=jdbc:mysql://mysql:3306/userdb
      - DB_USERNAME=app_user
      - DB_PASSWORD=your_password
    depends_on:
      - mysql

  mysql:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=root_password
      - MYSQL_DATABASE=userdb
      - MYSQL_USER=app_user
      - MYSQL_PASSWORD=your_password
    volumes:
      - mysql_data:/var/lib/mysql
    ports:
      - "3306:3306"

volumes:
  mysql_data:
```

启动：

```bash
docker-compose up -d
```

## 脚本参数说明

### start.sh / start.bat

| 参数 | 简写 | 说明 | 默认值 |
|------|------|------|--------|
| `--port` | `-p` | 服务端口 | 8080 |
| `--profile` | `-e` | 运行环境：dev/test/prod | dev |
| `--java-home` | `-j` | JDK 路径 | $JAVA_HOME |
| `--mvn-home` | `-m` | Maven 路径 | $MAVEN_HOME |
| `--skip-tests` | `-s` | 跳过测试 | false |
| `--build-only` | `-b` | 仅编译 | false |
| `--daemon` | `-d` | 后台运行 | false |
| `--help` | `-h` | 显示帮助 | - |

### 使用示例

```bash
# 1. 默认启动（开发环境，H2 数据库）
./scripts/start.sh

# 2. 生产环境启动，指定端口
./scripts/start.sh -e prod -p 8080

# 3. 使用特定 JDK 版本
./scripts/start.sh -j /opt/java/17

# 4. 后台运行（守护进程模式）
./scripts/start.sh -d -e prod

# 5. 快速构建，跳过测试
./scripts/start.sh -s -b
```

## 环境变量配置

### 生产环境必需变量

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `DB_URL` | 数据库连接 URL | `jdbc:mysql://localhost:3306/userdb` |
| `DB_USERNAME` | 数据库用户名 | `app_user` |
| `DB_PASSWORD` | 数据库密码 | `your_password` |
| `DB_DRIVER` | 数据库驱动类 | `com.mysql.cj.jdbc.Driver` |
| `JWT_SECRET` | JWT 密钥（重要！） | 随机生成的长字符串 |
| `SERVER_PORT` | 服务端口 | `8080` |

### 环境变量启动方式

```bash
# Linux/Mac
export DB_URL=jdbc:mysql://localhost:3306/userdb
export DB_USERNAME=app_user
export DB_PASSWORD=your_password
export JWT_SECRET=your-256-bit-secret-key-here

./scripts/start.sh -e prod
```

```cmd
:: Windows CMD
set DB_URL=jdbc:mysql://localhost:3306/userdb
set DB_USERNAME=app_user
set DB_PASSWORD=your_password
set JWT_SECRET=your-256-bit-secret-key-here

scripts\start.bat -e prod
```

## 环境配置详解

### 开发环境 (dev)

- **数据库**: H2 内存数据库
- **自动建表**: 启用（ddl-auto: create-drop）
- **SQL 日志**: 显示
- **H2 控制台**: 启用

### 测试环境 (test)

- **数据库**: H2 或独立测试数据库
- **自动建表**: 启用
- **SQL 日志**: 显示
- **模拟数据**: 自动加载

### 生产环境 (prod)

- **数据库**: MySQL/PostgreSQL
- **自动建表**: 仅验证（ddl-auto: validate）
- **SQL 日志**: 关闭
- **H2 控制台**: 禁用
- **日志级别**: WARN

## 验证部署

### 健康检查

```bash
# 检查应用是否启动
curl http://localhost:8080/actuator/health

# 预期输出
{"status":"UP"}
```

### API 测试

```bash
# 用户注册
curl -X POST http://localhost:8080/api/users/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"123456","email":"test@example.com"}'

# 用户登录
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"123456"}'
```

## 常见问题

### 1. Java 版本错误

**问题**: `需要 Java 17 或更高版本`

**解决**:
```bash
# 检查当前 Java 版本
java -version

# 指定正确的 JAVA_HOME
./scripts/start.sh -j /usr/lib/jvm/java-17
```

### 2. Maven 未找到

**问题**: `未找到 Maven`

**解决**:
```bash
# 方法一：添加 Maven 到 PATH
export PATH=$PATH:/opt/apache-maven/bin

# 方法二：指定 MAVEN_HOME
./scripts/start.sh -m /opt/apache-maven
```

### 3. 端口被占用

**问题**: `Port 8080 was already in use`

**解决**:
```bash
# 使用其他端口
./scripts/start.sh -p 8081
```

### 4. 数据库连接失败

**问题**: `Communications link failure`

**解决**:
1. 检查数据库服务是否启动
2. 验证连接信息是否正确
3. 确认数据库用户权限
4. 检查防火墙设置

## 安全建议

1. **生产环境务必修改 JWT Secret**：
   ```bash
   # 生成随机密钥
   openssl rand -base64 32
   ```

2. **使用环境变量管理敏感信息**，不要硬编码在配置文件中

3. **数据库密码使用强密码策略**

4. **启用 HTTPS**（生产环境）

5. **定期更新依赖**（关注安全漏洞）

## 日志查看

### 前台运行
日志直接输出到控制台

### 后台运行
```bash
# Linux/Mac
tail -f logs/app.log

# Windows
type logs\app.log
```

### 日志级别调整
编辑 `src/main/resources/application.yml`：

```yaml
logging:
  level:
    root: INFO
    com.example.demo: DEBUG  # 调整应用日志级别
```
