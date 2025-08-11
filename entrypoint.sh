#!/bin/bash
set -e

# Start SSH service
service ssh start

# Optionally, add your SSH public key if provided via env var
if [ -n "$PUBLIC_KEY" ]; then
    echo "$PUBLIC_KEY" >> /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
fi

# Start your backend (adjust command as needed)
uvicorn app.main:app --host 0.0.0.0 --port 8000 &

# Start your frontend (adjust path and command as needed)
cd /workspace/airline-chatbot-prototype/frontend
npm install
npm run dev -- --host 0.0.0.0 --port 5173 &

# Start Jupyter Lab with provided token or empty token
jupyter lab --allow-root --no-browser --port=8888 --ip=0.0.0.0 --ServerApp.token="${JUPYTER_PASSWORD:-}" &

# Wait forever so container doesn't exit
wait
