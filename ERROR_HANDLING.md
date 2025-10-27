# Error Handling Documentation - Zhongzi Phoenix Application

## Overview

This document provides a comprehensive guide to error handling mechanisms implemented in the Zhongzi Phoenix application. The error handling strategy follows Phoenix conventions and leverages Elixir/OTP's fault-tolerance principles to provide robust error management across different layers of the application.

## Error Handling Architecture

### 1. Error Response Controllers

#### JSON Error Controller (`lib/zhongzi_web/controllers/error_json.ex`)

```elixir
defmodule ZhongziWeb.ErrorJSON do
  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
```

**Purpose**: Handles API error responses in JSON format
- **Template Mapping**: Automatically maps HTTP status codes to error messages
- **Response Format**: Standardized JSON error response structure
- **Customization**: Supports custom error messages by adding specific template clauses

**Usage Examples**:
- `404.json` → `%{errors: %{detail: "Not Found"}}`
- `500.json` → `%{errors: %{detail: "Internal Server Error"}}`

#### HTML Error Controller (`lib/zhongzi_web/controllers/error_html.ex`)

```elixir
defmodule ZhongziWeb.ErrorHTML do
  use ZhongziWeb, :html
  
  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
```

**Purpose**: Handles browser error responses in HTML format
- **Plain Text Response**: Returns simple status messages by default
- **Custom Templates**: Can be extended with custom error pages
- **Template Location**: `lib/zhongzi_web/controllers/error_html/`

**Customization Options**:
```elixir
# Uncomment to enable custom error pages
# embed_templates "error_html/*"
# 
# Create files:
# * lib/zhongzi_web/controllers/error_html/404.html.heex
# * lib/zhongzi_web/controllers/error_html/500.html.heex
```

### 2. Endpoint Error Configuration

#### Error Rendering Configuration (`config/config.exs`)

```elixir
config :zhongzi, ZhongziWeb.Endpoint,
  render_errors: [
    formats: [html: ZhongziWeb.ErrorHTML, json: ZhongziWeb.ErrorJSON],
    layout: false
  ]
```

**Configuration Details**:
- **Format Mapping**: Associates content types with error controllers
- **Layout Control**: Disables layout rendering for error pages
- **Content Negotiation**: Automatically selects appropriate error format based on request headers

### 3. Development vs Production Error Handling

#### Development Configuration (`config/dev.exs`)

```elixir
config :zhongzi, ZhongziWeb.Endpoint,
  debug_errors: true,
  code_reloader: true
```

**Development Features**:
- **Debug Errors**: Shows detailed error information and stack traces
- **Code Reloading**: Enables hot code reloading for development
- **Enhanced Stacktraces**: Configured with depth of 20 for detailed debugging

```elixir
config :phoenix, :stacktrace_depth, 20
```

#### Production Configuration (`config/prod.exs`)

```elixir
config :logger, level: :info
```

**Production Features**:
- **Limited Logging**: Only logs info level and above to reduce verbosity
- **No Debug Information**: Hides sensitive error details from end users
- **Performance Optimized**: Minimal error information to improve response times

### 4. Logging and Error Tracking

#### Logger Configuration

**Development Logging** (`config/dev.exs`):
```elixir
config :logger, :console, format: "[$level] $message\n"
```

**Base Logging** (`config/config.exs`):
```elixir
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]
```

**Key Features**:
- **Request ID Tracking**: Each request gets a unique ID for tracing
- **Structured Logging**: Consistent format across all log entries
- **Environment-Specific**: Different verbosity levels per environment

### 5. Telemetry and Error Monitoring

#### Telemetry Metrics (`lib/zhongzi_web/telemetry.ex`)

The application includes built-in error tracking through telemetry:

```elixir
summary("phoenix.router_dispatch.exception.duration",
  tags: [:route],
  unit: {:native, :millisecond}
)
```

**Error Monitoring Capabilities**:
- **Exception Duration**: Tracks time spent handling exceptions
- **Route-Based Metrics**: Associates errors with specific routes
- **Performance Impact**: Measures error handling overhead

### 6. Pipeline Error Handling

#### Router Pipelines (`lib/zhongzi_web/router.ex`)

```elixir
pipeline :browser do
  plug :accepts, ["html"]
  plug :fetch_session
  plug :fetch_live_flash
  plug :put_root_layout, html: {ZhongziWeb.Layouts, :root}
  plug :protect_from_forgery
  plug :put_secure_browser_headers
end

pipeline :api do
  plug :accepts, ["json"]
end
```

**Error Handling in Pipelines**:
- **CSRF Protection**: Automatically handles CSRF token validation errors
- **Content Type Validation**: Rejects requests with unsupported content types
- **Security Headers**: Adds security headers to prevent common attacks

### 7. OTP-Level Error Handling

#### Application Supervision Tree (`lib/zhongzi/application.ex`)

```elixir
opts = [strategy: :one_for_one, name: Zhongzi.Supervisor]
Supervisor.start_link(children, opts)
```

**Fault Tolerance Strategy**:
- **One-for-One**: If a child process crashes, only that process is restarted
- **Process Isolation**: Errors in one component don't affect others
- **Automatic Recovery**: Failed processes are automatically restarted

### 8. Error Handling Best Practices

#### Controller Error Handling

```elixir
defmodule ZhongziWeb.SomeController do
  use ZhongziWeb, :controller

  def action(conn, params) do
    case YourModule.some_operation(params) do
      {:ok, result} ->
        render(conn, "success.html", result: result)
      
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> render("error.html", message: "Resource not found")
      
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.html", changeset: changeset)
    end
  end
end
```

#### LiveView Error Handling

```elixir
defmodule ZhongziWeb.SomeLive do
  use ZhongziWeb, :live_view

  def handle_event("action", params, socket) do
    case YourModule.some_operation(params) do
      {:ok, result} ->
        {:noreply, assign(socket, result: result)}
      
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Operation failed: #{reason}")}
    end
  end
end
```

### 9. Custom Error Handling Patterns

#### Adding Custom Error Pages

1. **Enable Template Embedding**:
```elixir
# In ZhongziWeb.ErrorHTML
embed_templates "error_html/*"
```

2. **Create Error Templates**:
```heex
<!-- lib/zhongzi_web/controllers/error_html/404.html.heex -->
<div class="error-page">
  <h1>Page Not Found</h1>
  <p>The page you're looking for doesn't exist.</p>
  <a href="/">Go Home</a>
</div>
```

3. **Custom Error Functions**:
```elixir
defmodule ZhongziWeb.ErrorHTML do
  def render("404.html", _assigns) do
    render_template("404.html", %{})
  end
  
  def render("500.html", _assigns) do
    render_template("500.html", %{})
  end
end
```

#### API Error Standardization

```elixir
defmodule ZhongziWeb.ErrorJSON do
  def render("400.json", _assigns) do
    %{
      error: %{
        code: "bad_request",
        message: "The request could not be understood",
        timestamp: DateTime.utc_now()
      }
    }
  end
  
  def render("422.json", %{changeset: changeset}) do
    %{
      error: %{
        code: "validation_failed",
        message: "Validation failed",
        details: format_changeset_errors(changeset)
      }
    }
  end
end
```

### 10. Error Handling Configuration

#### Environment-Specific Settings

**Development**:
- Full error details visible
- Debug mode enabled
- Detailed stack traces
- Code reloading on errors

**Production**:
- Minimal error information
- Secure error messages
- Performance optimized
- Comprehensive logging

#### Security Considerations

- **Information Disclosure**: Production errors hide sensitive information
- **CSRF Protection**: Built-in protection against cross-site request forgery
- **Secure Headers**: Automatic security header injection
- **Input Validation**: Request parsing with error handling

### 11. Monitoring and Observability

#### Error Metrics Collection

The application automatically collects error metrics through:

- **Request Tracking**: Each request gets a unique ID
- **Exception Monitoring**: Telemetry tracks exception frequency and duration
- **Performance Metrics**: Error handling performance is monitored
- **Route-Level Analysis**: Errors are associated with specific routes

#### Integration Points

- **External Monitoring**: Ready for APM tool integration
- **Log Aggregation**: Structured logs for centralized analysis
- **Alerting**: Can be extended with custom alert conditions
- **Dashboard Integration**: Metrics can be exported to monitoring dashboards

## Summary

The Zhongzi Phoenix application implements a comprehensive error handling strategy that provides:

- **Layered Error Handling**: From OTP supervision to HTTP responses
- **Environment-Aware**: Different behaviors for development and production
- **Standardized Responses**: Consistent error formats for APIs and web pages
- **Monitoring Ready**: Built-in telemetry and logging for error tracking
- **Extensible**: Easy to customize and extend for specific needs
- **Security-Focused**: Protects against information disclosure and common attacks

This error handling architecture ensures robust operation while providing developers with the tools needed to diagnose and resolve issues effectively.