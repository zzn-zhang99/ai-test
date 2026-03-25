# API 接口文档

## 基础信息

| 项目 | 值 |
|------|------|
| 基础 URL | `http://localhost:8080` |
| 响应格式 | JSON |
| 统一响应封装 | `Result<T>` |

## 认证方式

API 使用 JWT Token 认证，登录后获取 Token，在请求头中携带：

```
Authorization: Bearer <token>
```

---

## 接口列表

### 1. 用户认证 API

**基础路径**: `/api/auth`

#### 1.1 用户注册

- **路径**: `POST /api/auth/register`
- **请求体**:

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| username | string | 是 | 用户名，4-20字符，字母数字下划线 |
| password | string | 是 | 密码，6-20字符 |
| email | string | 是 | 邮箱地址 |

- **请求示例**:
```json
{
  "username": "john_doe",
  "password": "123456",
  "email": "john@example.com"
}
```

- **响应示例 (200)**:
```json
{
  "code": 200,
  "message": "success",
  "data": null,
  "timestamp": "2025-03-25T10:30:00"
}
```

#### 1.2 用户登录

- **路径**: `POST /api/auth/login`
- **请求体**:

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| account | string | 是 | 用户名或邮箱 |
| password | string | 是 | 密码 |

- **请求示例**:
```json
{
  "account": "john_doe",
  "password": "123456"
}
```

- **响应示例 (200)**:
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "tokenType": "Bearer",
    "expiresIn": 86400000,
    "user": {
      "id": 1,
      "username": "john_doe",
      "email": "john@example.com"
    }
  },
  "timestamp": "2025-03-25T10:30:00"
}
```

---

### 2. 用户管理 API

**基础路径**: `/api/users`

#### 2.1 获取所有用户

- **路径**: `GET /api/users`
- **认证**: 需携带 JWT Token
- **查询参数**: 无

- **响应示例 (200)**:
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "username": "john_doe",
      "email": "john@example.com",
      "createdAt": "2025-03-25T10:00:00",
      "updatedAt": "2025-03-25T10:30:00"
    }
  ],
  "timestamp": "2025-03-25T10:30:00"
}
```

#### 2.2 获取单个用户

- **路径**: `GET /api/users/{id}`
- **认证**: 需携带 JWT Token
- **路径参数**:

| 参数 | 类型 | 说明 |
|------|------|------|
| id | long | 用户ID |

- **响应示例 (200)**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "username": "john_doe",
    "email": "john@example.com",
    "createdAt": "2025-03-25T10:00:00",
    "updatedAt": "2025-03-25T10:30:00"
  },
  "timestamp": "2025-03-25T10:30:00"
}
```

- **错误响应 (500 - 用户不存在)**:
```json
{
  "code": 500,
  "message": "用户不存在",
  "data": null,
  "timestamp": "2025-03-25T10:30:00"
}
```

#### 2.3 创建用户

- **路径**: `POST /api/users`
- **认证**: 需携带 JWT Token
- **请求体**:

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| username | string | 是 | 用户名 |
| password | string | 是 | 密码 |
| email | string | 是 | 邮箱 |

- **请求示例**:
```json
{
  "username": "jane_doe",
  "password": "123456",
  "email": "jane@example.com"
}
```

- **响应示例 (200)**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 2,
    "username": "jane_doe",
    "email": "jane@example.com",
    "createdAt": "2025-03-25T10:30:00",
    "updatedAt": "2025-03-25T10:30:00"
  },
  "timestamp": "2025-03-25T10:30:00"
}
```

#### 2.4 更新用户

- **路径**: `PUT /api/users/{id}`
- **认证**: 需携带 JWT Token
- **路径参数**:

| 参数 | 类型 | 说明 |
|------|------|------|
| id | long | 用户ID |

- **请求体**:

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| username | string | 否 | 用户名 |
| password | string | 否 | 密码 |
| email | string | 否 | 邮箱 |

- **请求示例**:
```json
{
  "email": "new_email@example.com"
}
```

- **响应示例 (200)**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "username": "john_doe",
    "email": "new_email@example.com",
    "createdAt": "2025-03-25T10:00:00",
    "updatedAt": "2025-03-25T10:35:00"
  },
  "timestamp": "2025-03-25T10:35:00"
}
```

#### 2.5 删除用户

- **路径**: `DELETE /api/users/{id}`
- **认证**: 需携带 JWT Token
- **路径参数**:

| 参数 | 类型 | 说明 |
|------|------|------|
| id | long | 用户ID |

- **响应示例 (200)**:
```json
{
  "code": 200,
  "message": "success",
  "data": null,
  "timestamp": "2025-03-25T10:30:00"
}
```

---

## 统一响应格式

### Result 结构

| 字段 | 类型 | 说明 |
|------|------|------|
| code | integer | 状态码 |
| message | string | 响应消息 |
| data | object | 响应数据 |
| timestamp | string | 响应时间戳 |

### 成功响应

```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": "2025-03-25T10:30:00"
}
```

### 错误响应

```json
{
  "code": 500,
  "message": "错误描述",
  "data": null,
  "timestamp": "2025-03-25T10:30:00"
}
```

---

## 错误码说明

| 错误码 | 说明 |
|--------|------|
| 200 | 请求成功 |
| 400 | 参数错误或验证失败 |
| 401 | 未认证（Token 无效或缺失）|
| 403 | 无权限访问 |
| 404 | 资源不存在 |
| 409 | 资源冲突（如用户名/邮箱已存在）|
| 500 | 服务器内部错误 |

---

## 数据模型

### User 实体

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Long | 用户ID（主键，自增）|
| username | String | 用户名（唯一）|
| password | String | 密码（加密存储）|
| email | String | 邮箱（唯一）|
| createdAt | LocalDateTime | 创建时间 |
| updatedAt | LocalDateTime | 更新时间 |
| deleted | Integer | 软删除标记（0=未删除，1=已删除）|

### LoginRequest

| 字段 | 类型 | 约束 |
|------|------|------|
| account | string | @NotBlank |
| password | string | @NotBlank |

### RegisterRequest

| 字段 | 类型 | 约束 |
|------|------|------|
| username | string | @NotBlank, 4-20字符, 字母数字下划线 |
| password | string | @NotBlank, 6-20字符 |
| email | string | @NotBlank, @Email |

### LoginResponse

| 字段 | 类型 | 说明 |
|------|------|------|
| token | string | JWT Token |
| tokenType | string | Token 类型（Bearer）|
| expiresIn | Long | 过期时间（毫秒）|
| user.userInfo | object | 用户信息 |
| user.id | Long | 用户ID |
| user.username | string | 用户名 |
| user.email | string | 邮箱 |
