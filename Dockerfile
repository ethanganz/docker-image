FROM ubuntu:22.04

# Prevent interactive prompts during install
ENV DEBIAN_FRONTEND=noninteractive

# Update and upgrade system
RUN apt update && apt upgrade -y

# Install base packages
RUN apt install -y python3 python3-pip git curl pciutils lshw nodejs npm nano

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Create a workspace directory
WORKDIR /workspace

# Optional: make ollama user part of video group (GPU access)
RUN usermod -aG video ollama || true

# Set default shell to bash
SHELL ["/bin/bash", "-c"]

# This ensures containers keep running if no command is passed
CMD ["bash"]
