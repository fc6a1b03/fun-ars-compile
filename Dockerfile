# 使用官方Python基础镜像
FROM python:3.9-slim AS builder
WORKDIR /app
# 替换默认的apt-get源为阿里云镜像源
#RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.aliyun.com\/debian-security/g' /etc/apt/sources.list
# 安装必要的依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget git libsndfile1-dev ffmpeg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# 配置pip使用清华大学开源软件镜像站
# RUN mkdir -p /root/.pip && \
    echo "[global]" > /root/.pip/pip.conf && \
    echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> /root/.pip/pip.conf
# 安装pip包
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
# 复制应用程序代码
COPY . .

# =========================================================================================================

FROM python:3.9-alpine
WORKDIR /app
# 从builder阶段复制安装的依赖
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
# 复制应用程序代码
COPY --from=builder /app/sensevoice_offline_sdk.py /app/sensevoice_offline_sdk.py
# 运行应用
CMD ["python", "sensevoice_offline_sdk.py"]
