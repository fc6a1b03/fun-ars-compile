import os
import torch
import torchaudio
from transformers import AutoProcessor, AutoModelForCTC, MBart50Tokenizer, AutoModelForTextToSpeech
from flask import Flask, request, jsonify, send_file
from pydub import AudioSegment
import io
import scipy.io.wavfile as wavfile
import numpy as np

app = Flask(__name__)

# 加载音频转文本模型
asr_processor = AutoProcessor.from_pretrained("/app/models/asr")
asr_model = AutoModelForCTC.from_pretrained("/app/models/asr")

# 加载文本转语音模型
tts_tokenizer = MBart50Tokenizer.from_pretrained("facebook/mbart-large-50-many-to-one-mmt")
tts_model = AutoModelForTextToSpeech.from_pretrained("/app/models/tts")

@app.route('/audio_to_text', methods=['POST'])
def audio_to_text():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    
    audio_segment = AudioSegment.from_file(file)
    audio_tensor = torch.tensor(audio_segment.get_array_of_samples()).float().unsqueeze(0) / 32768.0
    
    with torch.no_grad():
        inputs = asr_processor(audio_tensor, sampling_rate=16_000, return_tensors="pt", padding=True)
        logits = asr_model(**inputs).logits
    
    predicted_ids = torch.argmax(logits, dim=-1)
    transcription = asr_processor.decode(predicted_ids[0])
    
    return jsonify({'transcription': transcription})

@app.route('/text_to_speech', methods=['POST'])
def text_to_speech():
    data = request.json
    if 'text' not in data:
        return jsonify({'error': 'No text provided'}), 400
    
    text = data['text']
    inputs = tts_tokenizer(text, return_tensors="pt")
    
    with torch.no_grad():
        speech = tts_model.generate_speech(inputs["input_ids"], speaker_embeddings=torch.randn(1, 256))
    
    sample_rate = 16000
    waveform = speech.numpy()
    
    # Save the waveform to an in-memory buffer
    out_wav = io.BytesIO()
    wavfile.write(out_wav, sample_rate, waveform.astype(np.int16))
    out_wav.seek(0)
    
    return send_file(out_wav, mimetype='audio/wav')

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
