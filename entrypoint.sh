#!/bin/bash
set -e

# Start SSH service
service ssh start

# Start your backend (adjust command as needed)
uvicorn app.main:app --host 0.0.0.0 --port 8000 &

# Start your frontend (adjust path and command as needed)
cd /workspace/airline-chatbot-prototype/frontend
npm install
npm run dev -- --host 0.0.0.0 --port 5173 &

# Wait forever so container doesn't exit
wait
