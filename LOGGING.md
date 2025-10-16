# Enhanced Logging System

This document describes the enhanced logging system implemented for the Zhongzi application.

## Overview

The enhanced logging system provides structured, consistent logging with performance monitoring, error tracking, and environment-specific formatting.

## Features

### 1. Structured Logging (`Zhongzi.Logger`)

The main logging module provides consistent, structured logging with metadata:

```elixir
# Basic logging with metadata
Zhongzi.Logger.info("User action", [user_id: 123, action: "login"])

# Performance logging
Zhongzi.Logger.log_performance("database_query", 45.2, [table: "users"])

# Error logging with context
Zhongzi.Logger.log_error(error, [operation: "user_creation"])

# Timing operations
result = Zhongzi.Logger.time_and_log("expensive_operation", fn ->
  # Your code here
end)
```

### 2. Custom Formatter (`Zhongzi.LoggerFormatter`)

- **Development**: Colorized console output with readable formatting
- **Production**: JSON formatted logs for log aggregation systems
- **Test**: Simple console format for clarity

### 3. Request Logging (`ZhongziWeb.Plugs.RequestLogger`)

Automatically logs HTTP requests with:
- Request ID tracking
- Performance metrics
- IP address and User-Agent
- Response status and timing
- Slow request detection (>1s)

### 4. Configuration by Environment

#### Development
- Colorized console output
- Full metadata including IP addresses
- Human-readable format

#### Production
- JSON formatted logs
- Optimized metadata for log aggregation
- Info level and above

#### Test
- Warning level and above
- Simple console format
- Minimal metadata

## Usage Examples

### Basic Logging

```elixir
# In your controllers
Zhongzi.Logger.info("User registration", [
  user_id: user.id,
  email: user.email,
  registration_method: "email"
])

# In your contexts
Zhongzi.Logger.debug("Database query executed", [
  query: "SELECT * FROM users",
  duration_ms: 23.4
])
```

### Performance Monitoring

```elixir
# Time a specific operation
result = Zhongzi.Logger.time_and_log("user_creation", fn ->
  Users.create_user(params)
end, [source: "web"])

# Manual performance logging
Zhongzi.Logger.log_performance("image_resize", duration_ms, [
  width: 800,
  height: 600,
  format: "jpeg"
])
```

### Error Handling

```elixir
try do
  some_risky_operation()
rescue
  error ->
    Zhongzi.Logger.log_error(error, [
      operation: "risky_operation",
      user_id: current_user.id
    ])
    
    # Handle error...
end
```

### Audit Logging

```elixir
# Log user actions for compliance
Zhongzi.Logger.log_user_action(
  user.id,
  "password_change",
  "user_account",
  [ip_address: get_ip(conn)]
)
```

## Log Metadata

The system automatically includes:
- `timestamp`: ISO8601 formatted timestamp
- `node`: Erlang node identifier
- `pid`: Process identifier
- `request_id`: Unique request identifier for tracing

Additional metadata can be added per log entry.

## Request Tracking

Every HTTP request gets a unique `request_id` that's:
- Generated automatically or extracted from `X-Request-ID` header
- Added to Logger metadata for the entire request
- Included in all log messages during request processing

## Performance Monitoring

The system automatically logs:
- Request duration and status
- Slow requests (>1s) as warnings
- Custom performance metrics via `log_performance/3`
- Timed operations via `time_and_log/3`

## JSON Log Format (Production)

Production logs are formatted as JSON for easy parsing:

```json
{
  "@timestamp": "2024-10-16T07:30:00.123Z",
  "level": "info",
  "message": "Request completed",
  "metadata": {
    "request_id": "abc123...",
    "method": "GET",
    "path": "/",
    "status": 200,
    "duration_ms": 45.2,
    "remote_ip": "192.168.1.1"
  },
  "application": "zhongzi"
}
```

## Testing

Run the logging tests with:

```bash
mix test test/zhongzi/logger_test.exs
```

## Configuration

All logging configuration is environment-specific and located in:
- `config/config.exs` - Base configuration
- `config/dev.exs` - Development overrides
- `config/prod.exs` - Production overrides  
- `config/test.exs` - Test overrides

## Best Practices

1. **Use structured metadata**: Always include relevant context
2. **Log at appropriate levels**: Info for business events, Debug for development
3. **Include timing information**: Use `time_and_log` for performance-critical operations
4. **Sanitize sensitive data**: Never log passwords, tokens, or PII
5. **Use consistent keys**: Follow naming conventions for metadata keys
6. **Add request context**: Include `user_id`, `operation`, etc. when relevant

## Migration from Standard Logger

Replace existing Logger calls:

```elixir
# Before
Logger.info("User created: #{user.id}")

# After  
Zhongzi.Logger.info("User created", [user_id: user.id])
```

This provides better structure and searchability in log aggregation systems.