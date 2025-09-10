FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y && \
    apt install -y curl gnupg2 ca-certificates lsb-release

# install npm and node.js
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
RUN \. "$HOME/.nvm/nvm.sh"
RUN nvm install 24
RUN node -v && npm -v

# Continue with other installs
RUN apt install -y python3 python3-pip python3-venv git pciutils lshw nano lsof pm2

WORKDIR /workspace

SHELL ["/bin/bash", "-c"]

CMD ["bash"]
