FROM alpine:3.22.0

RUN apk add --no-cache tzdata

RUN mkdir /CLIProxyAPI

# 复制预编译文件
COPY app/CLIProxyAPI_*.tar.gz /tmp/

# 解压预编译文件
RUN tar -xzf /tmp/CLIProxyAPI_*.tar.gz -C /tmp/ && \
    mv /tmp/cli-proxy-api /CLIProxyAPI/CLIProxyAPI && \
    chmod +x /CLIProxyAPI/CLIProxyAPI

# 清理临时文件
RUN rm -rf /tmp/*

# 从项目目录复制示例配置
COPY config.example.yaml /CLIProxyAPI/config.example.yaml

WORKDIR /CLIProxyAPI

EXPOSE 8317

ENV TZ=Asia/Shanghai

RUN cp /usr/share/zoneinfo/${TZ} /etc/localtime && echo "${TZ}" > /etc/timezone

COPY static /CLIProxyAPI/static

CMD ["./CLIProxyAPI"]