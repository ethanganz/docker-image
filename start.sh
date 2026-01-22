#!/bin/bash
set -e

### -------- PostgreSQL --------
echo "Starting PostgreSQL..."
service postgresql start

sed -i "s/#port = 5432/port = 4600/" /etc/postgresql/*/main/postgresql.conf
service postgresql restart

sudo -u postgres psql <<EOF
ALTER USER postgres PASSWORD 'password';
CREATE DATABASE chatbot_db;
EOF

### -------- Clone Repo --------
cd /app
if [ ! -d chatbot-v0.1 ]; then
  git clone https://gitlab.com/corerok/airlink/ai-chatbot/chatbot-v0.1.git
fi

### -------- Backend --------
echo "Setting up backend..."
cd /app/chatbot-v0.1/backend

python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

cat <<EOT > .env
DATABASE_URL=postgresql://postgres:password@localhost:4600/chatbot_db
EOT

uvicorn main:app --host 0.0.0.0 --port 3000 &

### -------- Frontend (build + serve) --------
echo "Building frontend..."
cd /app/chatbot-v0.1/frontend

npm install
npm run build

cd dist
python3 -m http.server 4000 &

### -------- vLLM --------
echo "Starting vLLM..."
cd /app
python3 -m venv vllm-venv
source vllm-venv/bin/activate

python -m pip install --upgrade pip
python -m pip install torch torchvision torchaudio \
  --index-url https://download.pytorch.org/whl/cu121
python -m pip install torch-c-dlpack-ext
python -m pip install vllm

# Hugging Face token must be provided by RunPod env vars
export HUGGINGFACE_TOKEN=${HUGGINGFACE_TOKEN}

vllm serve meta-llama/Meta-Llama-3-8B-Instruct \
  --dtype float16 \
  --max-model-len 8192 \
  --gpu-memory-utilization 0.8 \
  --port 4500 &

wait
