# Sky-Bot 在 claw.cloud 容器服务上的部署指南

## 概述

本指南将帮助您在 claw.cloud 容器服务平台上部署 Sky-Bot 交易机器人。通过环境变量配置，您可以轻松地在云端运行这个自动化交易系统。

## 前置准备

### 1. 币安账户准备
- 注册并完成币安账户实名认证
- 创建 API 密钥对（建议使用子账户）
- 确保账户有足够的 USDT 余额用于交易
- 建议为机器人创建专用的子账户以提高安全性

### 2. claw.cloud 账户
- 注册 claw.cloud 账户
- 选择合适的容器服务套餐
- 确保有足够的资源配额

## 部署步骤

### 步骤 1: 准备代码

1. 将项目代码上传到 claw.cloud 或从 Git 仓库部署
2. 确保以下文件存在：
   - `Dockerfile.cloud` - 优化的容器镜像配置
   - `.env.cloud` - 环境变量模板
   - `docker-compose.cloud.yml` - 容器编排配置

### 步骤 2: 配置环境变量

在 claw.cloud 控制台的环境变量设置中配置以下变量：

#### 必填配置项

```bash
# 币安 API 配置
BINANCE_API_KEY=your_actual_api_key_here
BINANCE_API_SECRET=your_actual_api_secret_here

# 交易对配置
SYMBOLS=BNB/USDT,ETH/USDT

# 初始参数配置 (JSON格式)
INITIAL_PARAMS_JSON={"BNB/USDT": {"initial_base_price": 600.0, "initial_grid": 2.0}, "ETH/USDT": {"initial_base_price": 3000.0, "initial_grid": 2.5}}

# 交易配置
INITIAL_GRID=2.0
MIN_TRADE_AMOUNT=20.0
INITIAL_PRINCIPAL=1000.0
```

#### 可选配置项

```bash
# 通知配置
PUSHPLUS_TOKEN=your_pushplus_token_here

# Web UI 认证
WEB_USER=admin
WEB_PASSWORD=your_secure_password_here

# 功能开关
ENABLE_SAVINGS_FUNCTION=true

# 系统配置
TZ=Asia/Shanghai
LOG_LEVEL=INFO
API_TIMEOUT=10000
RECV_WINDOW=5000
```

#### 高级策略配置

```bash
# 网格策略参数
GRID_PARAMS_JSON={"min": 1.0, "max": 4.0, "volatility_threshold": {"ranges": [{"range": [0, 0.10], "grid": 1.0}, {"range": [0.10, 0.20], "grid": 2.0}, {"range": [0.20, 0.30], "grid": 3.0}, {"range": [0.30, 0.40], "grid": 4.0}, {"range": [0.40, 999], "grid": 4.0}]}}
```

### 步骤 3: 容器配置

1. **选择 Dockerfile**: 使用 `Dockerfile.cloud`
2. **设置端口映射**: 
   - 容器端口: `58181`
   - 外部端口: `58181` (或您偏好的端口)
3. **资源配置**:
   - 内存: 建议 512MB 以上
   - CPU: 建议 0.5 核心以上
4. **健康检查**: 启用健康检查，路径为 `/health`

### 步骤 4: 部署启动

1. 在 claw.cloud 控制台点击"部署"
2. 等待容器构建和启动
3. 检查容器状态和日志
4. 访问 Web UI: `http://your-domain:58181`

## 配置说明

### 环境变量详解

| 变量名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `BINANCE_API_KEY` | string | ✅ | 币安 API 密钥 |
| `BINANCE_API_SECRET` | string | ✅ | 币安 API 密钥 |
| `SYMBOLS` | string | ✅ | 交易对列表，逗号分隔 |
| `INITIAL_PARAMS_JSON` | JSON | ❌ | 各交易对初始参数 |
| `INITIAL_GRID` | float | ❌ | 默认网格大小 (%) |
| `MIN_TRADE_AMOUNT` | float | ❌ | 最小交易金额 (USDT) |
| `INITIAL_PRINCIPAL` | float | ❌ | 初始本金 (USDT) |
| `WEB_USER` | string | ❌ | Web UI 用户名 |
| `WEB_PASSWORD` | string | ❌ | Web UI 密码 |
| `PUSHPLUS_TOKEN` | string | ❌ | 消息推送 Token |

### 网格策略配置

网格策略会根据市场波动率自动调整：

- **低波动率 (0-10%)**: 网格大小 1.0%
- **中等波动率 (10-20%)**: 网格大小 2.0%
- **高波动率 (20-30%)**: 网格大小 3.0%
- **极高波动率 (30%+)**: 网格大小 4.0%

## 监控和维护

### 1. 日志监控

在 claw.cloud 控制台查看容器日志：
```bash
# 查看实时日志
docker logs -f sky-bot

# 查看最近日志
docker logs --tail 100 sky-bot
```

### 2. Web UI 监控

访问 Web UI 界面监控交易状态：
- URL: `http://your-domain:58181`
- 用户名: 环境变量 `WEB_USER` 设置的值
- 密码: 环境变量 `WEB_PASSWORD` 设置的值

### 3. 健康检查

容器会自动进行健康检查，检查路径为 `/health`。如果服务异常，容器会自动重启。

### 4. 资源监控

定期检查容器资源使用情况：
- CPU 使用率
- 内存使用率
- 网络流量
- 磁盘使用率

## 安全建议

### 1. API 密钥安全
- 使用币安子账户 API 密钥
- 限制 API 权限，只开启现货交易权限
- 定期轮换 API 密钥
- 不要在代码中硬编码密钥

### 2. 网络安全
- 设置强密码用于 Web UI 访问
- 考虑使用 HTTPS（如果 claw.cloud 支持）
- 限制访问 IP（如果平台支持）

### 3. 资金安全
- 设置合理的交易金额限制
- 定期检查账户余额和交易记录
- 启用币安账户的安全功能（如短信验证）

## 故障排除

### 常见问题

1. **容器启动失败**
   - 检查环境变量配置是否正确
   - 查看容器日志获取错误信息
   - 确认 API 密钥有效性

2. **无法访问 Web UI**
   - 检查端口映射配置
   - 确认防火墙设置
   - 验证容器是否正常运行

3. **交易异常**
   - 检查币安账户余额
   - 验证 API 权限设置
   - 查看交易日志

4. **性能问题**
   - 增加容器内存配额
   - 检查网络连接质量
   - 优化交易参数

### 日志分析

重要日志关键词：
- `ERROR`: 错误信息
- `WARNING`: 警告信息
- `交易执行`: 交易相关日志
- `网格调整`: 策略调整日志
- `资产报告`: 资产统计日志

## 更新和维护

### 1. 代码更新
1. 停止当前容器
2. 更新代码
3. 重新构建镜像
4. 启动新容器

### 2. 配置更新
1. 在 claw.cloud 控制台修改环境变量
2. 重启容器使配置生效

### 3. 备份数据
定期备份重要数据：
- 交易记录
- 配置文件
- 日志文件

## 支持和帮助

如果在部署过程中遇到问题：

1. 查看项目文档和 README
2. 检查 claw.cloud 平台文档
3. 查看容器日志进行故障排除
4. 联系技术支持

---

**免责声明**: 
- 本交易机器人仅供学习和研究使用
- 数字货币交易存在风险，请谨慎投资
- 使用前请充分了解相关风险
- 建议先在测试环境中验证策略效果