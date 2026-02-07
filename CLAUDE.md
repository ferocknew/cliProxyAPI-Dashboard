# CLAUDE.md

本文件为 Claude Code (claude.ai/code) 在此仓库中工作时提供指导。

## 项目概述

CLIProxyAPI Dashboard 是一个基于 Go 的代理服务器，为 CLI 工具和编程助手提供与 OpenAI/Gemini/Claude 兼容的 API 接口。它作为多个 AI 提供商（Gemini、Claude、OpenAI、Qwen、iFlow、Vertex）的统一网关，支持 OAuth 认证、负载均衡和使用量跟踪。

**模块路径:** `github.com/router-for-me/CLIProxyAPI/v6`
**Go 版本:** 1.24.0
**Web 框架:** Gin (github.com/gin-gonic/gin)

---

## 常用开发命令

### 构建和运行 (Docker - 推荐)
```bash
# 构建并启动服务器
docker-compose up -d --build

# 查看日志
docker-compose logs -f

# 停止服务器
docker-compose down
```

### 构建和运行 (本地)
```bash
# 安装依赖
go mod download

# 运行服务器
go run cmd/server/main.go

# 构建二进制文件
go build -o cli-proxy-api cmd/server/main.go
```

### 测试
```bash
# 运行所有测试
go test ./...

# 运行测试（详细输出）
go test -v ./...

# 运行特定包的测试
go test ./internal/api
go test ./internal/auth/...

# 运行特定测试
go test -v ./internal/api -run TestAmpProviderModelRoutes
```

### 配置
```bash
# 从示例创建配置文件
cp config.example.yaml config.yaml

# 然后编辑 config.yaml
```

---

## 架构概览

### 目录结构（核心组件）

```
cmd/server/main.go          # 应用程序入口
internal/
├── api/                    # HTTP 服务器 (Gin)，路由，处理器
│   ├── handlers/           # 管理面板 API 端点
│   ├── modules/            # Amp CLI 集成和代理功能
│   └── server.go           # 主服务器设置
├── auth/                   # OAuth 认证提供商
│   ├── claude/             # Claude/Claude Code OAuth
│   ├── gemini/             # Gemini/Gemini CLI OAuth
│   ├── codex/              # OpenAI Codex OAuth
│   ├── qwen/               # Qwen Code OAuth
│   ├── iflow/              # iFlow OAuth
│   └── vertex/             # Vertex AI 服务账号认证
├── translator/             # API 格式转换器
│   ├── antigravity/        # Antigravity API 格式 (claude, gemini)
│   ├── openai/             # OpenAI API 格式 (claude, gemini, codex)
│   └── translator/         # 通用转换层
├── config/                 # 配置加载和验证
├── database/               # SQLite 使用统计存储
├── registry/               # 模型注册和路由
├── watcher/                # 配置文件变更检测和热重载
├── logging/                # 结构化日志 (logrus)
└── usage/                  # 使用跟踪和统计
sdk/                        # 可复用的 Go SDK（用于嵌入）
static/                     # 自定义管理面板 UI
```

### 请求流程

1. **HTTP 请求** → `internal/api/server.go` (Gin 路由)
2. **身份验证** → API 密钥验证 (config 中的 `api-keys`)
3. **模型路由** → `internal/registry/` 将模型映射到凭据
4. **格式转换** → `internal/translator/` 转换请求格式
5. **提供商认证** → `internal/auth/` 处理 OAuth/令牌刷新
6. **上游请求** → 转发到实际的 AI 提供商
7. **响应转换** → 转换回请求的格式
8. **使用记录** → `internal/usage/` 跟踪请求/令牌

### 核心设计模式

- **转换器模式**: 每个提供商 (claude, gemini, openai) 在 `internal/translator/` 中有专用转换器处理请求/响应格式转换
- **认证管理器模式**: `internal/auth/` 中特定提供商的认证实现共享通用接口进行令牌管理和刷新
- **注册表模式**: `internal/registry/` 维护模型到凭据的映射，支持前缀匹配和回退逻辑
- **监视器模式**: `internal/watcher/` 监控 config.yaml 变更并热重载无需重启

### 配置系统

- **文件**: `config.yaml` (从 `config.example.yaml` 复制)
- **关键设置**:
  - `remote-management.secret-key`: 管理面板认证密码
  - `remote-management.allow-remote`: 允许非本地访问管理面板
  - `api-keys`: 代理请求的有效 API 密钥列表
  - `auth-dir`: 存储 OAuth 凭据的目录 (~/.cli-proxy-api)
  - `routing.strategy`: 凭据选择策略 (round-robin 或 fill-first)

### 管理面板 UI

- **位置**: `static/` 目录 (management.html 和资源文件)
- **访问地址**: http://localhost:8317/management.html
- **自动更新**: 默认禁用 (docker-compose.yml 中设置 `MANAGEMENT_AUTO_UPDATE: "false"`)
- **功能**: 实时监控、OAuth 登录、使用统计、AI 游乐场

---

## 测试框架

- 使用标准 `testing` 包
- 测试文件: 源文件旁的 `*_test.go`
- 测试辅助函数: `internal/api/server_test.go` (如 `newTestServer()`)
- 运行单个测试: `go test -v ./path/to/package -run TestName`

---

## 重要说明

- **默认端口**: 8317 (可在 config.yaml 中配置)
- **日志文件**: 当 `logging-to-file: true` 时存储在 `logs/` 目录
- **使用数据库**: SQLite 数据库 (`usage.db`) 跟踪请求历史
- **Docker 挂载卷**: `./auth-dir`、`./logs`、`./static` 被挂载
- **提供商模型**: 每个提供商都有 `models.go` 定义支持的模型
- **Amp CLI**: `internal/api/modules/amp/` 中的特殊路由支持
