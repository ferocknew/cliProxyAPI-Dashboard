# CLIProxyAPI 预编译文件

本目录存放 CLIProxyAPI 的预编译二进制文件，用于 Docker 构建。

## 文件命名规范

```
CLIProxyAPI_{VERSION}_{OS}_{ARCH}.tar.gz
```

- **VERSION**: 版本号，例如 `6.7.42`
- **OS**: 操作系统，例如 `linux`
- **ARCH**: 架构，例如 `amd64`、`arm64`

## 当前版本

- **文件名**: `CLIProxyAPI_6.7.42_linux_amd64.tar.gz`
- **版本**: 6.7.42
- **平台**: Linux amd64

## 下载地址

官方发布地址：https://github.com/router-for-me/CLIProxyAPI/releases

下载步骤：
1. 访问 [CLIProxyAPI Releases](https://github.com/router-for-me/CLIProxyAPI/releases)
2. 选择对应的版本
3. 下载 `CLIProxyAPI_{VERSION}_linux_amd64.tar.gz` 文件
4. 将文件放到本目录下

## 版本更新

当需要更新到新版本时：

1. 删除旧版本文件
2. 从官方发布页下载新版本文件
3. 更新 Dockerfile 中的 `CLI_PROXY_VERSION` 环境变量
4. 重新构建 Docker 镜像：`docker-compose build`

## 注意事项

- 仅支持 Linux amd64 平台的预编译文件
- 压缩包内必须包含 `cli-proxy-api` 可执行文件
- 文件名必须遵循命名规范，以便 Dockerfile 自动提取版本号