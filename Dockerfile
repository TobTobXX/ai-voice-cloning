# Use an official Python runtime as a parent image
FROM docker.io/python:3.11

# Install PyTorch with CUDA 12.4 support
RUN pip install --no-cache-dir --pre \
	torch==2.5.0.dev20240816+cu124 \
	torchvision==0.20.0.dev20240816+cu124 \
	torchaudio==2.4.0.dev20240816+cu124 \
	--index-url https://download.pytorch.org/whl/nightly/cu124

# Prereqs
RUN apt-get update && apt-get install -y \
	curl \
	wget \
	git \
	ffmpeg \
	p7zip-full \
	gcc \
	g++ \
	vim \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Built in modules
COPY modules modules
RUN pip install -r ./modules/tortoise-tts/requirements.txt \
	&& pip install -e ./modules/tortoise-tts/ \
	&& pip install -r ./modules/dlas/requirements.txt \
	&& pip install -e ./modules/dlas/

# RVC
RUN curl -L -o /tmp/rvc.zip https://huggingface.co/Jmica/rvc/resolve/main/rvc_lightweight.zip?download=true \
	&& 7z x /tmp/rvc.zip \
	&& rm -f /tmp/rvc.zip

RUN pip install -r ./rvc/requirements.txt

# Fairseq
# Using patched version for Python 3.11 due to https://github.com/facebookresearch/fairseq/issues/5012
RUN pip install git+https://github.com/liyaodev/fairseq

# RVC Pipeline
RUN pip install git+https://github.com/JarodMica/rvc-tts-pipeline.git@lightweight#egg=rvc_tts_pipe

# Deepspeed
RUN pip install deepspeed

# PyFastMP3Decoder
RUN pip install cython
RUN git clone --depth 1 https://github.com/neonbjb/pyfastmp3decoder.git
RUN cd pyfastmp3decoder \
	&& git submodule update --init --recursive \
	&& python setup.py install

# WhisperX
RUN pip install git+https://github.com/m-bain/whisperx.git

# Main requirements
COPY requirements.txt requirements.txt
RUN pip install -r ./requirements.txt

# The app
COPY . .

ENV IN_DOCKER=true

ENV HOST="::1"
ENV PORT="5000"

CMD ["./start.sh"]

