# 种子 (Zhongzi)

基于 Phoenix LiveView 和 Elixir 构建的现代化 Web 应用程序，为可扩展的 Web 开发提供强大的基础框架。

## 系统设计架构

### 概览
种子系统构建在 Phoenix 框架 (v1.7.10) 之上，充分利用 Elixir 的 Actor 模型和容错能力，创建了一个高并发且具有弹性的 Web 应用程序。

### 核心架构组件

#### 1. 应用层 (`lib/zhongzi/application.ex`)
- **监督树**: 实现 OTP (开放电信平台) 监督策略
- **进程管理**: 管理关键应用程序进程，包括：
  - Phoenix PubSub 用于实时通信
  - Telemetry 用于监控和指标收集
  - DNSCluster 用于服务发现
  - Finch HTTP 客户端用于外部 API 通信
  - Web 端点用于处理 HTTP 请求

#### 2. Web 层 (`lib/zhongzi_web/`)
- **路由器** (`router.ex`): 定义基于管道的 HTTP 路由处理
  - 浏览器管道: 处理 HTML 请求，包含会话管理和 CSRF 保护
  - API 管道: 处理 JSON API 请求
- **控制器**: 处理 HTTP 请求逻辑
- **LiveView 组件**: 提供实时交互式 UI 组件
- **布局和模板**: 管理展示层和可重用的 UI 组件

#### 3. 业务逻辑层 (`lib/zhongzi/`)
- 核心应用程序逻辑和领域模型
- 使用 Swoosh 的邮件模块功能

#### 4. 配置管理 (`config/`)
- **环境特定配置**: 开发、测试、生产环境
- **运行时配置**: 动态配置加载
- **资源编译**: ESBuild 和 Tailwind CSS 配置

#### 5. 前端架构 (`assets/`)
- **JavaScript**: 现代 ES2017+ 配合 Phoenix LiveView 客户端
- **CSS**: Tailwind CSS 实用优先的样式框架
- **构建管道**: ESBuild 进行 JavaScript 打包和优化

### 技术栈

#### 后端
- **Elixir**: 具有 Actor 模型并发的函数式编程语言
- **Phoenix 框架**: 具有实时功能的 Web 框架
- **LiveView**: 服务端渲染的交互式组件
- **OTP**: 容错、分布式系统架构

#### 前端
- **Phoenix LiveView**: 服务端渲染的实时 UI
- **Tailwind CSS**: 实用优先的 CSS 框架
- **ESBuild**: 快速 JavaScript 打包工具
- **Topbar**: 导航反馈的进度条库

#### 基础设施和运维
- **Telemetry**: 应用程序监控和指标收集
- **Swoosh**: 邮件发送抽象层
- **Finch**: 外部服务集成的 HTTP 客户端
- **DNS Cluster**: 服务发现机制

### 核心设计原则

#### 1. 容错性
- 监督树确保进程隔离和自动恢复
- "让它崩溃"的哲学，配合监督者重启策略

#### 2. 并发性
- 轻量级进程 (Actor) 处理并发操作
- 消息传递确保状态管理的安全性

#### 3. 实时通信
- Phoenix PubSub 支持实时功能
- LiveView 提供无需复杂 JavaScript 的交互式 UI

#### 4. 可扩展性
- 通过分布式 Erlang/Elixir 集群实现水平扩展
- 无状态 Web 层配合会话管理

#### 5. 开发者体验
- 开发环境中的热代码重载
- 综合测试框架
- 资源编译和优化管道

### 开发工作流

#### 环境设置
```bash
mix setup                    # 安装和设置依赖项
mix phx.server              # 启动开发服务器
```

#### 资源管理
```bash
mix assets.setup            # 安装前端依赖项
mix assets.build            # 构建开发环境资源
mix assets.deploy           # 构建和优化生产环境资源
```

### 生产环境考虑

#### 性能
- 编译为高效的 BEAM 字节码
- 针对低延迟应用程序优化的垃圾回收
- 资源压缩和优化

#### 监控
- Telemetry 集成用于指标收集
- Phoenix LiveDashboard 用于实时系统监控
- 健康检查端点

#### 部署
- 使用 mix releases 构建发布版本
- 容器就绪架构
- 基于环境的配置

### 安全特性
- 所有状态变更请求的 CSRF 保护
- 安全的浏览器头部设置
- 带签名 cookie 的会话管理
- 内容安全策略就绪

该架构为构建具有出色容错性、可扩展性和开发者生产力的现代化实时 Web 应用程序提供了坚实的基础。

## 快速开始

启动 Phoenix 服务器：

* 运行 `mix setup` 安装和设置依赖项
* 使用 `mix phx.server` 启动 Phoenix 端点，或在 IEx 中使用 `iex -S mix phx.server`

现在您可以在浏览器中访问 [`localhost:4000`](http://localhost:4000)。

准备投入生产环境？请[查看我们的部署指南](https://hexdocs.pm/phoenix/deployment.html)。

## 了解更多

* 官方网站: https://www.phoenixframework.org/
* 指南: https://hexdocs.pm/phoenix/overview.html
* 文档: https://hexdocs.pm/phoenix
* 论坛: https://elixirforum.com/c/phoenix-forum
* 源码: https://github.com/phoenixframework/phoenix