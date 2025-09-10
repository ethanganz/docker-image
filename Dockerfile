FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Use bash for all subsequent RUN instructions
SHELL ["/bin/bash", "-lc"]

# Base packages
RUN apt update && apt upgrade -y && \
    apt install -y curl gnupg2 ca-certificates lsb-release python3 python3-pip python3-venv git pciutils lshw nano lsof pm2 && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Install Node.js 24 via nvm in a single layer so nvm is available during that layer
ENV NVM_DIR=/root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash && \
    source "$NVM_DIR/nvm.sh" && nvm install 24 && nvm alias default 24 && \
    # Expose node/npm globally via symlinks so future layers don't need nvm sourcing
    ln -s "$NVM_DIR/versions/node/$(ls $NVM_DIR/versions/node)/bin/node" /usr/local/bin/node && \
    ln -s "$NVM_DIR/versions/node/$(ls $NVM_DIR/versions/node)/bin/npm" /usr/local/bin/npm && \
    ln -s "$NVM_DIR/versions/node/$(ls $NVM_DIR/versions/node)/bin/npx" /usr/local/bin/npx && \
    node -v && npm -v

WORKDIR /workspace

CMD ["bash"]
