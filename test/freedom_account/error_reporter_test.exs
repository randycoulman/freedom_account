defmodule FreedomAccount.ErrorReporterTest do
  use FreedomAccount.Case, async: true

  import ExUnit.CaptureLog

  require FreedomAccount.ErrorReporter, as: ErrorReporter

  @message "Error Message"

  describe "logging errors" do
    test "logs a simple error" do
      output = logged_error(@message)

      assert output =~ @message
    end

    test "includes metadata for original calling location" do
      output = logged_error(@message)

      assert output =~ "mfa=#{inspect(__MODULE__)}.logged_error/2"
    end

    # We don't test any of the metadata manipulation here because we don't want
    # to make our error logging noisy for all of the other tests.

    defp logged_error(message, opts \\ []) do
      capture_log(fn ->
        ErrorReporter.call(message, opts)
      end)
    end
  end
end
