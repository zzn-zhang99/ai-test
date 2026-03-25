# ==================== 构建阶段 ====================
FROM maven:3.9.6-eclipse-temurin-17-alpine AS builder

# 设置工作目录
WORKDIR /app

# 复制 Maven 配置文件
COPY pom.xml .

# 下载依赖（利用 Docker 缓存层）
RUN mvn dependency:go-offline -B

# 复制源代码
COPY src ./src

# 打包应用（跳过测试）
RUN mvn clean package -DskipTests -B

# ==================== 运行阶段 ====================
FROM openjdk:17-slim

# 添加标签信息
LABEL maintainer="your-email@example.com"
LABEL description="Spring Boot Template Application"

# 设置工作目录
WORKDIR /app

# 创建非 root 用户运行应用
RUN addgroup --system spring && adduser --system --group spring

# 从构建阶段复制 JAR 文件
COPY --from=builder /app/target/*.jar app.jar

# 更改文件所有者
RUN chown -R spring:spring /app

# 切换到非 root 用户
USER spring

# 暴露应用端口
EXPOSE 8080

# 配置健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# 设置 JVM 参数（可根据需要调整）
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/./urandom"

# 启动应用
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
