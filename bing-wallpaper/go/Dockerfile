# 第一阶段：构建 Go 应用
FROM golang:1.22-alpine AS builder

# 设置工作目录
WORKDIR /app

# 复制文件
COPY go.mod ./
COPY main.go ./

# 下载依赖（可选）
RUN go mod tidy

# 构建静态编译的可执行文件
RUN go build -o bing-wallpaper .

# 第二阶段：构建最小镜像
FROM alpine:latest

# 拷贝可执行文件
COPY --from=builder /app/bing-wallpaper /usr/local/bin/bing-wallpaper

# 设置运行端口
EXPOSE 8080

# 运行应用
ENTRYPOINT ["bing-wallpaper"]
