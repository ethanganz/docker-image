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
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required packages once at build time
RUN apt update && apt upgrade -y && \
    apt install -y python3 python3-pip python3-venv git curl pciutils lshw nano wget openssh-server nodejs npm gnupg2 ca-certificates lsb-release

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Set up SSH authorized keys directory (adjust mounting or key injection separately)
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# Install Node.js 18 from NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Upgrade pip and install Python packages globally (adjust as needed)
RUN pip3 install --upgrade pip && \
    pip3 install jupyterlab jupyterlab_widgets ipykernel ipywidgets

WORKDIR /workspace

RUN usermod -aG video ollama || true

# Copy entrypoint script into the container
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose HTTP ports your app uses
EXPOSE 8000 5173 8003

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

