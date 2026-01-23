FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-c"]

RUN apt update && apt upgrade -y && \
    apt install -y curl gnupg2 ca-certificates lsb-release python3 python3-pip python3-venv git pciutils lshw nano lsof postgresql postgresql-contrib

# Setup Node via nvm in a single layer
ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=24
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
 && source "$NVM_DIR/nvm.sh" \
 && nvm install $NODE_VERSION \
 && nvm alias default $NODE_VERSION \
 && nvm use default \
 && npm install -g pm2 \
 && node -v && npm -v && pm2 -v
ENV PATH="$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH"

WORKDIR /workspace

CMD ["bash"]
