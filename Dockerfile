# 使用 FunASR 官方基础镜像
FROM registry.cn-hangzhou.aliyuncs.com/funasr_repo/funasr:${FUNASR_VERSION}

# 安装必要的依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    ffmpeg \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 配置 FunASR 服务
COPY models /workspace/FunASR/models

# 设置工作目录
WORKDIR /workspace/FunASR/runtime

# 创建一个自定义启动脚本
COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh

# 设置容器启动时运行的脚本
ENTRYPOINT ["entrypoint.sh"]
