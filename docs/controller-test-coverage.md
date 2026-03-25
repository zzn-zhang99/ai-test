# Controller 层单元测试覆盖报告

## 测试概述

本文档说明 Controller 层的单元测试覆盖情况。测试使用 **@WebMvcTest** + **MockMvc** 进行 MVC 层测试，使用 **@MockBean** 模拟 Service 层依赖。

## 测试环境

| 项目 | 版本 |
|------|------|
| JDK | 17 |
| Spring Boot | 3.2.12 |
| JUnit | 5.10.x |
| Maven | 3.9+ |

## 测试文件位置

```
src/test/java/com/example/demo/controller/
├── AuthControllerTest.java    # 认证控制器测试
└── UserControllerTest.java    # 用户控制器测试
```

## 测试统计

| 控制器 | 测试方法数 | 正常场景 | 异常场景 |
|--------|----------|----------|----------|
| AuthController | 10 | 2 | 8 |
| UserController | 14 | 6 | 8 |
| **总计** | **24** | **8** | **16** |

---

## AuthController 测试覆盖

### API 端点

| 端点 | 方法 | 说明 |
|------|------|------|
| `/api/auth/register` | POST | 用户注册 |
| `/api/auth/login` | POST | 用户登录 |

### 测试用例详情

#### 1. 注册功能 (register)

| 测试方法 | 场景 | 预期结果 |
|----------|------|----------|
| `register_Success` | 正常注册 | HTTP 200, code=200 |
| `register_UsernameExists` | 用户名已存在 | HTTP 200, code=400 |
| `register_ValidationFailed_EmptyUsername` | 用户名为空 | HTTP 200, code=400 |
| `register_ValidationFailed_UsernameTooShort` | 用户名过短 | HTTP 200, code=400 |
| `register_ValidationFailed_InvalidEmail` | 邮箱格式错误 | HTTP 200, code=400 |
| `register_ValidationFailed_EmptyPassword` | 密码为空 | HTTP 200, code=400 |

#### 2. 登录功能 (login)

| 测试方法 | 场景 | 预期结果 |
|----------|------|----------|
| `login_Success` | 正常登录，返回 Token | HTTP 200, code=200, 返回 token |
| `login_InvalidCredentials` | 用户名或密码错误 | HTTP 200, code=401 |
| `login_ValidationFailed_EmptyAccount` | 账号为空 | HTTP 200, code=400 |
| `login_ValidationFailed_EmptyPassword` | 密码为空 | HTTP 200, code=400 |

---

## UserController 测试覆盖

### API 端点

| 端点 | 方法 | 说明 |
|------|------|------|
| `/api/users` | GET | 获取所有用户 |
| `/api/users/{id}` | GET | 根据ID获取用户 |
| `/api/users` | POST | 创建用户 |
| `/api/users/{id}` | PUT | 更新用户 |
| `/api/users/{id}` | DELETE | 删除用户 |

### 测试用例详情

#### 1. 获取所有用户 (findAll)

| 测试方法 | 场景 | 预期结果 |
|----------|------|----------|
| `findAll_Success` | 成功返回用户列表 | HTTP 200, code=200, data.size=2 |
| `findAll_EmptyList` | 返回空列表 | HTTP 200, code=200, data.size=0 |

#### 2. 根据ID获取用户 (findById)

| 测试方法 | 场景 | 预期结果 |
|----------|------|----------|
| `findById_Success` | 用户存在 | HTTP 200, code=200, 返回用户信息 |
| `findById_NotFound` | 用户不存在 | HTTP 200, code=500 |
| `findById_InvalidId` | ID格式无效 | HTTP 200, code=500 |

#### 3. 创建用户 (create)

| 测试方法 | 场景 | 预期结果 |
|----------|------|----------|
| `create_Success` | 正常创建 | HTTP 200, code=200, 返回新用户 |
| `create_DuplicateUsername` | 用户名已存在 | HTTP 200, code=400 |
| `create_EmptyBody` | 请求体为空 | HTTP 200, code=500 |

#### 4. 更新用户 (update)

| 测试方法 | 场景 | 预期结果 |
|----------|------|----------|
| `update_Success` | 正常更新 | HTTP 200, code=200, 返回更新后用户 |
| `update_NotFound` | 用户不存在 | HTTP 200, code=500 |
| `update_DuplicateUsername` | 用户名已被使用 | HTTP 200, code=400 |

#### 5. 删除用户 (delete)

| 测试方法 | 场景 | 预期结果 |
|----------|------|----------|
| `delete_Success` | 正常删除 | HTTP 200, code=200 |
| `delete_NotFound` | 用户不存在 | HTTP 200, code=500 |
| `delete_CannotDeleteSelf` | 不能删除自己 | HTTP 200, code=400 |

---

## 测试技术说明

### 1. 注解说明

```java
@WebMvcTest(UserController.class)    // 仅加载 MVC 层，不加载完整的 Spring 上下文
@AutoConfigureMockMvc(addFilters = false)  // 配置 MockMvc，禁用过滤器
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;           // 模拟 HTTP 请求

    @MockBean
    private UserService userService;   // 模拟 Service 层
}
```

### 2. 常用测试方法

```java
// 模拟 GET 请求
mockMvc.perform(get("/api/users/1"))

// 模拟 POST 请求（带 JSON 请求体）
mockMvc.perform(post("/api/users")
        .contentType(MediaType.APPLICATION_JSON)
        .content(objectMapper.writeValueAsString(user)))

// 验证响应状态
.andExpect(status().isOk())

// 验证 JSON 响应字段
.andExpect(jsonPath("$.code").value(200))
.andExpect(jsonPath("$.data.username").value("testuser"))
.andExpect(jsonPath("$.data", hasSize(2)))

// 验证 Service 方法被调用
verify(userService, times(1)).findById(1L);
```

### 3. Mock 行为设置

```java
// 设置返回值
when(userService.findById(1L)).thenReturn(Optional.of(user));

// 设置异常抛出
when(userService.create(any())).thenThrow(new BusinessException(400, "用户名已存在"));
doThrow(new EntityNotFoundException("用户不存在")).when(userService).delete(999L);
```

---

## 运行测试

```bash
# 运行所有 Controller 测试
mvn test -Dtest=UserControllerTest,AuthControllerTest

# 运行单个测试类
mvn test -Dtest=UserControllerTest

# 查看测试报告
mvn test -Dtest=UserControllerTest,AuthControllerTest | grep -A 20 "Results:"
```

## 测试结果

```
Tests run: 24, Failures: 0, Errors: 0, Skipped: 0
BUILD SUCCESS
```

所有测试均已通过。
