# AGENTS.md

本文件为在 CLIProxyAPI 项目中工作的 AI 代理提供开发规范和指南。

## 项目基本信息

- **模块路径**: `github.com/router-for-me/CLIProxyAPI/v6`
- **Go 版本**: 1.24.0
- **Web 框架**: Gin (github.com/gin-gonic/gin)

---

## 开发命令

### 本地构建与运行

```bash
# 安装依赖
go mod download

# 运行服务器
go run cmd/server/main.go

# 构建二进制文件
go build -o cli-proxy-api cmd/server/main.go
```

### Docker 构建与运行（推荐）

```bash
# 构建并启动服务器
docker-compose up -d --build

# 查看日志
docker-compose logs -f

# 停止服务器
docker-compose down
```

### 测试命令

```bash
# 运行所有测试
go test ./...

# 运行测试并显示详细信息
go test -v ./...

# 运行特定包的测试
go test ./internal/api
go test ./internal/auth/...

# 运行单个测试（重要）
go test -v ./internal/api -run TestAmpProviderModelRoutes

# 运行单个测试文件
go test -v ./internal/database/sqlite_test.go

# 运行特定测试函数
go test -v -run TestDatabase_Flow ./internal/database/

# 查看测试覆盖率
go test -cover ./...
```

### 代码检查

```bash
# 格式化代码
gofmt -w internal/

# 检查代码格式
gofmt -d internal/

# 运行静态分析（如果有 golint）
golangci-lint run ./...
```

---

## 代码风格规范

### 导入（Imports）

导入应按以下顺序分组，各组之间留空行：

```go
import (
    // 标准库
    "context"
    "encoding/json"
    "fmt"
    "net/http"
    "os"
    "path/filepath"
    "strings"
    "sync"
    "time"

    // 第三方库（按字母顺序）
    "github.com/gin-gonic/gin"
    "github.com/sirupsen/logrus"
    "gopkg.in/yaml.v3"
)
```

### 命名规范

- **包名**: 使用简洁、有意义的单数形式，如 `config`、`auth`、`util`
- **文件名**: 使用下划线分隔的小写字母，如 `sqlite_test.go`
- **变量/函数**: 使用驼峰命名法（camelCase）
- **导出类型/函数**: 使用帕斯卡命名法（PascalCase）
- **常量**: 使用全大写加下划线，或帕斯卡命名法
- **接口名**: 以 `er` 结尾或使用描述性名称，如 `TokenStorage`、`Handler`

```go
// 变量示例
var (
    defaultPort    = 8317
    maxRetryCount  = 3
)

// 函数示例
func NewServer(cfg *Config, authManager *auth.Manager) *Server {
    return &Server{config: cfg}
}

// 类型示例
type Config struct {
    Host        string
    Port        int
    AuthDir     string
}

// 接口示例
type TokenStorage interface {
    SaveTokenToFile(path string) error
}
```

### 类型定义与标签

结构体字段应添加 JSON/YAML 标签，并编写详细的注释：

```go
// Config represents the application's configuration, loaded from a YAML file.
type Config struct {
    // Host is the network host/interface on which the API server will bind.
    Host string `yaml:"host" json:"host"`

    // Port is the network port on which the API server will listen.
    Port int `yaml:"port" json:"port"`

    // AuthDir is the directory where authentication token files are stored.
    AuthDir string `yaml:"auth-dir" json:"-"`
}
```

### 错误处理

- 使用 `errors` 包包装错误，提供上下文信息
- 避免在生产代码中使用 `panic`
- 对于可选参数，使用空值而非零值

```go
// 推荐的错误处理方式
if err != nil {
    return fmt.Errorf("failed to initialize database: %w", err)
}

// 使用 errors.Is 进行错误比较
if errors.Is(err, os.ErrNotExist) {
    // 处理文件不存在的情况
}
```

### 函数注释

每个导出的函数应有文档注释，说明其功能、参数和返回值：

```go
// SaveTokenToFile persists authentication tokens to the specified file path.
//
// Parameters:
//   - authFilePath: The file path where the authentication tokens should be saved
//
// Returns:
//   - error: An error if the save operation fails, nil otherwise
func SaveTokenToFile(authFilePath string) error {
    // 实现
}
```

### 包注释

每个包应以 `// Package xxx ...` 开头，提供包级文档：

```go
// Package config provides configuration management for the CLI Proxy API server.
// It handles loading and parsing YAML configuration files, and provides structured
// access to application settings including server port, authentication directory,
// debug settings, proxy configuration, and API keys.
package config
```

---

## 测试规范

### 测试文件命名

- 测试文件命名为 `*_test.go`，与源文件放在同一目录
- 测试辅助函数应标记为 `t.Helper()`

### 表驱动测试

使用表驱动测试模式，通过 `t.Run()` 运行各测试用例：

```go
func TestIsClaudeThinkingModel(t *testing.T) {
    tests := []struct {
        name     string
        model    string
        expected bool
    }{
        {"claude-sonnet thinking", "claude-sonnet-4-5-thinking", true},
        {"claude-opus thinking", "claude-opus-4-5-thinking", true},
        {"non-thinking model", "claude-sonnet-4-5", false},
    }

    for _, tt := range tests {
        tt := tt
        t.Run(tt.name, func(t *testing.T) {
            result := IsClaudeThinkingModel(tt.model)
            if result != tt.expected {
                t.Errorf("IsClaudeThinkingModel(%q) = %v, expected %v",
                    tt.model, result, tt.expected)
            }
        })
    }
}
```

### 测试辅助函数

```go
func newTestServer(t *testing.T) *Server {
    t.Helper()

    gin.SetMode(gin.TestMode)
    // ...
}
```

### 测试断言

使用 `testify/require` 进行断言：

```go
import "github.com/stretchr/testify/require"

func TestDatabase_Flow(t *testing.T) {
    require.NoError(t, err)
    require.Len(t, logs, 1)
    require.Equal(t, expected, actual)
}
```

---

## 目录结构规范

```
cmd/server/main.go          # 应用入口点
internal/                    # 内部包（不对外暴露）
├── api/                     # HTTP 服务器、路由、处理器
├── auth/                    # OAuth 认证提供者
├── config/                  # 配置加载和验证
├── database/                # SQLite 使用统计存储
├── logging/                 # 结构化日志
├── runtime/                 # 执行器
├── translator/              # API 格式转换器
├── usage/                   # 使用跟踪和统计
├── util/                    # 工具函数
└── watcher/                 # 配置文件监控和热重载
sdk/                         # 可复用的 Go SDK
static/                      # 管理 UI 静态文件
```

- `internal/` 目录下的包不应被外部引用
- SDK 包放在 `sdk/` 目录，供外部嵌入使用
- 测试文件与源文件放在同一目录

---

## 配置管理

- 配置文件：`config.yaml`（从 `config.example.yaml` 复制）
- 敏感配置（如密钥）使用环境变量或通过 YAML 配置
- 配置变更后自动热重载（通过 watcher）
