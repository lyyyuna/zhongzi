# Zhongzi

A modern web application built with Phoenix LiveView and Elixir, providing a robust foundation for scalable web development.

## System Design Architecture

### Overview
Zhongzi is built on the Phoenix Framework (v1.7.10), leveraging Elixir's actor model and fault-tolerance capabilities to create a highly concurrent and resilient web application.

### Core Architecture Components

#### 1. Application Layer (`lib/zhongzi/application.ex`)
- **Supervision Tree**: Implements OTP (Open Telecom Platform) supervision strategy
- **Process Management**: Manages critical application processes including:
  - Phoenix PubSub for real-time communication
  - Telemetry for monitoring and metrics
  - DNSCluster for service discovery
  - Finch HTTP client for external API communication
  - Web endpoint for handling HTTP requests

#### 2. Web Layer (`lib/zhongzi_web/`)
- **Router** (`router.ex`): Defines HTTP routing with pipeline-based request processing
  - Browser pipeline: Handles HTML requests with session management, CSRF protection
  - API pipeline: Handles JSON API requests
- **Controllers**: Handle HTTP request logic
- **LiveView Components**: Provide real-time, interactive UI components
- **Layouts & Templates**: Manage presentation layer with reusable UI components

#### 3. Business Logic Layer (`lib/zhongzi/`)
- Core application logic and domain models
- Mailer module for email functionality using Swoosh

#### 4. Configuration Management (`config/`)
- **Environment-specific configurations**: Development, test, production
- **Runtime configuration**: Dynamic configuration loading
- **Asset compilation**: ESBuild and Tailwind CSS configuration

#### 5. Frontend Architecture (`assets/`)
- **JavaScript**: Modern ES2017+ with Phoenix LiveView client
- **CSS**: Tailwind CSS for utility-first styling
- **Build Pipeline**: ESBuild for JavaScript bundling and optimization

### Technology Stack

#### Backend
- **Elixir**: Functional programming language with actor model concurrency
- **Phoenix Framework**: Web framework with real-time features
- **LiveView**: Server-side rendered interactive components
- **OTP**: Fault-tolerant, distributed system architecture

#### Frontend
- **Phoenix LiveView**: Server-rendered real-time UI
- **Tailwind CSS**: Utility-first CSS framework
- **ESBuild**: Fast JavaScript bundler
- **Topbar**: Progress bar library for navigation feedback

#### Infrastructure & Operations
- **Telemetry**: Application monitoring and metrics collection
- **Swoosh**: Email delivery abstraction
- **Finch**: HTTP client for external service integration
- **DNS Cluster**: Service discovery mechanism

### Key Design Principles

#### 1. Fault Tolerance
- Supervision trees ensure process isolation and automatic recovery
- "Let it crash" philosophy with supervisor restart strategies

#### 2. Concurrency
- Lightweight processes (Actors) handle concurrent operations
- Message passing for safe state management

#### 3. Real-time Communication
- Phoenix PubSub enables real-time features
- LiveView provides interactive UI without JavaScript complexity

#### 4. Scalability
- Horizontal scaling through distributed Erlang/Elixir clusters
- Stateless web layer with session management

#### 5. Developer Experience
- Hot code reloading in development
- Comprehensive testing framework
- Asset compilation and optimization pipeline

### Development Workflow

#### Setup
```bash
mix setup                    # Install and setup dependencies
mix phx.server              # Start development server
```

#### Asset Management
```bash
mix assets.setup            # Install frontend dependencies
mix assets.build            # Build assets for development
mix assets.deploy           # Build and optimize for production
```

### Production Considerations

#### Performance
- Compiled to efficient BEAM bytecode
- Garbage collection optimized for low-latency applications
- Asset minification and compression

#### Monitoring
- Telemetry integration for metrics collection
- Phoenix LiveDashboard for real-time system monitoring
- Health check endpoints

#### Deployment
- Release builds with mix releases
- Container-ready architecture
- Environment-based configuration

### Security Features
- CSRF protection on all state-changing requests
- Secure browser headers
- Session management with signed cookies
- Content Security Policy ready

This architecture provides a solid foundation for building modern, real-time web applications with excellent fault tolerance, scalability, and developer productivity.

## Quick Start

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix