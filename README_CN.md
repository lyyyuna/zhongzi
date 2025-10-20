# 种子 (Zhongzi)

一个基于 Phoenix LiveView 的 Web 应用程序。

## 快速开始

启动你的 Phoenix 服务器：

* 运行 `mix setup` 安装和设置依赖项
* 使用 `mix phx.server` 启动 Phoenix 端点，或在 IEx 中使用 `iex -S mix phx.server`

现在你可以在浏览器中访问 [`localhost:4000`](http://localhost:4000)。

准备在生产环境中运行？请[查看我们的部署指南](https://hexdocs.pm/phoenix/deployment.html)。

## 项目结构

这是一个使用 Phoenix 1.7+ 和 LiveView 的现代 Elixir Web 应用程序，包含以下主要功能：

* **Phoenix LiveView** - 用于构建丰富的交互式 Web 应用程序
* **Tailwind CSS** - 用于样式设计
* **esbuild** - 用于资源打包
* **Swoosh** - 用于邮件发送

## 开发环境要求

* Elixir 1.14 或更高版本
* Erlang/OTP 24 或更高版本
* Node.js（用于资源编译）

## 常用命令

```bash
# 安装依赖
mix deps.get

# 设置项目（安装并构建资源）
mix setup

# 启动开发服务器
mix phx.server

# 在 IEx 中启动（用于调试）
iex -S mix phx.server

# 运行测试
mix test

# 代码格式化
mix format
```

## 资源管理

本项目使用以下工具进行资源管理：

* **Tailwind CSS** - 实用优先的 CSS 框架
* **esbuild** - 极快的 JavaScript 打包工具

## 了解更多

* Phoenix 官方网站：https://www.phoenixframework.org/
* 指南：https://hexdocs.pm/phoenix/overview.html
* 文档：https://hexdocs.pm/phoenix
* 论坛：https://elixirforum.com/c/phoenix-forum
* 源码：https://github.com/phoenixframework/phoenix

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

请查看项目根目录下的许可证文件。