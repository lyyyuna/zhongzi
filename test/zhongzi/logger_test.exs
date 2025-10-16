defmodule Zhongzi.LoggerTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog

  alias Zhongzi.Logger

  describe "structured logging" do
    test "info logs with metadata" do
      log = capture_log(fn ->
        Logger.info("Test message", [key: "value", number: 42])
      end)

      assert log =~ "Test message"
      assert log =~ "key=\"value\""
      assert log =~ "number=42"
    end

    test "error logs with context" do
      error = %RuntimeError{message: "Something went wrong"}
      
      log = capture_log(fn ->
        Logger.log_error(error, [operation: "test"])
      end)

      assert log =~ "Application error"
      assert log =~ "error_type=RuntimeError"
      assert log =~ "error_message=\"Something went wrong\""
      assert log =~ "operation=\"test\""
    end

    test "performance logging" do
      log = capture_log(fn ->
        Logger.log_performance("test_operation", 150.5, [component: "test"])
      end)

      assert log =~ "Performance metric"
      assert log =~ "operation=\"test_operation\""
      assert log =~ "duration_ms=150.5"
      assert log =~ "component=\"test\""
    end

    test "time_and_log measures execution time" do
      log = capture_log(fn ->
        result = Logger.time_and_log("test_function", fn ->
          :timer.sleep(10)
          :ok
        end)
        
        assert result == :ok
      end)

      assert log =~ "Performance metric"
      assert log =~ "operation=\"test_function\""
      assert log =~ "duration_ms="
    end

    test "user action logging" do
      log = capture_log(fn ->
        Logger.log_user_action("user123", "login", "session", [ip: "127.0.0.1"])
      end)

      assert log =~ "User action"
      assert log =~ "user_id=\"user123\""
      assert log =~ "action=\"login\""
      assert log =~ "resource=\"session\""
      assert log =~ "audit=true"
      assert log =~ "ip=\"127.0.0.1\""
    end

    test "query logging" do
      log = capture_log(fn ->
        Logger.log_query("SELECT * FROM users WHERE id = ?", 25.3, [rows: 10])
      end)

      assert log =~ "Database query"
      assert log =~ "query_type=\"database\""
      assert log =~ "duration_ms=25.3"
      assert log =~ "query=\"SELECT * FROM users WHERE id = ?\""
      assert log =~ "rows=10"
    end
  end

  describe "log levels" do
    test "debug logging" do
      log = capture_log(fn ->
        Logger.debug("Debug message", [detail: "extra"])
      end)

      assert log =~ "Debug message"
      assert log =~ "detail=\"extra\""
    end

    test "warning logging" do
      log = capture_log(fn ->
        Logger.warn("Warning message", [severity: "medium"])
      end)

      assert log =~ "Warning message"
      assert log =~ "severity=\"medium\""
    end
  end
end