#FROM wwwzhouhui569/ubuntu22.04-py311-torch2.3.1-1.28.0:latest
FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai

# Install essential utilities and browser dependencies (optimized for size)
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
    # Playwright browser automation dependencies
    xvfb \
    libfontenc1 \
    libunwind8 \
    libxfont2 \
    x11-xkb-utils \
    xauth \
    xfonts-base \
    xfonts-encodings \
    xfonts-utils \
    xserver-common \
    # Additional browser runtime dependencies
    libglib2.0-0 \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libdbus-1-3 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libpango-1.0-0 \
    libcairo2 \
    libasound2 \
    libatspi2.0-0 \
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
    npm install -g @github/copilot --timeout=300000 --registry=https://registry.npmjs.org/ && \
    npm install -g @neovate/code@latest --timeout=300000 --registry=https://registry.npmjs.org/ && \
    bash -c 'source $NVM_DIR/nvm.sh && npm install -g @tencent-ai/codebuddy-code --timeout=300000 --registry=https://registry.npmjs.org/' && \
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

# Copy requirements and install Python packages with optimizations (single installation)
COPY --chown=user requirements.txt $HOME/app/
RUN pip install --no-cache-dir --no-compile --upgrade -r requirements.txt && \
    find /usr/local -name "*.pyc" -delete && \
    find /usr/local -name "__pycache__" -type d -exec rm -rf {} + || true

# Install Playwright browsers (Python version) - AFTER requirements
RUN python -m playwright install chromium chromium-headless-shell firefox webkit

# Install Playwright system dependencies as root (with retry logic and timeout handling)
USER root
RUN for i in 1 2 3 4 5; do \
        echo "Attempt $i: Updating apt cache..." && \
        apt-get update -o Acquire::http::Timeout=30 -o Acquire::Retries=3 && \
        echo "Installing Playwright dependencies..." && \
        python -m playwright install-deps && \
        echo "Playwright dependencies installed successfully!" && \
        break || { \
            echo "❌ Attempt $i failed. Waiting 10 seconds before retry..." >&2; \
            sleep 10; \
            if [ $i -eq 5 ]; then \
                echo "⚠️ All attempts failed. Continuing without Playwright system deps..." >&2; \
                echo "You may need to install deps manually or use a different network." >&2; \
            fi; \
        }; \
    done && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER user

# Install Node.js Playwright and browsers
RUN . /home/user/.nvm/nvm.sh && \
    npm install -g playwright@latest && \
    npx playwright install chromium && \
    npm cache clean --force

# Install uv for Python package management (required for Serena MCP server)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> $HOME/.bashrc

# Install SuperClaude using official method
RUN pip install --no-cache-dir SuperClaude && \
    pip install --no-cache-dir --upgrade SuperClaude && \
    printf "all\nall\ny\ny\n" | python -m superclaude install && \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.bashrc

# Update PATH to include SuperClaude scripts
ENV PATH="/home/user/.local/bin:$PATH"

# Copy the current directory contents into the container
COPY --chown=user . $HOME/app

# Create .claude directory and set proper permissions for SuperClaude
RUN mkdir -p $HOME/.claude && \
    chown -R user:user $HOME/.claude && \
    chmod -R 755 $HOME/.claude

# Create jupyter config directory and set permissions
RUN mkdir -p $HOME/.jupyter && \
    sudo chmod 1777 /tmp

# Scripts no longer needed - using direct Jupyter startup

# Set environment variables for MCP servers (these should be provided at runtime)
ENV MORPH_API_KEY="" \
    TAVILY_API_KEY="" \
    PLAYWRIGHT_HEADLESS=true \
    PLAYWRIGHT_BROWSERS_PATH=/home/user/.cache/ms-playwright \
    DISPLAY=:99 \
    PYTHONUNBUFFERED=1 \
    GRADIO_ALLOW_FLAGGING=never \
    GRADIO_NUM_PORTS=1 \
    GRADIO_SERVER_NAME=0.0.0.0 \
    GRADIO_THEME=huggingface \
    SYSTEM=spaces \
    SHELL=/bin/bash \
    JUPYTER_TOKEN=o3sky2025

# Create .claude directory and set proper permissions for SuperClaude
RUN mkdir -p $HOME/.claude && \
    chown -R user:user $HOME/.claude && \
    chmod -R 755 $HOME/.claude

# Create jupyter config directory and set permissions
RUN mkdir -p $HOME/.jupyter && \
    sudo chmod 1777 /tmp

# Create xvfb startup script for browser automation
USER root
RUN echo '#!/bin/bash' > /usr/local/bin/start-with-xvfb.sh && \
    echo 'echo "Starting Xvfb virtual display server..."' >> /usr/local/bin/start-with-xvfb.sh && \
    echo 'Xvfb :99 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset &' >> /usr/local/bin/start-with-xvfb.sh && \
    echo 'export DISPLAY=:99' >> /usr/local/bin/start-with-xvfb.sh && \
    echo 'echo "Xvfb started on display :99"' >> /usr/local/bin/start-with-xvfb.sh && \
    echo 'sleep 2' >> /usr/local/bin/start-with-xvfb.sh && \
    echo 'exec "$@"' >> /usr/local/bin/start-with-xvfb.sh && \
    chmod +x /usr/local/bin/start-with-xvfb.sh

USER user

# Install MCP tools for Claude
RUN echo "安装 MCP 工具..." && \
    export PATH="$HOME/.cargo/bin:$PATH" && \
    if command -v claude >/dev/null 2>&1; then \
        echo "使用 claude 命令安装 MCP 工具..." && \
        claude mcp add --transport sse sse-server https://mcp.deepwiki.com/sse || echo "deepwiki MCP 安装完成" && \
        claude mcp add fs -- npx -y @modelcontextprotocol/server-filesystem ~/app || echo "filesystem MCP 安装完成" && \
        claude add sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking || echo "sequential-thinking MCP 安装完成" && \
        claude add morph-fast-apply -- npx -y @morph-llm/morph-fast-apply || echo "morph-fast-apply MCP 安装完成"; \
    else \
        echo "claude 命令不可用，跳过 MCP 工具安装"; \
    fi

# Verify SuperClaude installation
RUN python -c "import superclaude; print('SuperClaude 安装成功，版本:', getattr(superclaude, '__version__', '未知'))"

# Start Jupyter Lab with Xvfb for browser automation support
CMD ["/usr/local/bin/start-with-xvfb.sh", "bash", "-c", "python -m jupyterlab \
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
