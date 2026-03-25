# VSCode 开发环境配置指南

## 项目信息
- **JDK**: 17+
- **Spring Boot**: 3.2.12
- **构建工具**: Maven 3.9+

---

## 一、安装必要扩展

打开 VSCode，按 `Ctrl+Shift+X` 打开扩展面板，搜索并安装以下扩展：

### 必装扩展（Java 开发基础）
| 扩展名 | 说明 |
|--------|------|
| **Extension Pack for Java** | Java 开发基础包（含6个核心扩展） |
| **Spring Boot Extension Pack** | Spring Boot 开发支持 |
| **Lombok Annotations Support** | Lombok 注解支持 |

> 快捷方式：项目已配置 `.vscode/extensions.json`，首次打开时会自动推荐以上扩展。

---

## 二、JDK 路径配置

### 1. 确认本地 JDK 安装位置
```cmd
# Windows 命令行执行
echo %JAVA_HOME%
# 输出示例: E:\Java\jdk17.0.16
```

### 2. 配置 VSCode Java 路径

编辑 `.vscode/settings.json`：

```json
{
    "java.jdt.ls.java.home": "E:\\Java\\jdk17.0.16",
    "java.configuration.runtimes": [
        {
            "name": "JavaSE-17",
            "path": "E:\\Java\\jdk17.0.16",
            "default": true
        }
    ],
    "maven.terminal.customEnv": [
        {
            "environmentVariable": "JAVA_HOME",
            "value": "E:\\Java\\jdk17.0.16"
        }
    ]
}
```

### 3. 验证配置
在 VSCode 中按 `Ctrl+Shift+P`，输入并执行：
```
> Java: Configure Java Runtime
```
确认显示 JDK 17 即可。

---

## 三、Maven 命令运行

### 方式一：VSCode 任务快捷键（推荐）

按 `Ctrl+Shift+P`，输入 `Tasks: Run Task`，选择以下任务：

| 任务名称 | 功能 |
|----------|------|
| `Maven: Clean Compile` | 清理并编译 |
| `Maven: Clean Package` | 打包项目（跳过测试）|
| `Maven: Run Tests` | 运行单元测试 |
| `Maven: Spring Boot Run` | 启动 Spring Boot 应用 |
| `Maven: Generate Dependency Tree` | 查看依赖树 |

### 方式二：终端直接执行

```bash
# 编译项目
mvn clean compile

# 打包（跳过测试）
mvn clean package -DskipTests

# 运行测试
mvn test

# 启动 Spring Boot
mvn spring-boot:run

# 查看依赖树
mvn dependency:tree
```

---

## 四、Spring Boot 启动方式

### 方式一：VSCode 调试启动（推荐）

1. 按 `F5` 或 `Ctrl+Shift+D` 打开调试面板
2. 选择配置：**"Launch DemoApplication"**
3. 按 `F5` 启动调试

### 方式二：使用 Spring Boot Dashboard

1. 安装 **Spring Boot Dashboard** 扩展
2. 点击左侧活动栏的 **Spring Boot** 图标
3. 右键点击 `com.example.demo.DemoApplication` → **Run**

### 方式三：Maven 命令

```bash
# 开发模式启动（热部署）
mvn spring-boot:run

# 指定 profile 启动
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

### 方式四：Java 直接运行

```bash
# 先打包
mvn clean package -DskipTests

# 运行 jar
java -jar target/spring-boot-template-1.0.0.jar
```

---

## 五、调试配置

### 启动调试
1. 在代码中点击行号左侧设置断点
2. 选择调试配置 **"Launch DemoApplication (Debug)"**
3. 按 `F5` 启动调试

### 常用调试快捷键
| 快捷键 | 功能 |
|--------|------|
| `F5` | 继续运行/启动调试 |
| `F10` | 单步跳过 |
| `F11` | 单步进入 |
| `Shift+F11` | 单步跳出 |
| `Shift+F5` | 停止调试 |

---

## 六、配置文件说明

### 已配置清单
项目已包含完整的 `.vscode` 配置，无需重复设置：

| 文件 | 作用 |
|------|------|
| `settings.json` | Java/Maven/Spring Boot 配置 |
| `launch.json` | 调试启动配置 |
| `tasks.json` | Maven 任务快捷方式 |
| `extensions.json` | 推荐扩展列表 |

### 主要配置项
```json
{
    // Java JDK 路径
    "java.jdt.ls.java.home": "E:\\Java\\jdk17.0.16",

    // 自动编译
    "java.configuration.updateBuildConfiguration": "automatic",

    // 保存时格式化
    "editor.formatOnSave": true,

    // 自动导入
    "editor.codeActionsOnSave": {
        "source.organizeImports": "explicit"
    },

    // Spring Boot 版本检查
    "spring-boot.ls.problem.version-validation.LOWEST_COMPATIBLE_VERSION": "3.2.0"
}
```

---

## 七、常见问题

### Q1: Java 扩展报错 "JDK not found"
**解决**：检查 `settings.json` 中的 `java.jdt.ls.java.home` 路径是否正确。

### Q2: Maven 命令找不到
**解决**：确保 Maven 已添加到系统 PATH，或在 VSCode 中安装 Maven 扩展。

### Q3: Lombok 注解不生效
**解决**：
1. 确保安装了 **Lombok Annotations Support** 扩展
2. 确保 `pom.xml` 中已添加 Lombok 依赖
3. 重启 VSCode

### Q4: 依赖下载慢
**解决**：在 `~/.m2/settings.xml` 中配置阿里云镜像：
```xml
<mirrors>
    <mirror>
        <id>aliyunmaven</id>
        <mirrorOf>*</mirrorOf>
        <name>阿里云公共仓库</name>
        <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
</mirrors>
```

---

## 八、开发工作流

### 标准开发流程
```
1. 打开 VSCode，等待 Java 项目加载完成（状态栏显示 "Ready"）
2. 按 Ctrl+Shift+P → Tasks: Run Task → Maven: Spring Boot Run
3. 访问 http://localhost:8080 验证应用启动
4. 开发代码，保存后自动编译
5. 使用 F5 启动调试模式进行断点调试
```

---

## 参考资料
- [VSCode Java 官方文档](https://code.visualstudio.com/docs/java/java-tutorial)
- [Spring Boot in VSCode](https://code.visualstudio.com/docs/java/java-spring-boot)
