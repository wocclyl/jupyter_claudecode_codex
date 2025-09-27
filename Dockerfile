#FROM wwwzhouhui569/ubuntu22.04-py311-torch2.3.1-1.28.0:latest
FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai

# Install essential utilities only (optimized for size)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    sudo \
    git \
    wget \
    procps \
    git-lfs \
    zip \
    unzip \
    nano \
    bzip2 \
    libsndfile1 \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add cloudflare gpg key
RUN mkdir -p --mode=0755 /usr/share/keyrings && \
    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# Add this repo to your apt repositories
RUN echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | tee /etc/apt/sources.list.d/cloudflared.list

# install cloudflared
RUN apt-get update && apt-get install -y cloudflared && rm -rf /var/lib/apt/lists/*

# Install Atlassian CLI (acli)
RUN apt-get update && apt-get install -y wget gnupg2 && \
    mkdir -p -m 755 /etc/apt/keyrings && \
    wget -nv -O- https://acli.atlassian.com/gpg/public-key.asc | gpg --dearmor -o /etc/apt/keyrings/acli-archive-keyring.gpg && \
    chmod go+r /etc/apt/keyrings/acli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/acli-archive-keyring.gpg] https://acli.atlassian.com/linux/deb stable main" | tee /etc/apt/sources.list.d/acli.list > /dev/null && \
    apt-get update && \
    apt-get install -y acli && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create a working directory
WORKDIR /app

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' --shell /bin/bash user \
 && chown -R user:user /app
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-user

# All users can use /home/user as their home directory
ENV HOME=/home/user
RUN mkdir -p $HOME/.cache $HOME/.config $HOME/.nvm \
 && chown -R user:user $HOME \
 && chmod -R 777 $HOME

USER user

# Install NVM and Node.js (optimized with version control)
ENV NVM_DIR="/home/user/.nvm"
ENV NODE_VERSION="v22.19.0"
ENV PATH="$NVM_DIR/versions/node/$NODE_VERSION/bin:$PATH"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm use $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    npm install -g configurable-http-proxy && \
    npm install -g @anthropic-ai/claude-code && \
    npm install -g @musistudio/claude-code-router && \
    npm install -g @google/gemini-cli --timeout=300000 && \
    npm install -g @qwen-code/qwen-code@latest --timeout=300000 && \
    npm install -g @openai/codex --timeout=300000 --registry=https://registry.npmjs.org/ && \
    npm install -g @iflow-ai/iflow-cli@latest --timeout=300000 --registry=https://registry.npmjs.org/ && \
    bash -c 'source $NVM_DIR/nvm.sh && npm install -g @tencent-ai/codebuddy-code --timeout=300000 --registry=https://registry.npmjs.org/' && \
    bash -c 'source $NVM_DIR/nvm.sh && npm install -g @bifrost_inc/superclaude --timeout=300000 --registry=https://registry.npmjs.org/' && \
    bash -c 'source $NVM_DIR/nvm.sh && export PATH=$NVM_DIR/versions/node/$NODE_VERSION/bin:$PATH && printf "all\nall\ny\ny\n" | superclaude install' && \
    npm cache clean --force && \
    rm -rf /tmp/* /var/tmp/* || true

# Python 3.11 is already available from the base image python:3.11-slim

WORKDIR $HOME/app

#######################################
# Start root user section
#######################################

USER root

# Create data directory
RUN mkdir /data && chown user:user /data

# Remove nginx and supervisor configuration (no longer needed)

#######################################
# End root user section
#######################################

USER user

# Install Python packages using pip only (optimized)
RUN pip install --no-cache-dir --upgrade pip

# Copy requirements and install Python packages with optimizations
COPY --chown=user requirements.txt $HOME/app/
RUN pip install --no-cache-dir --no-compile --upgrade -r requirements.txt && \
    find /usr/local -name "*.pyc" -delete && \
    find /usr/local -name "__pycache__" -type d -exec rm -rf {} + || true

# Copy the current directory contents into the container
COPY --chown=user . $HOME/app

# Scripts no longer needed - using direct Jupyter startup

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    GRADIO_ALLOW_FLAGGING=never \
    GRADIO_NUM_PORTS=1 \
    GRADIO_SERVER_NAME=0.0.0.0 \
    GRADIO_THEME=huggingface \
    SYSTEM=spaces \
    SHELL=/bin/bash \
    JUPYTER_TOKEN=o3sky2025

# Create jupyter config directory and set permissions
RUN mkdir -p $HOME/.jupyter && \
    sudo chmod 1777 /tmp

# Directly start Jupyter Lab without supervisord overhead  
CMD ["bash", "-c", "python -m jupyterlab \
     --ip 0.0.0.0 \
     --port 8888 \
     --no-browser \
     --allow-root \
     --ServerApp.token=\"$JUPYTER_TOKEN\" \
     --ServerApp.password='' \
     --ServerApp.disable_check_xsrf=True \
     --ServerApp.allow_origin='*' \
     --ServerApp.allow_credentials=True \
     --ServerApp.terminals_enabled=True \
     --LabApp.news_url=None \
     --LabApp.check_for_updates_class='jupyterlab.NeverCheckForUpdate' \
     --notebook-dir=/data"]
