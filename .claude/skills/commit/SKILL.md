---
name: commit
description: 执行 git commit 操作
---
# Git Commit
执行 git commit 操作。
## 步骤
1. 执行 git status 查看变更文件
2. 执行 git diff 查看变更内容
3. 根据变更内容生成 commit message，格式：<type>: <description>
 - feat: 新功能
 - fix: 修复 bug
 - refactor: 重构
 - docs: 文档
 - test: 测试
 - chore: 构建/配置
4. 执行 git add .
5. 执行 git commit
