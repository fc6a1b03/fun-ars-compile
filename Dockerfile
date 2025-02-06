FROM python:3.9-slim AS builder
WORKDIR /app
# 安装必要的依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget git libsndfile1-dev ffmpeg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# 安装pip包
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
# 克隆ModelScope上的ASR模型仓库: https://modelscope.cn/models/iic/speech_data2vec_pretrain-zh-cn-aishell2-16k-pytorch
# RUN git clone --depth 1 https://www.modelscope.cn/iic/speech_data2vec_pretrain-zh-cn-aishell2-16k-pytorch.git models/asr
# 克隆ModelScope上的TTS模型仓库: https://modelscope.cn/models/iic/speech_sambert-hifigan_tts_zh-cn_16k 
# RUN git clone --depth 1 https://www.modelscope.cn/iic/speech_sambert-hifigan_tts_zh-cn_16k.git models/tts
# 复制应用程序代码
COPY . .

# =========================================================================================================

FROM python:3.9-alpine
WORKDIR /app
# 从builder阶段复制安装的依赖和模型
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
# COPY --from=builder /app/models /app/models
COPY --from=builder /app/sensevoice_offline_sdk.py /app/sensevoice_offline_sdk.py
# 运行应用
CMD ["python", "sensevoice_offline_sdk.py"]
