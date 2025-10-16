defmodule ZhongziWeb.Plugs.RequestLogger do
  @moduledoc """
  Plug for logging HTTP requests with enhanced metadata and performance tracking.
  """

  @behaviour Plug
  import Plug.Conn
  require Logger

  def init(opts), do: opts

  def call(conn, _opts) do
    start_time = System.monotonic_time(:microsecond)
    
    # Generate or extract request ID
    request_id = get_request_id(conn)
    
    # Add request ID to Logger metadata
    Logger.metadata(request_id: request_id)
    
    # Log request start
    Zhongzi.Logger.info("Request started", [
      method: conn.method,
      path: conn.request_path,
      query_string: conn.query_string,
      remote_ip: get_remote_ip(conn),
      user_agent: get_user_agent(conn),
      request_id: request_id
    ])

    conn
    |> put_private(:start_time, start_time)
    |> put_private(:request_id, request_id)
    |> register_before_send(&log_response/1)
  end

  defp log_response(conn) do
    start_time = conn.private[:start_time]
    request_id = conn.private[:request_id]
    duration = System.monotonic_time(:microsecond) - start_time
    duration_ms = duration / 1000

    status_type = cond do
      conn.status < 300 -> "success"
      conn.status < 400 -> "redirect"
      conn.status < 500 -> "client_error"
      true -> "server_error"
    end

    Zhongzi.Logger.info("Request completed", [
      method: conn.method,
      path: conn.request_path,
      status: conn.status,
      status_type: status_type,
      duration_ms: Float.round(duration_ms, 2),
      duration_microseconds: duration,
      remote_ip: get_remote_ip(conn),
      request_id: request_id,
      response_size: get_content_length(conn)
    ])

    # Log slow requests as warnings
    if duration_ms > 1000 do
      Zhongzi.Logger.warn("Slow request detected", [
        method: conn.method,
        path: conn.request_path,
        duration_ms: Float.round(duration_ms, 2),
        request_id: request_id
      ])
    end

    conn
  end

  defp get_request_id(conn) do
    case get_req_header(conn, "x-request-id") do
      [request_id | _] -> request_id
      [] -> generate_request_id()
    end
  end

  defp generate_request_id do
    :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
  end

  defp get_remote_ip(conn) do
    case get_req_header(conn, "x-forwarded-for") do
      [forwarded_ip | _] ->
        forwarded_ip |> String.split(",") |> List.first() |> String.trim()
      [] ->
        conn.remote_ip |> :inet.ntoa() |> to_string()
    end
  end

  defp get_user_agent(conn) do
    case get_req_header(conn, "user-agent") do
      [user_agent | _] -> user_agent
      [] -> "unknown"
    end
  end

  defp get_content_length(conn) do
    case get_resp_header(conn, "content-length") do
      [length | _] -> 
        case Integer.parse(length) do
          {size, _} -> size
          :error -> nil
        end
      [] -> nil
    end
  end
end