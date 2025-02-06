FROM python:3.9-slim AS builder

# 设置工作目录
WORKDIR /app
# 安装必要的依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget libsndfile1-dev ffmpeg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# 安装pip包
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
# 复制应用程序代码
COPY . .

# ===========================================================================

FROM python:3.9-alpine

# 设置工作目录
WORKDIR /app
# 从builder阶段复制安装的依赖和模型
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=builder /app/sensevoice_offline_sdk.py /app/sensevoice_offline_sdk.py
# 运行应用
CMD ["python", "sensevoice_offline_sdk.py"]
