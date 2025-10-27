# Zhongzi - System Design Architecture

## Overview

Zhongzi is a modern web application built with Elixir and the Phoenix Framework, leveraging Phoenix LiveView for real-time interactive web experiences. The system follows the Actor Model through OTP (Open Telecom Platform) for fault-tolerant, concurrent, and distributed computing.

## Core Architecture

### Technology Stack

- **Backend Framework**: Phoenix 1.7.10 (Elixir ~> 1.14)
- **Frontend**: Phoenix LiveView 0.20.1 with TailwindCSS
- **Build Tools**: ESBuild for JavaScript, TailwindCSS for styling
- **HTTP Client**: Finch for external API calls
- **Email**: Swoosh for email delivery
- **Telemetry**: Built-in Phoenix telemetry and metrics
- **Testing**: Built-in ExUnit with Floki for HTML parsing

### System Components

#### 1. Application Layer (`lib/zhongzi/application.ex`)

The application follows the OTP supervision tree pattern:

```
Zhongzi.Supervisor (one_for_one strategy)
├── ZhongziWeb.Telemetry          # Metrics and monitoring
├── DNSCluster                    # Service discovery
├── Phoenix.PubSub               # Message broadcasting
├── Finch                        # HTTP client pool
└── ZhongziWeb.Endpoint          # HTTP server endpoint
```

**Supervision Strategy**: `one_for_one` - If a child process crashes, only that process is restarted.

#### 2. Web Layer (`lib/zhongzi_web/`)

##### Router (`router.ex`)
- **Browser Pipeline**: HTML requests with CSRF protection, session management, and security headers
- **API Pipeline**: JSON API support (currently unused but prepared)
- **Development Tools**: Swoosh mailbox preview for email testing

##### Core Components
- **Endpoint**: HTTP request entry point with Cowboy2 adapter
- **Controllers**: Request handling and response generation
- **Views/Templates**: HTML rendering with Phoenix.Component
- **LiveView**: Real-time interactive components
- **Layouts**: Consistent page structure

#### 3. Business Logic Layer (`lib/zhongzi/`)

Currently minimal, containing:
- **Mailer**: Email sending functionality using Swoosh
- **Application**: OTP application definition and supervision

### Configuration Architecture

#### Environment-Specific Configuration
- **`config/config.exs`**: Base configuration
- **`config/dev.exs`**: Development settings
- **`config/test.exs`**: Testing configuration  
- **`config/prod.exs`**: Production settings
- **`config/runtime.exs`**: Runtime configuration

#### Key Configuration Areas
- **Endpoint Configuration**: URL handling, render errors, PubSub
- **Asset Pipeline**: ESBuild and TailwindCSS configuration
- **Mailer Setup**: Email adapter configuration
- **Logger**: Structured logging configuration

### Asset Pipeline

#### JavaScript (`assets/js/`)
- **ESBuild**: Modern JavaScript bundling and transpilation
- **Target**: ES2017 for broad browser compatibility
- **External Resources**: Fonts and images handled separately

#### Styling (`assets/css/`)
- **TailwindCSS**: Utility-first CSS framework
- **Configuration**: Custom Tailwind configuration for branding
- **Build Process**: Integrated with Phoenix asset pipeline

### Development Workflow

#### Setup Commands
```bash
mix setup              # Install dependencies and setup assets
mix phx.server          # Start development server
iex -S mix phx.server   # Start with interactive shell
```

#### Asset Management
```bash
mix assets.setup       # Install asset tools
mix assets.build       # Build assets for development
mix assets.deploy      # Build and optimize for production
```

### Scalability & Performance

#### Concurrency Model
- **Actor Model**: Each request handled by lightweight Elixir processes
- **OTP Supervision**: Fault-tolerant process management
- **Phoenix PubSub**: Distributed message passing for real-time features

#### Performance Features
- **Phoenix LiveView**: Minimal JavaScript, server-rendered real-time UI
- **Asset Optimization**: Minification and digesting for production
- **HTTP/2 Support**: Through Cowboy2 adapter
- **Connection Pooling**: Finch for efficient external API calls

### Deployment Architecture

#### Production Considerations
- **DNS Cluster**: Service discovery for distributed deployments
- **Telemetry**: Built-in metrics collection and monitoring
- **Security**: CSRF protection, secure headers, session management
- **Email Delivery**: Configurable adapter system (Local for dev, external for prod)

### Monitoring & Observability

#### Telemetry System
- **Phoenix Telemetry**: Request metrics, database queries, custom events
- **Telemetry Metrics**: Aggregated metrics collection
- **Telemetry Poller**: Periodic system metrics

#### Logging
- **Structured Logging**: JSON-formatted logs with metadata
- **Request ID Tracking**: Request correlation across services
- **Log Levels**: Configurable per environment

### Security Architecture

#### Web Security
- **CSRF Protection**: Built-in Phoenix CSRF tokens
- **Secure Headers**: XSS protection, content type sniffing prevention
- **Session Security**: Secure session management
- **Input Validation**: Phoenix parameter validation

#### LiveView Security
- **Signing Salt**: Secure WebSocket connections
- **Socket Authentication**: Session-based socket auth
- **CSRF for WebSockets**: Automatic CSRF protection

### Testing Strategy

#### Test Structure
- **Unit Tests**: Individual module testing
- **Integration Tests**: Controller and LiveView testing
- **End-to-End**: Full application flow testing with Floki

#### Test Environment
- **Isolated Database**: Separate test database
- **Mocked External Services**: Controlled testing environment
- **Async Testing**: Concurrent test execution

## Getting Started

### Prerequisites
- Elixir 1.14+
- Erlang/OTP 25+
- Node.js (for asset compilation)

### Installation
1. Clone the repository
2. Run `mix setup` to install dependencies
3. Start the server with `mix phx.server`
4. Visit [`localhost:4000`](http://localhost:4000)

### Development
- **Live Reload**: Automatic browser refresh during development
- **Error Pages**: Detailed error information in development
- **Mailbox Preview**: Email testing at `/dev/mailbox`

## Future Architecture Considerations

### Potential Enhancements
- **Database Integration**: Ecto for data persistence
- **Authentication**: User management system
- **API Expansion**: RESTful or GraphQL APIs
- **Background Jobs**: Oban for async task processing
- **Caching**: Redis for session storage and caching
- **Metrics Dashboard**: LiveDashboard for system monitoring

### Scalability Paths
- **Distributed Deployment**: Multi-node Elixir cluster
- **Database Scaling**: Read replicas and sharding
- **CDN Integration**: Asset delivery optimization
- **Load Balancing**: Multiple Phoenix instances
- **Microservices**: Domain-driven service separation

---

For more information about Phoenix Framework, visit the [official documentation](https://hexdocs.pm/phoenix/overview.html).