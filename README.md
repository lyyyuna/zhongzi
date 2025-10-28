# Zhongzi

**Zhongzi** is a modern web application built with Elixir and the Phoenix Framework, designed with a scalable and maintainable architecture following Elixir/OTP best practices.

## 🏗️ System Architecture

### High-Level Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Web Browser   │◄──►│  Phoenix Web    │◄──►│   Application   │
│    (Client)     │    │    Server       │    │     Logic       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │   Static Assets │
                    │ (CSS/JS/Images) │
                    └─────────────────┘
```

### Core Components

#### 1. **Application Layer** (`lib/zhongzi/`)
- **Zhongzi.Application**: Main OTP application supervisor that coordinates all system components
- **Supervision Tree**: Manages fault-tolerant processes using OTP principles
- **PubSub System**: Real-time communication infrastructure for distributed messaging

#### 2. **Web Layer** (`lib/zhongzi_web/`)
- **Endpoint**: Entry point for all HTTP requests with middleware pipeline
- **Router**: URL routing and request dispatching with pipelines for different content types
- **Controllers**: Request handling and business logic coordination
- **Views & Templates**: Presentation layer with server-side rendering
- **Components**: Reusable UI components using Phoenix's component system

#### 3. **Infrastructure Services**
- **Telemetry**: Application monitoring and metrics collection
- **Mailer**: Email delivery system using Swoosh
- **HTTP Client**: Finch-based HTTP client for external API integration
- **DNS Cluster**: Service discovery for distributed deployments

### Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Runtime** | Elixir 1.14+ | Functional programming with actor model |
| **Web Framework** | Phoenix 1.7 | Modern web framework with real-time features |
| **Frontend** | Phoenix LiveView | Server-side rendered interactive UI |
| **Styling** | TailwindCSS | Utility-first CSS framework |
| **Build Tools** | ESBuild | Fast JavaScript bundling |
| **HTTP Server** | Cowboy | High-performance HTTP server |
| **JSON** | Jason | Fast JSON encoding/decoding |

### Request Processing Pipeline

```
HTTP Request
     │
     ▼
┌─────────────────┐
│   Endpoint      │ ← Middleware (CSRF, Session, etc.)
└─────────────────┘
     │
     ▼
┌─────────────────┐
│   Router        │ ← Route matching & pipeline selection
└─────────────────┘
     │
     ▼
┌─────────────────┐
│   Controller    │ ← Business logic & data processing
└─────────────────┘
     │
     ▼
┌─────────────────┐
│   View/Template │ ← Response rendering
└─────────────────┘
     │
     ▼
HTTP Response
```

### Process Architecture

The application follows the OTP supervision tree pattern:

```
Zhongzi.Supervisor (one_for_one)
├── ZhongziWeb.Telemetry
├── DNSCluster
├── Phoenix.PubSub
├── Finch (HTTP Client)
└── ZhongziWeb.Endpoint
```

**Supervision Strategy**: `one_for_one` - If a child process crashes, only that process is restarted, ensuring system resilience.

### Configuration Management

- **Environment-specific configs**: Development, test, and production configurations
- **Runtime configuration**: Dynamic configuration loading via `config/runtime.exs`
- **Asset pipeline**: Automated CSS/JS building with live reloading in development

### Development Workflow

```bash
# Setup dependencies and assets
mix setup

# Start development server with live reloading
mix phx.server

# Interactive development with IEx
iex -S mix phx.server
```

### Key Features

- **Real-time Updates**: WebSocket-based live updates via Phoenix Channels
- **Developer Experience**: Live code reloading and comprehensive error pages
- **Email Integration**: Built-in mailer with development preview
- **Asset Management**: Optimized CSS/JS bundling and cache busting
- **Security**: CSRF protection, secure headers, and session management
- **Monitoring**: Built-in telemetry and metrics collection

### Scalability Considerations

- **Horizontal Scaling**: Stateless web processes that can be load-balanced
- **Database Ready**: Architecture prepared for database integration
- **Clustering**: DNS-based service discovery for multi-node deployments
- **Caching**: Static asset versioning and browser caching strategies

### Deployment

The application is production-ready with:
- Asset optimization and minification
- Security headers and CSRF protection
- Configurable runtime environment
- Health monitoring via telemetry

For detailed deployment instructions, see the [Phoenix deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## 🚀 Quick Start

```bash
# Install dependencies
mix setup

# Start the development server
mix phx.server
```

Visit [`localhost:4000`](http://localhost:4000) to access the application.

## 📚 Learn More

- **Phoenix Framework**: https://www.phoenixframework.org/
- **Elixir Language**: https://elixir-lang.org/
- **Documentation**: https://hexdocs.pm/phoenix
- **Community**: https://elixirforum.com/c/phoenix-forum