defmodule Zhongzi.LoggerFormatter do
  @moduledoc """
  Custom logger formatter that outputs structured JSON logs for production
  and human-readable logs for development.
  """

  def format(level, message, timestamp, metadata) do
    case Application.get_env(:zhongzi, :log_format, :console) do
      :json -> format_json(level, message, timestamp, metadata)
      :console -> format_console(level, message, timestamp, metadata)
    end
  end

  defp format_json(level, message, timestamp, metadata) do
    log_entry = %{
      "@timestamp" => format_timestamp(timestamp),
      level: level,
      message: IO.chardata_to_string(message),
      metadata: sanitize_metadata(metadata),
      application: "zhongzi"
    }

    Jason.encode!(log_entry) <> "\n"
  rescue
    _ -> 
      # Fallback to simple format if JSON encoding fails
      format_console(level, message, timestamp, metadata)
  end

  defp format_console(level, message, timestamp, metadata) do
    timestamp_str = format_timestamp(timestamp)
    level_str = format_level(level)
    
    metadata_str = 
      case format_metadata(metadata) do
        "" -> ""
        meta -> " #{meta}"
      end

    "#{timestamp_str} #{level_str} #{message}#{metadata_str}\n"
  end

  defp format_timestamp(timestamp) do
    {{year, month, day}, {hour, minute, second, microsecond}} = timestamp
    microsecond_str = microsecond |> div(1000) |> Integer.to_string() |> String.pad_leading(3, "0")
    
    "#{year}-#{pad(month)}-#{pad(day)} #{pad(hour)}:#{pad(minute)}:#{pad(second)}.#{microsecond_str}"
  end

  defp format_level(level) do
    level
    |> Atom.to_string()
    |> String.upcase()
    |> String.pad_leading(5)
    |> case do
      "ERROR" -> "\e[31m#{level}\e[0m"  # Red
      " WARN" -> "\e[33m#{level}\e[0m"   # Yellow  
      " INFO" -> "\e[32m#{level}\e[0m"   # Green
      "DEBUG" -> "\e[36m#{level}\e[0m"   # Cyan
      other -> other
    end
  end

  defp format_metadata(metadata) do
    metadata
    |> Enum.reject(fn {key, _} -> key in [:time, :gl, :report_cb, :mfa, :file, :line] end)
    |> Enum.map(fn {key, value} -> "#{key}=#{inspect(value)}" end)
    |> Enum.join(" ")
  end

  defp sanitize_metadata(metadata) do
    metadata
    |> Enum.into(%{})
    |> Map.drop([:time, :gl, :report_cb, :mfa, :file, :line])
    |> sanitize_values()
  end

  defp sanitize_values(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {k, sanitize_value(v)} end)
  end

  defp sanitize_value(value) when is_binary(value) do
    if String.valid?(value) do
      value
    else
      Base.encode64(value)
    end
  end

  defp sanitize_value(value) when is_pid(value), do: inspect(value)
  defp sanitize_value(value) when is_reference(value), do: inspect(value)
  defp sanitize_value(value) when is_function(value), do: inspect(value)
  defp sanitize_value(value), do: value

  defp pad(number) when number < 10, do: "0#{number}"
  defp pad(number), do: "#{number}"
end