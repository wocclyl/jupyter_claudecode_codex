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

一个功能完整的AI驱动开发环境，集成了多种主流AI代码助手和开发工具。基于Docker容器化部署，开箱即用。

## 🚀 核心特性

- **多AI引擎支持**: 集成Claude Code、通义千问、OpenAI Codex、Google Gemini等主流AI代码助手
- **SuperClaude框架**: 自动安装配置SuperClaude框架，包含15个专业AI代理、7种行为模式和25个命令定义
- **完整开发环境**: Python 3.11 + Node.js v22.19.0 + JupyterLab，支持AI辅助编程
- **云服务集成**: 内置腾讯CodeBuddy、CloudFlare、Atlassian CLI等云服务工具
- **开箱即用**: 一键部署，所有工具预配置完成

## Docker 使用说明

### 构建镜像

```bash
docker build -t jupyter_claudecode_codex .
```

### 启动容器

```bash
docker run -d -p 8889:8888 --name jupyter_claudecode_codex jupyter_claudecode_codex
```

### 访问服务

- **Jupyter Lab**: http://localhost:8889 (token: o3sky2025)
- **Gradio**: http://localhost:7860
- **Nginx**: http://localhost:80

### 包含的工具

- **AI代码工具**: Claude Code CLI, Claude Code Router, Google Gemini CLI, 通义千问, OpenAI Codex
- **云服务工具**: 腾讯云CLI, CloudFlare CLI, Atlassian CLI
- **开发环境**: JupyterLab, Gradio, Node.js v22.19.0, Python 3.11
- j
