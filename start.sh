#!/bin/bash
set -e

echo "=== START.SH EXECUTING ==="

### -------- SSH SETUP --------
mkdir -p /workspace
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Add your public key from environment variable
if [[ -n "$PUBLIC_KEY" ]]; then
    echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
fi

# Start SSH service
service ssh start
echo "SSH started"

### -------- PYTHON PIP BOOTSTRAP --------
if ! command -v pip3 &> /dev/null; then
    wget https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py
    python3 /tmp/get-pip.py
    rm /tmp/get-pip.py
fi

### -------- POSTGRES --------
echo "Starting PostgreSQL..."
service postgresql start
sed -i "s/#port = 5432/port = 4600/" /etc/postgresql/*/main/postgresql.conf
service postgresql restart
sudo -u postgres psql <<EOF
ALTER USER postgres PASSWORD 'password';
CREATE DATABASE chatbot_db;
EOF

### -------- BACKEND --------
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

### -------- FRONTEND --------
echo "Building frontend..."
cd /app/chatbot-v0.1/frontend
npm install
npm run build

cd dist
python3 -m http.server 4000 &

### -------- VLLM --------
echo "Starting vLLM..."
cd /app
python3 -m venv vllm-venv
source vllm-venv/bin/activate

python -m pip install --upgrade pip
python -m pip install torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/cu121
python -m pip install torch-c-dlpack-ext
python -m pip install vllm

# Hugging Face token must be provided via env
export HUGGINGFACE_TOKEN=${HUGGINGFACE_TOKEN}

vllm serve meta-llama/Meta-Llama-3-8B-Instruct \
    --dtype float16 \
    --max-model-len 8192 \
    --gpu-memory-utilization 0.8 \
    --port 4500 &

# Keep container alive
echo "Container setup complete. Running all services..."
sleep infinity
