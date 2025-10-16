defmodule Zhongzi.Logger do
  @moduledoc """
  Enhanced logging utilities for the Zhongzi application.
  
  This module provides structured logging capabilities with consistent formatting,
  performance monitoring, and enhanced error tracking.
  """

  require Logger

  @doc """
  Logs an info message with structured metadata.
  """
  def info(message, metadata \\ []) do
    Logger.info(message, build_metadata(metadata))
  end

  @doc """
  Logs a warning message with structured metadata.
  """
  def warn(message, metadata \\ []) do
    Logger.warning(message, build_metadata(metadata))
  end

  @doc """
  Logs an error message with structured metadata.
  """
  def error(message, metadata \\ []) do
    Logger.error(message, build_metadata(metadata))
  end

  @doc """
  Logs a debug message with structured metadata.
  """
  def debug(message, metadata \\ []) do
    Logger.debug(message, build_metadata(metadata))
  end

  @doc """
  Logs HTTP request information.
  """
  def log_request(conn, start_time \\ nil) do
    metadata = [
      method: conn.method,
      path: conn.request_path,
      query_string: conn.query_string,
      remote_ip: get_remote_ip(conn),
      user_agent: get_user_agent(conn),
      status: conn.status
    ]

    metadata = 
      if start_time do
        duration = System.monotonic_time(:microsecond) - start_time
        Keyword.put(metadata, :duration_microseconds, duration)
      else
        metadata
      end

    info("HTTP Request", metadata)
  end

  @doc """
  Logs performance metrics for a given operation.
  """
  def log_performance(operation, duration_ms, metadata \\ []) do
    base_metadata = [
      operation: operation,
      duration_ms: duration_ms,
      performance: true
    ]

    info("Performance metric", Keyword.merge(base_metadata, metadata))
  end

  @doc """
  Logs database query performance.
  """
  def log_query(query, duration_ms, metadata \\ []) do
    base_metadata = [
      query_type: "database",
      duration_ms: duration_ms,
      query: String.slice(query, 0, 200) <> if(String.length(query) > 200, do: "...", else: "")
    ]

    info("Database query", Keyword.merge(base_metadata, metadata))
  end

  @doc """
  Logs application errors with enhanced context.
  """
  def log_error(error, context \\ [], stacktrace \\ nil) do
    metadata = [
      error_type: error.__struct__,
      error_message: Exception.message(error),
      context: context
    ]

    metadata = 
      if stacktrace do
        Keyword.put(metadata, :stacktrace, format_stacktrace(stacktrace))
      else
        metadata
      end

    error("Application error", metadata)
  end

  @doc """
  Times a function execution and logs the performance.
  """
  def time_and_log(operation_name, fun, metadata \\ []) when is_function(fun, 0) do
    start_time = System.monotonic_time(:millisecond)
    
    try do
      result = fun.()
      duration = System.monotonic_time(:millisecond) - start_time
      log_performance(operation_name, duration, metadata)
      result
    rescue
      error ->
        duration = System.monotonic_time(:millisecond) - start_time
        log_performance(operation_name, duration, Keyword.put(metadata, :error, true))
        log_error(error, [operation: operation_name])
        reraise error, __STACKTRACE__
    end
  end

  @doc """
  Logs user actions for audit purposes.
  """
  def log_user_action(user_id, action, resource \\ nil, metadata \\ []) do
    base_metadata = [
      user_id: user_id,
      action: action,
      audit: true
    ]

    base_metadata = 
      if resource do
        Keyword.put(base_metadata, :resource, resource)
      else
        base_metadata
      end

    info("User action", Keyword.merge(base_metadata, metadata))
  end

  # Private functions

  defp build_metadata(metadata) do
    base_metadata = [
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      node: Node.self(),
      pid: inspect(self())
    ]

    Keyword.merge(base_metadata, metadata)
  end

  defp get_remote_ip(conn) do
    case Plug.Conn.get_req_header(conn, "x-forwarded-for") do
      [forwarded_ip | _] ->
        forwarded_ip |> String.split(",") |> List.first() |> String.trim()
      [] ->
        conn.remote_ip |> :inet.ntoa() |> to_string()
    end
  end

  defp get_user_agent(conn) do
    case Plug.Conn.get_req_header(conn, "user-agent") do
      [user_agent | _] -> user_agent
      [] -> "unknown"
    end
  end

  defp format_stacktrace(stacktrace) when is_list(stacktrace) do
    stacktrace
    |> Enum.take(10)  # Limit to first 10 frames
    |> Enum.map(&Exception.format_stacktrace_entry/1)
    |> Enum.join("\n")
  end

  defp format_stacktrace(_), do: "unavailable"
end