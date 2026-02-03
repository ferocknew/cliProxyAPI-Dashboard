FROM alpine:3.22.0

RUN apk add --no-cache tzdata

RUN mkdir /CLIProxyAPI

# 复制预编译文件
COPY app/CLIProxyAPI_*.tar.gz /tmp/

# 解压预编译文件
RUN tar -xzf /tmp/CLIProxyAPI_*.tar.gz -C /tmp/ && \
    mv /tmp/cli-proxy-api /CLIProxyAPI/CLIProxyAPI && \
    chmod +x /CLIProxyAPI/CLIProxyAPI

# 从压缩包中复制示例配置和 README
RUN tar -xzf /tmp/CLIProxyAPI_*.tar.gz -C /tmp/ config.example.yaml README.md && \
    mv /tmp/config.example.yaml /CLIProxyAPI/config.example.yaml && \
    rm -rf /tmp/*

WORKDIR /CLIProxyAPI

EXPOSE 8317

ENV TZ=Asia/Shanghai

RUN cp /usr/share/zoneinfo/${TZ} /etc/localtime && echo "${TZ}" > /etc/timezone

COPY static /CLIProxyAPI/static

CMD ["./CLIProxyAPI"]