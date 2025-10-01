# ========== claw.cloud 容器服务专用 Dockerfile ==========
# 针对容器服务环境优化的 Docker 镜像构建文件

# 使用官方 Python 3.10 slim 镜像作为基础镜像
FROM python:3.10-slim

# 设置维护者信息
LABEL maintainer="Sky-Bot"
LABEL description="Sky-Bot USDT Trading Bot for claw.cloud container service"

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    TZ=Asia/Shanghai

# 安装系统依赖和时区数据
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    curl \
    ca-certificates \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 创建非 root 用户以提高安全性
RUN groupadd -r appuser && useradd -r -g appuser appuser

# 复制 requirements.txt 并安装 Python 依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用程序代码
COPY . .

# 创建数据目录并设置权限
RUN mkdir -p /app/data /app/logs \
    && chown -R appuser:appuser /app

# 切换到非 root 用户
USER appuser

# 暴露应用端口 (Web UI)
EXPOSE 58181

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:58181/health || exit 1

# 设置启动命令
CMD ["python", "main.py"]

# ========== 构建说明 ==========
# 1. 在项目根目录执行: docker build -t sky-bot .
# 2. 运行容器: docker run -d --name sky-bot -p 58181:58181 --env-file .env sky-bot
# 3. 或者直接在 claw.cloud 控制台中使用此 Dockerfile 进行部署

# ========== 优化特性 ==========
# - 使用 slim 镜像减小镜像大小
# - 多阶段构建优化 (如需要可进一步优化)
# - 非 root 用户运行提高安全性
# - 健康检查确保服务可用性
# - 环境变量优化 Python 运行时
# - 清理 apt 缓存减小镜像大小