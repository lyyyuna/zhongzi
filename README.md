# Zhongzi

**Zhongzi** is a modern web application built with Elixir and the Phoenix Framework. It demonstrates best practices for building scalable, real-time web applications using functional programming principles and the Actor model.

## Overview

Zhongzi serves as a foundation for web applications that require:
- **Real-time communication** via WebSockets and Phoenix Channels
- **High performance** and fault tolerance through Elixir's OTP
- **Modern web development** with server-side rendering and interactive UI
- **Scalable architecture** designed for distributed systems

## Key Features

- ⚡ **High Performance**: Built on the BEAM virtual machine for excellent concurrency
- 🔄 **Real-time Updates**: WebSocket support for live, interactive experiences
- 🛡️ **Fault Tolerant**: OTP supervision trees ensure system resilience
- 🎨 **Modern UI**: TailwindCSS for responsive, utility-first styling
- 📧 **Email Integration**: Built-in mailer for user communications
- 🔒 **Security**: CSRF protection, secure headers, and session management
- 📊 **Monitoring**: Telemetry and metrics for production insights

## Technology Stack

- **Runtime**: Elixir 1.14+ on Erlang/OTP
- **Web Framework**: Phoenix 1.7 with LiveView
- **Frontend**: Phoenix LiveView with TailwindCSS
- **HTTP Server**: Cowboy for high-performance request handling
- **Build Tools**: ESBuild for JavaScript bundling

## Quick Start

### Prerequisites
- Elixir 1.14 or later
- Node.js for asset compilation

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/lyyyuna/zhongzi.git
   cd zhongzi
   ```

2. **Install dependencies and setup the project**
   ```bash
   mix setup
   ```

3. **Start the development server**
   ```bash
   mix phx.server
   ```

4. **Access the application**
   
   Visit [`http://localhost:4000`](http://localhost:4000) in your browser

### Alternative Development Mode

For interactive development with IEx:
```bash
iex -S mix phx.server
```

## Development

### Asset Compilation
- **CSS**: Automatically compiled with TailwindCSS
- **JavaScript**: Bundled with ESBuild
- **Live Reload**: Automatic browser refresh during development

### Email Testing
Visit [`http://localhost:4000/dev/mailbox`](http://localhost:4000/dev/mailbox) to preview emails in development.

## Production Deployment

Zhongzi is production-ready with:
- Asset optimization and minification
- Security headers and CSRF protection
- Configurable runtime environment
- Health monitoring and telemetry

For detailed deployment instructions, see the [Phoenix deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Project Structure

```
zhongzi/
├── lib/
│   ├── zhongzi/          # Core application logic
│   └── zhongzi_web/      # Web interface (controllers, views, templates)
├── assets/               # Frontend assets (CSS, JS)
├── config/               # Environment configuration
├── priv/                 # Static files and database migrations
└── test/                 # Test suite
```

## Architecture

Zhongzi follows Phoenix and Elixir best practices:
- **Supervision Trees**: Fault-tolerant process management
- **PubSub System**: Real-time message broadcasting
- **Modular Design**: Clear separation between business logic and web layer
- **Configuration Management**: Environment-specific settings

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Resources

- **Phoenix Framework**: https://www.phoenixframework.org/
- **Elixir Language**: https://elixir-lang.org/
- **Documentation**: https://hexdocs.pm/phoenix
- **Community Forum**: https://elixirforum.com/c/phoenix-forum

## License

This project is open source and available under the [MIT License](LICENSE).