package com.example.demo.controller;

import com.example.demo.common.exception.BusinessException;
import com.example.demo.domain.User;
import com.example.demo.service.UserService;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.EntityNotFoundException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.Collections;
import java.util.Optional;

import static org.hamcrest.Matchers.hasSize;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * 用户控制器单元测试
 * 使用 @WebMvcTest 模拟 MVC 层，@MockBean 模拟 Service 层
 */
@WebMvcTest(UserController.class)
@AutoConfigureMockMvc(addFilters = false)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @Autowired
    private ObjectMapper objectMapper;

    /**
     * 创建测试用户对象
     */
    private User createTestUser(Long id, String username, String email) {
        return User.builder()
                .id(id)
                .username(username)
                .email(email)
                .password("encrypted_password")
                .deleted(0)
                .build();
    }

    // ==================== GET /api/users ====================

    @Test
    @DisplayName("获取所有用户 - 成功返回用户列表")
    void findAll_Success() throws Exception {
        // Given
        User user1 = createTestUser(1L, "user1", "user1@example.com");
        User user2 = createTestUser(2L, "user2", "user2@example.com");
        when(userService.findAll()).thenReturn(Arrays.asList(user1, user2));

        // When & Then
        mockMvc.perform(get("/api/users"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.message").value("success"))
                .andExpect(jsonPath("$.data", hasSize(2)))
                .andExpect(jsonPath("$.data[0].id").value(1))
                .andExpect(jsonPath("$.data[0].username").value("user1"))
                .andExpect(jsonPath("$.data[0].email").value("user1@example.com"))
                .andExpect(jsonPath("$.data[1].id").value(2))
                .andExpect(jsonPath("$.data[1].username").value("user2"));

        verify(userService, times(1)).findAll();
    }

    @Test
    @DisplayName("获取所有用户 - 空列表")
    void findAll_EmptyList() throws Exception {
        // Given
        when(userService.findAll()).thenReturn(Collections.emptyList());

        // When & Then
        mockMvc.perform(get("/api/users"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.message").value("success"))
                .andExpect(jsonPath("$.data", hasSize(0)));
    }

    // ==================== GET /api/users/{id} ====================

    @Test
    @DisplayName("根据ID获取用户 - 成功")
    void findById_Success() throws Exception {
        // Given
        User user = createTestUser(1L, "testuser", "test@example.com");
        when(userService.findById(1L)).thenReturn(Optional.of(user));

        // When & Then
        mockMvc.perform(get("/api/users/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.message").value("success"))
                .andExpect(jsonPath("$.data.id").value(1))
                .andExpect(jsonPath("$.data.username").value("testuser"))
                .andExpect(jsonPath("$.data.email").value("test@example.com"));

        verify(userService, times(1)).findById(1L);
    }

    @Test
    @DisplayName("根据ID获取用户 - 用户不存在")
    void findById_NotFound() throws Exception {
        // Given
        when(userService.findById(999L)).thenReturn(Optional.empty());

        // When & Then - RuntimeException会被全局异常处理器捕获返回500
        mockMvc.perform(get("/api/users/999"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(500))
                .andExpect(jsonPath("$.message").value("系统繁忙，请稍后重试"));

        verify(userService, times(1)).findById(999L);
    }

    @Test
    @DisplayName("根据ID获取用户 - 无效ID格式")
    void findById_InvalidId() throws Exception {
        // When & Then - Spring 无法转换 "invalid" 为 Long，触发异常，被全局处理器捕获返回 500
        mockMvc.perform(get("/api/users/invalid"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(500))
                .andExpect(jsonPath("$.message").value("系统繁忙，请稍后重试"));
    }

    // ==================== POST /api/users ====================

    @Test
    @DisplayName("创建用户 - 成功")
    void create_Success() throws Exception {
        // Given
        User inputUser = User.builder()
                .username("newuser")
                .email("newuser@example.com")
                .password("password123")
                .build();

        User createdUser = createTestUser(1L, "newuser", "newuser@example.com");
        when(userService.create(any(User.class))).thenReturn(createdUser);

        // When & Then
        mockMvc.perform(post("/api/users")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(inputUser)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.message").value("success"))
                .andExpect(jsonPath("$.data.id").value(1))
                .andExpect(jsonPath("$.data.username").value("newuser"))
                .andExpect(jsonPath("$.data.email").value("newuser@example.com"));

        verify(userService, times(1)).create(any(User.class));
    }

    @Test
    @DisplayName("创建用户 - 用户名已存在")
    void create_DuplicateUsername() throws Exception {
        // Given
        User inputUser = User.builder()
                .username("existinguser")
                .email("test@example.com")
                .password("password123")
                .build();

        when(userService.create(any(User.class)))
                .thenThrow(new BusinessException(400, "用户名已存在"));

        // When & Then
        mockMvc.perform(post("/api/users")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(inputUser)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value("用户名已存在"));
    }

    @Test
    @DisplayName("创建用户 - 请求体为空")
    void create_EmptyBody() throws Exception {
        // When & Then - 请求体为空触发 HttpMessageNotReadableException，被全局处理器捕获返回 500
        mockMvc.perform(post("/api/users")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(500))
                .andExpect(jsonPath("$.message").value("系统繁忙，请稍后重试"));
    }

    // ==================== PUT /api/users/{id} ====================

    @Test
    @DisplayName("更新用户 - 成功")
    void update_Success() throws Exception {
        // Given
        User inputUser = User.builder()
                .username("updateduser")
                .email("updated@example.com")
                .password("newpassword")
                .build();

        User updatedUser = createTestUser(1L, "updateduser", "updated@example.com");
        when(userService.update(eq(1L), any(User.class))).thenReturn(updatedUser);

        // When & Then
        mockMvc.perform(put("/api/users/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(inputUser)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.message").value("success"))
                .andExpect(jsonPath("$.data.id").value(1))
                .andExpect(jsonPath("$.data.username").value("updateduser"))
                .andExpect(jsonPath("$.data.email").value("updated@example.com"));

        verify(userService, times(1)).update(eq(1L), any(User.class));
    }

    @Test
    @DisplayName("更新用户 - 用户不存在")
    void update_NotFound() throws Exception {
        // Given
        User inputUser = User.builder()
                .username("updateduser")
                .email("updated@example.com")
                .password("newpassword")
                .build();

        when(userService.update(eq(999L), any(User.class)))
                .thenThrow(new EntityNotFoundException("用户不存在"));

        // When & Then - EntityNotFoundException 被全局处理器捕获返回 500
        mockMvc.perform(put("/api/users/999")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(inputUser)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(500))
                .andExpect(jsonPath("$.message").value("系统繁忙，请稍后重试"));
    }

    @Test
    @DisplayName("更新用户 - 用户名已被其他用户使用")
    void update_DuplicateUsername() throws Exception {
        // Given
        User inputUser = User.builder()
                .username("takenusername")
                .email("test@example.com")
                .password("password")
                .build();

        when(userService.update(eq(1L), any(User.class)))
                .thenThrow(new BusinessException(400, "用户名已被使用"));

        // When & Then
        mockMvc.perform(put("/api/users/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(inputUser)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value("用户名已被使用"));
    }

    // ==================== DELETE /api/users/{id} ====================

    @Test
    @DisplayName("删除用户 - 成功")
    void delete_Success() throws Exception {
        // When & Then
        mockMvc.perform(delete("/api/users/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.message").value("success"));

        verify(userService, times(1)).delete(1L);
    }

    @Test
    @DisplayName("删除用户 - 用户不存在")
    void delete_NotFound() throws Exception {
        // Given
        doThrow(new EntityNotFoundException("用户不存在")).when(userService).delete(999L);

        // When & Then - EntityNotFoundException 被全局处理器捕获返回 500
        mockMvc.perform(delete("/api/users/999"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(500))
                .andExpect(jsonPath("$.message").value("系统繁忙，请稍后重试"));

        verify(userService, times(1)).delete(999L);
    }

    @Test
    @DisplayName("删除用户 - 不能删除自己")
    void delete_CannotDeleteSelf() throws Exception {
        // Given
        doThrow(new BusinessException(400, "不能删除当前登录用户")).when(userService).delete(1L);

        // When & Then
        mockMvc.perform(delete("/api/users/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value("不能删除当前登录用户"));
    }
}
