#!/bin/bash
# =============================================================================
# Spring Boot Template 启动脚本 (Linux/Mac)
# =============================================================================
# 功能：自动检测 JAVA_HOME、MAVEN_HOME，支持参数化配置
# 用法：./start.sh [选项]
# =============================================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认配置
DEFAULT_PORT=8080
DEFAULT_PROFILE="dev"

# 打印帮助信息
print_help() {
    echo -e "${BLUE}Spring Boot Template 启动脚本${NC}"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -p, --port <端口>        指定服务端口 (默认: $DEFAULT_PORT)"
    echo "  -e, --profile <环境>     指定运行环境: dev|test|prod (默认: $DEFAULT_PROFILE)"
    echo "  -j, --java-home <路径>   指定 JAVA_HOME"
    echo "  -m, --mvn-home <路径>    指定 MAVEN_HOME"
    echo "  -s, --skip-tests         跳过测试编译"
    echo "  -b, --build-only         仅编译，不启动"
    echo "  -d, --daemon             后台运行"
    echo "  -h, --help               显示此帮助"
    echo ""
    echo "环境变量:"
    echo "  JAVA_HOME       JDK 安装路径"
    echo "  MAVEN_HOME      Maven 安装路径"
    echo ""
    echo "示例:"
    echo "  $0                           使用默认配置启动"
    echo "  $0 -p 8081 -e prod           使用 8081 端口，生产环境启动"
    echo "  $0 -j /opt/java17 -s         指定 JDK，跳过测试"
    echo "  $0 -d                        后台运行"
}

# 打印带颜色的信息
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 解析命令行参数
PORT=$DEFAULT_PORT
PROFILE=$DEFAULT_PROFILE
SKIP_TESTS=false
BUILD_ONLY=false
DAEMON_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -e|--profile)
            PROFILE="$2"
            shift 2
            ;;
        -j|--java-home)
            JAVA_HOME="$2"
            shift 2
            ;;
        -m|--mvn-home)
            MAVEN_HOME="$2"
            shift 2
            ;;
        -s|--skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        -b|--build-only)
            BUILD_ONLY=true
            shift
            ;;
        -d|--daemon)
            DAEMON_MODE=true
            shift
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            log_error "未知选项: $1"
            print_help
            exit 1
            ;;
    esac
done

# 检测 JAVA_HOME
log_step "检测 Java 环境..."

if [[ -z "$JAVA_HOME" ]]; then
    # 尝试从环境变量获取
    if command -v java &> /dev/null; then
        JAVA_CMD=$(command -v java)
        # 尝试解析 JAVA_HOME
        if [[ -L "$JAVA_CMD" ]]; then
            JAVA_CMD=$(readlink -f "$JAVA_CMD")
        fi
        DETECTED_JAVA_HOME=$(dirname "$(dirname "$JAVA_CMD")")
        log_warn "未设置 JAVA_HOME，使用检测到的路径: $DETECTED_JAVA_HOME"
        JAVA_HOME=$DETECTED_JAVA_HOME
    else
        log_error "未找到 Java，请设置 JAVA_HOME 环境变量或使用 -j 参数指定"
        exit 1
    fi
else
    log_info "使用 JAVA_HOME: $JAVA_HOME"
fi

# 验证 Java 版本
if [[ -x "$JAVA_HOME/bin/java" ]]; then
    JAVA_VERSION=$($JAVA_HOME/bin/java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
    if [[ "$JAVA_VERSION" -ge 17 ]]; then
        log_info "Java 版本: $(java -version 2>&1 | head -n 1)"
    else
        log_error "需要 Java 17 或更高版本，当前版本: $JAVA_VERSION"
        exit 1
    fi
else
    log_error "在 $JAVA_HOME/bin/java 未找到可执行的 Java"
    exit 1
fi

export JAVA_HOME

# 检测 MAVEN_HOME
log_step "检测 Maven 环境..."

if [[ -z "$MAVEN_HOME" ]]; then
    if command -v mvn &> /dev/null; then
        MVN_CMD=$(command -v mvn)
        log_info "使用系统 Maven: $MVN_CMD"
        MVN="mvn"
    else
        # 尝试常见安装路径
        COMMON_MAVEN_PATHS=(
            "$HOME/apache-maven"
            "/usr/local/apache-maven"
            "/opt/apache-maven"
            "/usr/share/maven"
        )
        for path in "${COMMON_MAVEN_PATHS[@]}"; do
            if [[ -x "$path/bin/mvn" ]]; then
                MAVEN_HOME=$path
                log_warn "未设置 MAVEN_HOME，使用检测到的路径: $MAVEN_HOME"
                break
            fi
        done

        if [[ -z "$MAVEN_HOME" ]]; then
            log_error "未找到 Maven，请安装 Maven 或设置 MAVEN_HOME"
            exit 1
        fi
    fi
else
    log_info "使用 MAVEN_HOME: $MAVEN_HOME"
    export MAVEN_HOME
    MVN="$MAVEN_HOME/bin/mvn"
fi

if [[ -z "$MVN" ]]; then
    MVN="mvn"
fi

# 验证 Maven
$MVN -version > /dev/null 2>&1 || {
    log_error "Maven 验证失败"
    exit 1
}

# 检查项目目录
PROJECT_ROOT=$(dirname "$(dirname "$0")")
cd "$PROJECT_ROOT"

if [[ ! -f "pom.xml" ]]; then
    log_error "未找到 pom.xml，请确保在正确的项目目录中运行此脚本"
    exit 1
fi

log_info "项目目录: $(pwd)"

# 构建 Maven 命令
log_step "开始构建项目..."

MVN_OPTS="-P$PROFILE"

if [[ "$SKIP_TESTS" == true ]]; then
    MVN_OPTS="$MVN_OPTS -DskipTests"
    log_info "跳过测试编译"
fi

# 设置端口
export SERVER_PORT=$PORT

# 执行构建
log_info "执行: $MVN clean package $MVN_OPTS"
$MVN clean package $MVN_OPTS

if [[ $? -ne 0 ]]; then
    log_error "构建失败"
    exit 1
fi

log_info "构建成功"

# 如果仅构建，则退出
if [[ "$BUILD_ONLY" == true ]]; then
    log_info "构建完成，跳过启动"
    exit 0
fi

# 查找生成的 JAR 包
JAR_FILE=$(find target -name "*.jar" -not -name "*sources*" -not -name "*javadoc*" | head -n 1)

if [[ -z "$JAR_FILE" ]]; then
    log_error "未找到生成的 JAR 包"
    exit 1
fi

log_info "JAR 包: $JAR_FILE"

# 启动应用
log_step "启动应用..."
log_info "环境: $PROFILE"
log_info "端口: $PORT"

# 创建日志目录
mkdir -p logs

# 构建启动命令
START_CMD="$JAVA_HOME/bin/java -jar \"$JAR_FILE\" --server.port=$PORT --spring.profiles.active=$PROFILE"

if [[ "$DAEMON_MODE" == true ]]; then
    # 后台运行
    log_info "后台模式启动，日志输出到 logs/app.log"
    nohup $START_CMD > logs/app.log 2>&1 &
    PID=$!
    echo $PID > logs/app.pid
    log_info "应用已启动，PID: $PID"
    log_info "查看日志: tail -f logs/app.log"
else
    # 前台运行
    log_info "启动命令: $START_CMD"
    echo "================================================"
    $START_CMD
fi
