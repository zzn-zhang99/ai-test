package com.example.demo.service;

import com.example.demo.domain.User;

import java.util.List;
import java.util.Optional;

/**
 * 用户业务服务接口
 */
public interface UserService {

    /**
     * 查询所有用户
     *
     * @return 用户列表
     */
    List<User> findAll();

    /**
     * 根据ID查询用户
     *
     * @param id 用户ID
     * @return 用户对象
     */
    Optional<User> findById(Long id);

    /**
     * 根据用户名查询用户
     *
     * @param username 用户名
     * @return 用户对象
     */
    Optional<User> findByUsername(String username);

    /**
     * 创建用户
     *
     * @param user 用户对象
     * @return 创建后的用户
     */
    User create(User user);

    /**
     * 更新用户
     *
     * @param id   用户ID
     * @param user 用户对象
     * @return 更新后的用户
     */
    User update(Long id, User user);

    /**
     * 删除用户
     *
     * @param id 用户ID
     */
    void delete(Long id);
}
