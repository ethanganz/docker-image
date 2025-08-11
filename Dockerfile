FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y && \
    apt install -y curl gnupg2 ca-certificates lsb-release

# Add NodeSource repository and install Node.js 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Continue with your other installs
RUN apt install -y python3 python3-pip python3-venv git pciutils lshw nano

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

WORKDIR /workspace

RUN usermod -aG video ollama || true

SHELL ["/bin/bash", "-c"]

CMD ["bash"]
