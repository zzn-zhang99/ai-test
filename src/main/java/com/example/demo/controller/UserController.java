package com.example.demo.controller;

import com.example.demo.common.Result;
import com.example.demo.domain.User;
import com.example.demo.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 用户接口层
 */
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping
    public Result<List<User>> getAllUsers() {
        return Result.success(userService.findAll());
    }

    @GetMapping("/{id}")
    public Result<User> getUser(@PathVariable Long id) {
        return userService.findById(id)
                .map(Result::success)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
    }

    @PostMapping
    public Result<User> createUser(@RequestBody User user) {
        return Result.success(userService.create(user));
    }

    @PutMapping("/{id}")
    public Result<User> updateUser(@PathVariable Long id, @RequestBody User user) {
        return Result.success(userService.update(id, user));
    }

    @DeleteMapping("/{id}")
    public Result<Void> deleteUser(@PathVariable Long id) {
        userService.delete(id);
        return Result.success();
    }
}
