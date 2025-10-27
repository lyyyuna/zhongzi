# Zhongzi - Phoenix Web Application

## System Architecture Overview

Zhongzi is a modern web application built with the Phoenix framework, leveraging the Elixir/OTP ecosystem for building scalable, fault-tolerant web services.

### Technology Stack

- **Framework**: Phoenix 1.7.10 - Modern web framework for Elixir
- **Language**: Elixir 1.14+ - Functional, concurrent programming language
- **Runtime**: Erlang/OTP - Battle-tested actor model runtime
- **Frontend**: Phoenix LiveView 0.20.1 - Server-side rendered reactive UI
- **Styling**: Tailwind CSS 3.3.2 - Utility-first CSS framework
- **JavaScript**: ESBuild 0.8 - Fast JavaScript bundler
- **HTTP Client**: Finch 0.13 - HTTP client for external API calls
- **Email**: Swoosh 1.3 - Email composition and delivery
- **JSON**: Jason 1.2 - High-performance JSON parser

### Application Architecture

#### 1. Application Layer (`lib/zhongzi/application.ex`)

The main application supervisor that orchestrates the entire system using OTP supervision principles:

```
Zhongzi.Supervisor (one_for_one strategy)
├── ZhongziWeb.Telemetry          # Metrics and monitoring
├── DNSCluster                    # Service discovery
├── Phoenix.PubSub                # Real-time messaging
├── Finch                         # HTTP client pool
└── ZhongziWeb.Endpoint           # Web server endpoint
```

**Key Components:**
- **Telemetry**: Provides application metrics and monitoring capabilities
- **PubSub**: Enables real-time communication between processes and LiveView components
- **DNS Cluster**: Handles service discovery for distributed deployments
- **HTTP Client**: Manages connection pools for external API communication
- **Web Endpoint**: Serves HTTP requests and WebSocket connections

#### 2. Web Layer (`lib/zhongzi_web/`)

Following Phoenix conventions with clear separation of concerns:

**Router (`router.ex`)**
- Browser pipeline: Session management, CSRF protection, secure headers
- API pipeline: JSON content negotiation (currently unused but prepared)
- Development routes: Email preview functionality

**Controllers**
- `PageController`: Handles basic page rendering
- `ErrorJSON`: API error response formatting

**Components**
- `CoreComponents`: Reusable UI components
- `Layouts`: Application layout templates

#### 3. Configuration Management

Environment-specific configuration following best practices:

- `config/config.exs`: Base application configuration
- `config/dev.exs`: Development environment settings
- `config/prod.exs`: Production optimizations
- `config/test.exs`: Testing environment configuration
- `config/runtime.exs`: Runtime configuration for deployment

#### 4. Asset Pipeline

Modern frontend toolchain:
- **Tailwind CSS**: Utility-first styling with configuration in `tailwind.config.js`
- **ESBuild**: Fast JavaScript bundling and processing
- **Asset Management**: Automated asset compilation and optimization

### Development Workflow

#### Quick Start
```bash
# Install dependencies and setup
mix setup

# Start development server
mix phx.server

# Or start with interactive shell
iex -S mix phx.server
```

#### Asset Development
```bash
# Setup assets (run once)
mix assets.setup

# Build assets for development
mix assets.build

# Build and minify for production
mix assets.deploy
```

### Deployment Architecture

The application is designed for cloud-native deployment with:

- **OTP Releases**: Self-contained deployment packages
- **DNS Cluster**: Automatic service discovery in container environments
- **Telemetry**: Built-in metrics for monitoring and observability
- **Asset Pipeline**: Optimized static asset delivery

### Security Features

- **CSRF Protection**: Cross-site request forgery prevention
- **Secure Headers**: Security-focused HTTP headers
- **Session Management**: Secure session handling
- **Content Security**: Input validation and output encoding

### Scalability Considerations

- **Actor Model**: Lightweight processes for concurrent request handling
- **PubSub System**: Horizontal scaling of real-time features
- **Supervision Tree**: Fault tolerance through process isolation
- **Connection Pooling**: Efficient resource management for external services

### Monitoring and Observability

- **Telemetry Integration**: Application metrics and custom events
- **Logging**: Structured logging with request tracing
- **Health Checks**: Built-in application health monitoring

## Getting Started

Visit [`localhost:4000`](http://localhost:4000) after starting the server.

## Production Deployment

For production deployment, refer to the [Phoenix deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn More

- **Phoenix Framework**: https://www.phoenixframework.org/
- **Guides**: https://hexdocs.pm/phoenix/overview.html
- **Documentation**: https://hexdocs.pm/phoenix
- **Community**: https://elixirforum.com/c/phoenix-forum
- **Source Code**: https://github.com/phoenixframework/phoenix