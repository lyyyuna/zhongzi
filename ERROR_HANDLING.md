# Zhongzi - Error Handling Guide

## Overview

This document provides a comprehensive guide to error handling patterns in the Zhongzi Phoenix application. It covers error handling strategies across different layers of the application, from HTTP errors to OTP process failures.

## Error Handling Architecture

### 1. HTTP Error Handling

#### Error Views (`lib/zhongzi_web/controllers/`)

The application implements dual error handling for different content types:

##### HTML Error Handling (`error_html.ex`)
```elixir
defmodule ZhongziWeb.ErrorHTML do
  use ZhongziWeb, :html

  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
```

**Key Features:**
- **Default Rendering**: Returns plain text status messages (e.g., "Not Found", "Internal Server Error")
- **Customizable Templates**: Can be extended with custom error pages in `error_html/` directory
- **Status Code Mapping**: Automatically maps HTTP status codes to user-friendly messages

**Customization Pattern:**
```elixir
# To add custom error pages, uncomment and create:
# lib/zhongzi_web/controllers/error_html/404.html.heex
# lib/zhongzi_web/controllers/error_html/500.html.heex

embed_templates "error_html/*"
```

##### JSON Error Handling (`error_json.ex`)
```elixir
defmodule ZhongziWeb.ErrorJSON do
  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
```

**Response Format:**
```json
{
  "errors": {
    "detail": "Not Found"
  }
}
```

**Custom Error Response Pattern:**
```elixir
def render("500.json", _assigns) do
  %{errors: %{detail: "Internal Server Error"}}
end

def render("422.json", %{changeset: changeset}) do
  %{errors: translate_errors(changeset)}
end
```

### 2. Request Pipeline Error Handling

#### Router Error Configuration (`config/config.exs`)

```elixir
config :zhongzi, ZhongziWeb.Endpoint,
  render_errors: [
    formats: [html: ZhongziWeb.ErrorHTML, json: ZhongziWeb.ErrorJSON],
    layout: false
  ]
```

**Error Handling Flow:**
1. **Exception Occurs**: Unhandled exception in controller or plug
2. **Phoenix Catches**: Phoenix framework intercepts the error
3. **Format Detection**: Determines response format (HTML/JSON) from Accept header
4. **Error View**: Renders appropriate error view
5. **Response**: Returns formatted error response to client

#### Plug-Level Error Handling

**Built-in Error Protection:**
- **Request ID**: `Plug.RequestId` for request tracing
- **CSRF Protection**: Automatic CSRF error handling in forms
- **Session Errors**: Secure session handling with error recovery
- **Parser Errors**: JSON/form parsing error handling

### 3. LiveView Error Handling

#### WebSocket Connection Errors

```elixir
# In endpoint.ex
socket "/live", Phoenix.LiveView.Socket, 
  websocket: [connect_info: [session: @session_options]]
```

**Error Scenarios:**
- **Connection Failures**: Network disconnections, timeouts
- **Authentication Errors**: Invalid session or CSRF tokens
- **Process Crashes**: LiveView process failures with automatic restart

**LiveView Error Recovery:**
```elixir
def handle_info({:DOWN, _ref, :process, _pid, _reason}, socket) do
  # Custom cleanup on process crash
  {:noreply, socket}
end

def handle_event("error", %{"type" => type}, socket) do
  # Handle client-side errors
  {:noreply, put_flash(socket, :error, "An error occurred: #{type}")}
end
```

### 4. OTP Error Handling & Supervision

#### Application Supervision Tree (`lib/zhongzi/application.ex`)

```elixir
children = [
  ZhongziWeb.Telemetry,          # Metrics collection
  {DNSCluster, query: Application.get_env(:zhongzi, :dns_cluster_query) || :ignore},
  {Phoenix.PubSub, name: Zhongzi.PubSub},
  {Finch, name: Zhongzi.Finch},  # HTTP client pool
  ZhongziWeb.Endpoint           # Web server
]

opts = [strategy: :one_for_one, name: Zhongzi.Supervisor]
```

**Supervision Strategy: `:one_for_one`**
- **Individual Recovery**: If one child crashes, only that child is restarted
- **Isolation**: Failures are contained to individual processes
- **Availability**: Other services continue running during failures

#### Error Recovery Patterns

**1. Process Restart**
```elixir
# Automatic restart on crash
def start_link(args) do
  GenServer.start_link(__MODULE__, args, name: __MODULE__)
end

# Graceful error handling in GenServer
def handle_call({:risky_operation, data}, _from, state) do
  try do
    result = perform_operation(data)
    {:reply, {:ok, result}, state}
  rescue
    error -> 
      Logger.error("Operation failed: #{inspect(error)}")
      {:reply, {:error, :operation_failed}, state}
  end
end
```

**2. Circuit Breaker Pattern**
```elixir
def handle_external_api_call do
  case Circuit.call(:external_api) do
    {:ok, result} -> result
    {:error, :circuit_open} -> {:error, :service_unavailable}
  end
end
```

### 5. Telemetry & Error Monitoring

#### Telemetry Events (`lib/zhongzi_web/telemetry.ex`)

**Error-Related Metrics:**
```elixir
# Router dispatch errors
summary("phoenix.router_dispatch.exception.duration",
  tags: [:route],
  unit: {:native, :millisecond}
)

# Endpoint errors  
summary("phoenix.endpoint.stop.duration",
  unit: {:native, :millisecond}
)
```

**Custom Error Telemetry:**
```elixir
:telemetry.execute(
  [:zhongzi, :error, :occurred],
  %{count: 1},
  %{type: :database_error, severity: :critical}
)
```

### 6. Logging & Error Tracking

#### Logger Configuration

**Development:**
```elixir
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]
```

**Production:**
```elixir
config :logger, level: :info
```

#### Structured Error Logging

```elixir
require Logger

def handle_error(error, context) do
  Logger.error("Database operation failed", 
    error: inspect(error),
    operation: context.operation,
    user_id: context.user_id,
    request_id: context.request_id
  )
end
```

### 7. Testing Error Scenarios

#### Error View Tests (`test/zhongzi_web/controllers/`)

**HTML Error Tests:**
```elixir
test "renders 404.html" do
  assert render_to_string(ZhongziWeb.ErrorHTML, "404", "html", []) == "Not Found"
end

test "renders 500.html" do
  assert render_to_string(ZhongziWeb.ErrorHTML, "500", "html", []) == "Internal Server Error"
end
```

**JSON Error Tests:**
```elixir
test "renders 404" do
  assert ZhongziWeb.ErrorJSON.render("404.json", %{}) == 
    %{errors: %{detail: "Not Found"}}
end

test "renders 500" do
  assert ZhongziWeb.ErrorJSON.render("500.json", %{}) ==
    %{errors: %{detail: "Internal Server Error"}}
end
```

#### Integration Error Testing

```elixir
test "handles invalid data gracefully", %{conn: conn} do
  conn = post(conn, "/api/users", %{invalid: "data"})
  assert json_response(conn, 422) == %{
    "errors" => %{"detail" => "Unprocessable Entity"}
  }
end

test "returns 404 for non-existent resources", %{conn: conn} do
  conn = get(conn, "/users/999999")
  assert html_response(conn, 404) =~ "Not Found"
end
```

### 8. Error Handling Best Practices

#### Controller Error Handling

```elixir
def show(conn, %{"id" => id}) do
  case Users.get_user(id) do
    nil -> 
      conn
      |> put_status(:not_found)
      |> put_view(ZhongziWeb.ErrorHTML)
      |> render("404.html")
    
    user -> 
      render(conn, :show, user: user)
  end
end

def create(conn, %{"user" => user_params}) do
  case Users.create_user(user_params) do
    {:ok, user} ->
      conn
      |> put_status(:created)
      |> render(:show, user: user)
      
    {:error, %Ecto.Changeset{} = changeset} ->
      conn
      |> put_status(:unprocessable_entity)
      |> put_view(ZhongziWeb.ErrorJSON)
      |> render("422.json", changeset: changeset)
  end
end
```

#### LiveView Error Handling

```elixir
def handle_event("save", %{"user" => params}, socket) do
  case Users.update_user(socket.assigns.user, params) do
    {:ok, user} ->
      {:noreply, 
       socket
       |> put_flash(:info, "User updated successfully")
       |> assign(:user, user)}
       
    {:error, %Ecto.Changeset{} = changeset} ->
      {:noreply, assign(socket, :changeset, changeset)}
  end
end

def handle_info({:user_updated, user}, socket) do
  if socket.assigns.user.id == user.id do
    {:noreply, assign(socket, :user, user)}
  else
    {:noreply, socket}
  end
rescue
  error ->
    Logger.error("Failed to handle user update: #{inspect(error)}")
    {:noreply, put_flash(socket, :error, "Failed to update user")}
end
```

#### External Service Error Handling

```elixir
def call_external_api(data) do
  case Finch.build(:post, @api_url, @headers, Jason.encode!(data))
       |> Finch.request(Zhongzi.Finch) do
    {:ok, %{status: 200, body: body}} ->
      {:ok, Jason.decode!(body)}
      
    {:ok, %{status: status}} when status >= 400 ->
      {:error, {:http_error, status}}
      
    {:error, %Mint.TransportError{}} ->
      {:error, :network_error}
      
    {:error, reason} ->
      {:error, {:request_failed, reason}}
  end
rescue
  Jason.DecodeError -> {:error, :invalid_json}
  error -> {:error, {:unexpected_error, error}}
end
```

### 9. Production Error Handling

#### Error Aggregation & Alerting

```elixir
# Custom error reporter
defmodule ZhongziWeb.ErrorReporter do
  def report_error(kind, reason, stack, metadata \\ %{}) do
    error_data = %{
      kind: kind,
      reason: inspect(reason),
      stack: Exception.format_stacktrace(stack),
      metadata: metadata,
      timestamp: DateTime.utc_now()
    }
    
    # Send to error tracking service
    case Application.get_env(:zhongzi, :error_service) do
      nil -> Logger.error("Error occurred", error: error_data)
      service -> service.report(error_data)
    end
  end
end
```

#### Graceful Degradation

```elixir
def get_user_profile(user_id) do
  with {:ok, user} <- Users.get_user(user_id),
       {:ok, profile} <- Profiles.get_profile(user.id),
       {:ok, preferences} <- fetch_user_preferences(user.id) do
    {:ok, build_full_profile(user, profile, preferences)}
  else
    {:error, :user_not_found} -> {:error, :not_found}
    {:error, :profile_service_down} -> 
      # Graceful degradation - return basic user info
      case Users.get_user(user_id) do
        {:ok, user} -> {:ok, build_basic_profile(user)}
        error -> error
      end
    error -> error
  end
end
```

### 10. Error Prevention Strategies

#### Input Validation

```elixir
def validate_user_input(params) do
  %{email: email, age: age} = params
  
  with :ok <- validate_email(email),
       :ok <- validate_age(age) do
    :ok
  else
    {:error, field, message} -> {:error, "#{field}: #{message}"}
  end
end

defp validate_email(email) when is_binary(email) do
  if String.contains?(email, "@") do
    :ok
  else
    {:error, :email, "must contain @"}
  end
end

defp validate_email(_), do: {:error, :email, "must be a string"}
```

#### Defensive Programming

```elixir
def safe_divide(a, b) when is_number(a) and is_number(b) and b != 0 do
  {:ok, a / b}
end

def safe_divide(_, 0), do: {:error, :division_by_zero}
def safe_divide(_, _), do: {:error, :invalid_arguments}

def process_list(list) when is_list(list) do
  list
  |> Enum.filter(&is_valid_item/1)
  |> Enum.map(&process_item/1)
  |> Enum.reject(&is_nil/1)
end

def process_list(_), do: {:error, :invalid_list}
```

---

## Summary

The Zhongzi application implements comprehensive error handling across all architectural layers:

- **HTTP Layer**: Dual format error responses (HTML/JSON) with customizable templates
- **LiveView Layer**: WebSocket error recovery and graceful degradation
- **OTP Layer**: Supervision trees with isolated failure recovery
- **Telemetry Layer**: Error monitoring and metrics collection
- **Testing Layer**: Comprehensive error scenario coverage

This multi-layered approach ensures robust error handling, system reliability, and excellent user experience even when failures occur.

For implementation details and examples, refer to the specific sections above or examine the source code in the respective modules.