defmodule FreedomAccount.ErrorReporter do
  @moduledoc """
  Standard error reporting.
  """
  use Boundary

  @type error :: {:error, term()} | term()
  @type opt ::
          {:error, error()}
          | {:metadata, map()}
          | {:stacktrace, Exception.stacktrace()}

  @doc """
  Reports application errors.

  While this module is currently overkill, it is a handy place to add further
  error handling and reporting in the future. For example, if we choose to add
  an alerting service or to use OpenTelemetry for instrumentation.

  Reports application errors to:
  - log messages (via `Logger.error`)

  The error message (a `t:String.t/0`) is required. Options include:
  - `error`: The original error to report; will be automatically added to the
    `metadata`
  - `metadata`: Additional context information about the error. Will be sent to
    all selected destinations; to see the metadata in log messages, Logger must
    be configured to include them.
  - `stacktrace`: The stacktrace of a thrown exception. Defaults to
    `Process.info(self(), :current_stacktrace)` with error-reporting stack
    frames removed.
  """
  @spec call(String.t(), [opt]) :: Macro.t()
  defmacro call(message, opts \\ []) do
    quote bind_quoted: [message: message, module: __MODULE__, opts: opts] do
      require Logger

      {metadata, opts} = Keyword.pop(opts, :metadata, %{})
      opts = Keyword.put_new_lazy(opts, :stacktrace, &module.generate_stacktrace/0)

      # This is done inline in the macro so that the Logger.error call looks
      # like it came from the original caller.
      logger_metadata = module.logger_metadata(metadata, opts)
      Logger.error(message, logger_metadata)
      :ok
    end
  end

  @spec logger_metadata(map(), [opt]) :: keyword()
  def logger_metadata(metadata, opts) do
    error = opts |> Keyword.get(:error) |> normalize_error()
    stacktrace = opts |> Keyword.get(:stacktrace) |> Exception.format_stacktrace()

    metadata
    |> add_error(error)
    |> Map.put(:stacktrace, stacktrace)
    |> Keyword.new()
  end

  defp add_error(metadata, nil), do: metadata
  defp add_error(metadata, error), do: Map.put(metadata, :error, error)

  defp normalize_error({:error, error}), do: error
  defp normalize_error(error), do: error

  @spec generate_stacktrace :: Exception.stacktrace()
  def generate_stacktrace do
    case Process.info(self(), :current_stacktrace) do
      {:current_stacktrace, stacktrace} -> filter_stacktrace(stacktrace)
      _other -> []
    end
  end

  defp filter_stacktrace([{Keyword, :put_new_lazy, _arity_or_args, _location} | rest]), do: filter_stacktrace(rest)
  defp filter_stacktrace([{Process, :info, _arity_or_args, _location} | rest]), do: filter_stacktrace(rest)
  defp filter_stacktrace([{__MODULE__, _function_name, _arity_or_args, _location} | rest]), do: filter_stacktrace(rest)
  defp filter_stacktrace(stacktrace), do: stacktrace
end
