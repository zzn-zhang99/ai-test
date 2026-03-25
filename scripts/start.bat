@echo off
chcp 65001 >nul
:: ===============================================================================
:: Spring Boot Template 启动脚本 (Windows)
:: ===============================================================================
:: 功能：自动检测 JAVA_HOME、MAVEN_HOME，支持参数化配置
:: 用法：start.bat [选项]
:: ===============================================================================

setlocal EnableDelayedExpansion

:: 默认配置
set "DEFAULT_PORT=8080"
set "DEFAULT_PROFILE=dev"

:: 颜色定义（Windows 10+ 支持 ANSI）
set "RED=[31m"
set "GREEN=[32m"
set "YELLOW=[33m"
set "BLUE=[34m"
set "NC=[0m"

:: 解析命令行参数
set "PORT=%DEFAULT_PORT%"
set "PROFILE=%DEFAULT_PROFILE%"
set "SKIP_TESTS=false"
set "BUILD_ONLY=false"
set "DAEMON_MODE=false"
set "CUSTOM_JAVA_HOME="
set "CUSTOM_MAVEN_HOME="

:parse_args
if "%~1"=="" goto :end_parse

if "%~1"=="-p" (
    set "PORT=%~2"
    shift
    shift
    goto :parse_args
)
if "%~1"=="--port" (
    set "PORT=%~2"
    shift
    shift
    goto :parse_args
)
if "%~1"=="-e" (
    set "PROFILE=%~2"
    shift
    shift
    goto :parse_args
)
if "%~1"=="--profile" (
    set "PROFILE=%~2"
    shift
    shift
    goto :parse_args
)
if "%~1"=="-j" (
    set "CUSTOM_JAVA_HOME=%~2"
    shift
    shift
    goto :parse_args
)
if "%~1"=="--java-home" (
    set "CUSTOM_JAVA_HOME=%~2"
    shift
    shift
    goto :parse_args
)
if "%~1"=="-m" (
    set "CUSTOM_MAVEN_HOME=%~2"
    shift
    shift
    goto :parse_args
)
if "%~1"=="--mvn-home" (
    set "CUSTOM_MAVEN_HOME=%~2"
    shift
    shift
    goto :parse_args
)
if "%~1"=="-s" (
    set "SKIP_TESTS=true"
    shift
    goto :parse_args
)
if "%~1"=="--skip-tests" (
    set "SKIP_TESTS=true"
    shift
    goto :parse_args
)
if "%~1"=="-b" (
    set "BUILD_ONLY=true"
    shift
    goto :parse_args
)
if "%~1"=="--build-only" (
    set "BUILD_ONLY=true"
    shift
    goto :parse_args
)
if "%~1"=="-d" (
    set "DAEMON_MODE=true"
    shift
    goto :parse_args
)
if "%~1"=="--daemon" (
    set "DAEMON_MODE=true"
    shift
    goto :parse_args
)
if "%~1"=="-h" goto :print_help
if "%~1"=="--help" goto :print_help

echo [ERROR] 未知选项: %~1
goto :print_help

:end_parse

:: 切换到脚本所在目录
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%\.."
set "PROJECT_ROOT=%CD%"

:: 检查 pom.xml
if not exist "pom.xml" (
    echo [ERROR] 未找到 pom.xml，请确保在正确的项目目录中运行此脚本
    exit /b 1
)

:: ============ 检测 Java 环境 ============
echo.
echo [STEP] 检测 Java 环境...

:: 优先使用命令行参数指定的 JAVA_HOME
if not "%CUSTOM_JAVA_HOME%"=="" (
    set "JAVA_HOME=%CUSTOM_JAVA_HOME%"
    echo [INFO] 使用命令行指定的 JAVA_HOME: %JAVA_HOME%
)

:: 检查 JAVA_HOME
if "%JAVA_HOME%"=="" (
    :: 尝试从注册表查找
    for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\JavaSoft\Java Development Kit" /v CurrentVersion 2^>nul') do set "JDK_VERSION=%%b"
    if not "!JDK_VERSION!"=="" (
        for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\JavaSoft\Java Development Kit\!JDK_VERSION!" /v JavaHome 2^>nul') do set "JAVA_HOME=%%b"
    )

    :: 尝试查找 javac
    if "%JAVA_HOME%"=="" (
        where java >nul 2>&1
        if !ERRORLEVEL! equ 0 (
            for /f "delims=" %%i in ('where java') do (
                set "JAVA_CMD=%%~dpi"
                :: 获取上级目录
                set "DETECTED_JAVA_HOME=!JAVA_CMD:~0,-5!"
                echo [WARN] 未设置 JAVA_HOME，使用检测到的路径: !DETECTED_JAVA_HOME!
                set "JAVA_HOME=!DETECTED_JAVA_HOME!"
            )
        )
    )

    if "%JAVA_HOME%"=="" (
        echo [ERROR] 未找到 Java，请设置 JAVA_HOME 环境变量或使用 -j 参数指定
        exit /b 1
    )
) else (
    echo [INFO] 使用 JAVA_HOME: %JAVA_HOME%
)

:: 验证 Java 版本
if exist "%JAVA_HOME%\bin\java.exe" (
    for /f "tokens=3" %%v in ('"%JAVA_HOME%\bin\java.exe" -version 2^>^&1 ^| findstr /i "version"') do (
        set "JAVA_VERSION=%%v"
        set "JAVA_VERSION=!JAVA_VERSION:"=!"
        for /f "delims=." %%i in ("!JAVA_VERSION!") do set "JAVA_MAJOR=%%i"
    )

    if !JAVA_MAJOR! LSS 17 (
        echo [ERROR] 需要 Java 17 或更高版本，当前版本: !JAVA_VERSION!
        exit /b 1
    )
    echo [INFO] Java 版本: !JAVA_VERSION!
) else (
    echo [ERROR] 在 %JAVA_HOME%\bin\java.exe 未找到可执行的 Java
    exit /b 1
)

:: ============ 检测 Maven 环境 ============
echo.
echo [STEP] 检测 Maven 环境...

:: 优先使用命令行参数指定的 MAVEN_HOME
if not "%CUSTOM_MAVEN_HOME%"=="" (
    set "MAVEN_HOME=%CUSTOM_MAVEN_HOME%"
    echo [INFO] 使用命令行指定的 MAVEN_HOME: %MAVEN_HOME%
)

if "%MAVEN_HOME%"=="" (
    :: 尝试从环境变量 PATH 查找
    where mvn >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        echo [INFO] 使用系统 Maven
        set "MVN=mvn"
    ) else (
        :: 尝试常见安装路径
        set "COMMON_MAVEN_PATHS=C:\apache-maven;C:\Program Files\apache-maven;C:\Program Files (x86)\apache-maven;%USERPROFILE%\apache-maven"
        for %%p in (!COMMON_MAVEN_PATHS!) do (
            if exist "%%p\bin\mvn.cmd" (
                set "MAVEN_HOME=%%p"
                echo [WARN] 未设置 MAVEN_HOME，使用检测到的路径: %%p
                goto :found_maven
            )
        )
        echo [ERROR] 未找到 Maven，请安装 Maven 或设置 MAVEN_HOME
        exit /b 1
    )
) else (
    echo [INFO] 使用 MAVEN_HOME: %MAVEN_HOME%
)

:found_maven
if "%MVN%"=="" (
    if not "%MAVEN_HOME%"=="" (
        set "MVN=%MAVEN_HOME%\bin\mvn.cmd"
    ) else (
        set "MVN=mvn"
    )
)

:: 验证 Maven
"%MVN%" -version >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo [ERROR] Maven 验证失败
    exit /b 1
)

echo [INFO] Maven 路径: %MVN%
echo [INFO] 项目目录: %PROJECT_ROOT%

:: ============ 开始构建 ============
echo.
echo [STEP] 开始构建项目...

set MVN_OPTS=-P%PROFILE%

if "%SKIP_TESTS%"=="true" (
    set MVN_OPTS=%MVN_OPTS% -DskipTests
    echo [INFO] 跳过测试编译
)

:: 设置端口环境变量
set SERVER_PORT=%PORT%

:: 执行构建
echo [INFO] 执行: %MVN% clean package %MVN_OPTS%
"%MVN%" clean package %MVN_OPTS%

if !ERRORLEVEL! neq 0 (
    echo [ERROR] 构建失败
    exit /b 1
)

echo [INFO] 构建成功

:: 如果仅构建，则退出
if "%BUILD_ONLY%"=="true" (
    echo [INFO] 构建完成，跳过启动
    exit /b 0
)

:: ============ 查找 JAR 包 ============
for /f "delims=" %%a in ('dir /b target\*.jar 2^>nul ^| findstr /v "sources" ^| findstr /v "javadoc"') do (
    set "JAR_FILE=target\%%a"
)

if "%JAR_FILE%"=="" (
    echo [ERROR] 未找到生成的 JAR 包
    exit /b 1
)

echo [INFO] JAR 包: %JAR_FILE%

:: ============ 启动应用 ============
echo.
echo [STEP] 启动应用...
echo [INFO] 环境: %PROFILE%
echo [INFO] 端口: %PORT%

:: 创建日志目录
if not exist "logs" mkdir logs

:: 构建启动命令
set START_CMD="%JAVA_HOME%\bin\java.exe" -jar "%JAR_FILE%" --server.port=%PORT% --spring.profiles.active=%PROFILE%

if "%DAEMON_MODE%"=="true" (
    :: 后台运行
    echo [INFO] 后台模式启动，日志输出到 logs\app.log
    start /B %START_CMD% > logs\app.log 2>&1
    for /f "tokens=2" %%a in ('tasklist ^| findstr java.exe') do (
        echo [INFO] 应用已启动，PID: %%a
        exit /b 0
    )
) else (
    :: 前台运行
    echo [INFO] 启动命令: %START_CMD%
    echo ===================================================================
    %START_CMD%
)

exit /b 0

:: ============ 帮助信息 ============
:print_help
echo Spring Boot Template 启动脚本
echo.
echo 用法: start.bat [选项]
echo.
echo 选项:
echo   -p, --port ^<端口^>        指定服务端口 (默认: %DEFAULT_PORT%)
echo   -e, --profile ^<环境^>     指定运行环境: dev^|test^|prod (默认: %DEFAULT_PROFILE%)
echo   -j, --java-home ^<路径^>   指定 JAVA_HOME
echo   -m, --mvn-home ^<路径^>    指定 MAVEN_HOME
echo   -s, --skip-tests         跳过测试编译
echo   -b, --build-only         仅编译，不启动
echo   -d, --daemon             后台运行
echo   -h, --help               显示此帮助
echo.
echo 环境变量:
echo   JAVA_HOME       JDK 安装路径
echo   MAVEN_HOME      Maven 安装路径
echo.
echo 示例:
echo   start.bat                           使用默认配置启动
echo   start.bat -p 8081 -e prod           使用 8081 端口，生产环境启动
echo   start.bat -j C:\java\jdk17 -s       指定 JDK，跳过测试
echo   start.bat -d                        后台运行

exit /b 0
