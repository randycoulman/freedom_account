defmodule FreedomAccount.DevLogFormatter do
  @moduledoc """
  Custom formatter for Logger for dev.
  ​
  We want to include generic metadata in our dev log messages, but Elixir/Logger
  includes some pre-supplied metadata that we don't want to log. This formatter
  wraps the default formatter, strips out the unwanted metadata keys and calls
  the standard formatter with the result.
  """

  alias Logger.Formatter

  @type time :: Formatter.date_time_ms()
  @format Formatter.compile("[$level] $message { $metadata }\n")
  @omit_keys [
    :application,
    :domain,
    :erl_level,
    :file,
    :function,
    :line,
    :module,
    :stacktrace
  ]

  @spec format(
          level :: Logger.level(),
          msg :: Logger.message(),
          timestamp :: time,
          metadata :: keyword
        ) :: IO.chardata()
  def format(level, msg, timestamp, metadata) do
    metadata =
      metadata
      |> Keyword.drop(@omit_keys)
      |> Keyword.update(:error, nil, &inspect/1)
      |> Enum.map(fn
        {k, v} when is_binary(v) -> {k, v}
        {k, v} -> {k, inspect(v, pretty: true)}
      end)

    Formatter.format(@format, level, msg, timestamp, metadata)
  end
end
