#!/bin/bash
set -e

# 启动 FunASR 服务
bash run_server.sh \
  # 关闭ssl
  --certfile 0
  # 指定下载模型的目录，确保所有模型都存储在此目录
  --download-model-dir /workspace/FunASR/models \  
  # 指定语音端点检测（VAD）模型的路径
  # https://modelscope.cn/models/iic/speech_fsmn_vad_zh-cn-16k-common-onnx
  --vad-dir /workspace/FunASR/models/speech_fsmn_vad_zh-cn-16k-common-onnx \  
  # 指定语音识别（ASR）模型的路径
  # https://modelscope.cn/models/iic/speech_paraformer-large-vad-punc_asr_nat-zh-cn-16k-common-vocab8404-onnx
  --model-dir /workspace/FunASR/models/speech_paraformer-large-vad-punc_asr_nat-zh-cn-16k-common-vocab8404-onnx \
  # 指定标点预测（PUNC）模型的路径
  # https://modelscope.cn/models/iic/punc_ct-transformer_cn-en-common-vocab471067-large-onnx
  --punc-dir /workspace/FunASR/models/punc_ct-transformer_cn-en-common-vocab471067-large-onnx \  
  # 指定语言模型（LM）的路径，用于提高识别的准确性
  # https://modelscope.cn/models/iic/speech_ngram_lm_zh-cn-ai-wesp-fst
  --lm-dir /workspace/FunASR/models/speech_ngram_lm_zh-cn-ai-wesp-fst \  
  # 指定反标准化（ITN）模型的路径，用于将数字和缩写转换为文本形式
  # https://modelscope.cn/models/thuduj12/fst_itn_zh
  --itn-dir /workspace/FunASR/models/fst_itn_zh \
  # 指定热词文件的路径，用于提高特定词汇的识别准确率
  --hotword /workspace/FunASR/models/hotwords.txt
