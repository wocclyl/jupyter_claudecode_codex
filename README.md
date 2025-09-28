---
title: AI开发工具集成环境
emoji: 🤖
colorFrom: blue
colorTo: gray
sdk: docker
pinned: false
license: apache-2.0
short_description: 功能完整的AI驱动开发环境，集成多种主流AI代码助手和开发工具
---

# AI开发工具集成环境 🤖

一个功能完整的AI驱动开发环境，集成了多种主流AI代码助手、SuperClaude框架v4.1.5和8个MCP服务器。基于Docker容器化部署，开箱即用。

## 🚀 核心特性

- **多AI引擎支持**: 集成Claude Code、通义千问、OpenAI Codex、Google Gemini、GitHub Copilot、Neovate Code等主流AI代码助手
- **SuperClaude框架**: 完整安装SuperClaude框架v4.1.5，包含:
  - 15个专业AI代理（agents）
  - 7种行为模式（modes）
  - 25个命令定义（commands）
  - 核心框架文档（core）
- **MCP服务器集成**: 预配置8个MCP服务器:
  - sequential-thinking：多步骤问题解决和系统分析
  - context7：官方库文档和代码示例
  - magic：现代UI组件生成和设计系统
  - playwright：跨浏览器E2E测试和自动化
  - serena：语义代码分析和智能编辑（包含uv支持）
  - morphllm-fast-apply：快速应用上下文感知代码修改
  - tavily：网络搜索和实时信息检索
  - chrome-devtools：Chrome开发者工具调试和性能分析
- **完整开发环境**: Python 3.11 + Node.js v22.19.0 + JupyterLab，支持AI辅助编程
- **云服务集成**: 内置腾讯CodeBuddy、CloudFlare、Atlassian CLI等云服务工具
- **开箱即用**: 一键部署，所有工具预配置完成

## 🐳 Docker 使用说明

### 方式一：使用预构建镜像（推荐）

#### 拉取最新镜像
```bash
docker pull wwwzhouhui569/jupyter_claudecode_codex:latest
```

#### 启动容器
```bash
# 基础启动
docker run -d -p 8889:8888 --name jupyter_claudecode_codex wwwzhouhui569/jupyter_claudecode_codex:latest

# 带环境变量启动（推荐）
docker run -d -p 8889:8888 \
  -e MORPH_API_KEY="your_morph_api_key" \
  -e TAVILY_API_KEY="your_tavily_api_key" \
  -v /your/data/path:/data \
  --name jupyter_claudecode_codex \
  wwwzhouhui569/jupyter_claudecode_codex:latest
```

### 方式二：本地构建镜像

#### 构建镜像
```bash
docker build -t jupyter_claudecode_codex .
```

#### 启动容器
```bash
docker run -d -p 8889:8888 --name jupyter_claudecode_codex jupyter_claudecode_codex
```

### 访问服务

- **Jupyter Lab**: http://localhost:8889 (token: o3sky2025)
- **终端访问**: 在JupyterLab中打开Terminal即可使用所有AI工具

### 环境变量配置

为了充分使用MCP服务器功能，建议配置以下环境变量：

```bash
# Morph API（用于morphllm-fast-apply）
export MORPH_API_KEY="your_morph_api_key"

# Tavily API（用于网络搜索）
export TAVILY_API_KEY="your_tavily_api_key"

# Playwright配置
export PLAYWRIGHT_HEADLESS=true
```

## 📦 包含的工具

### AI代码助手
- **Claude Code CLI** (@anthropic-ai/claude-code)
- **Claude Code Router** (@musistudio/claude-code-router)
- **Google Gemini CLI** (@google/gemini-cli)
- **通义千问** (@qwen-code/qwen-code)
- **OpenAI Codex** (@openai/codex)
- **GitHub Copilot CLI** (@github/copilot)
- **Neovate Code** (@neovate/code)
- **腾讯CodeBuddy** (@tencent-ai/codebuddy-code)
- **iFlow AI CLI** (@iflow-ai/iflow-cli)

### SuperClaude框架组件
- **核心框架**: 业务面板示例、符号、标志、原则、研究配置、规则
- **行为模式**: 头脑风暴、业务面板、深度研究、内省、编排、任务管理、令牌效率
- **专业代理**: 15个领域专家AI代理，支持智能路由
- **命令系统**: 25个SuperClaude斜杠命令定义

### MCP服务器
- **sequential-thinking**: 系统性问题解决
- **context7**: 官方文档和示例
- **magic**: UI组件生成
- **playwright**: E2E测试自动化
- **serena**: 智能代码编辑（含uv支持）
- **morphllm-fast-apply**: 快速代码应用
- **tavily**: 网络搜索和信息检索
- **chrome-devtools**: 浏览器调试工具

### 云服务工具
- **CloudFlare CLI** (cloudflared)
- **Atlassian CLI** (acli)
- **Git LFS** 支持

### 开发环境
- **Python 3.11** + pip包管理
- **Node.js v22.19.0** + npm全局包
- **JupyterLab** Web界面
- **uv** Python包管理器（Serena MCP依赖）

## 🎯 使用说明

### 启动后的操作

1. **访问JupyterLab**: 打开 http://localhost:8889，使用token `o3sky2025` 登录
2. **打开Terminal**: 在JupyterLab中新建Terminal
3. **验证安装**: 运行以下命令检查工具安装情况

```bash
# 检查Claude Code
claude-code --version

# 检查SuperClaude
superclaude --version
python -c "import SuperClaude; print('SuperClaude已安装')"

# 检查其他AI工具
gemini --version
qwen --version
github-copilot --version
neovate --version

# 查看SuperClaude配置
ls -la ~/.claude/
```

### SuperClaude使用

```bash
# 查看SuperClaude帮助
superclaude --help

# 查看已安装的组件
superclaude status

# 配置API密钥（如需要）
export MORPH_API_KEY="your_key"
export TAVILY_API_KEY="your_key"
```

## 🔧 故障排除

### 常见问题

1. **MCP服务器无法使用**: 检查是否已设置相应的API密钥
2. **SuperClaude命令不可用**: 确认容器启动完成，重新进入Terminal
3. **权限问题**: 确保使用正确的用户权限运行容器

### 日志查看

```bash
# 查看容器日志
docker logs jupyter_claudecode_codex

# 实时查看日志
docker logs -f jupyter_claudecode_codex
```

## 📝 更新日志

### v0.0.2 (最新)
- ✅ 新增GitHub Copilot CLI支持 (@github/copilot)
- ✅ 新增Neovate Code AI助手 (@neovate/code)
- ✅ 扩展AI代码助手生态系统
- ✅ 优化多AI引擎协作能力

### v0.0.1
- ✅ 集成SuperClaude框架v4.1.5
- ✅ 添加8个MCP服务器支持
- ✅ 新增uv包管理器支持
- ✅ 完整的非交互式安装流程
- ✅ 优化容器构建和启动流程

## 📄 许可证

Apache-2.0 License
