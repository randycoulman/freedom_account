defmodule FreedomAccount.PubSub do
  @moduledoc """
  Wrap Phoenix.PubSub with a convenience API.
  """
  use Boundary, deps: [FreedomAccount.Error, FreedomAccount.ErrorReporter]

  alias Ecto.Changeset
  alias FreedomAccount.Error
  alias FreedomAccount.Error.ServiceError
  alias Phoenix.PubSub

  require FreedomAccount.ErrorReporter, as: ErrorReporter

  @type event :: atom()
  @type topic :: PubSub.topic()

  @service :pubsub

  @spec broadcast({:ok, result} | {:error, error}, topic(), event()) :: {:ok, result} | {:error, error}
        when result: term(), error: Changeset.t() | Error.t()
  def broadcast({:ok, record} = result, topic, event) do
    case PubSub.broadcast(__MODULE__, topic, {event, record}) do
      :ok ->
        :ok

      {:error, error} ->
        ErrorReporter.call("Failed to broadcast event '#{event}' on topic '#{topic}'",
          error: error,
          metadata: %{record: record, service: @service, topic: topic}
        )
    end

    result
  end

  def broadcast({:error, _error} = result, _topic, _event), do: result

  @spec subscribe(topic()) :: :ok | {:error, ServiceError.t()}
  def subscribe(topic) do
    case PubSub.subscribe(__MODULE__, topic) do
      :ok ->
        :ok

      {:error, error} ->
        ErrorReporter.call("Failed to subscribe to topic '#{topic}'",
          error: error,
          metadata: %{service: @service, topic: topic}
        )

        Error.service(message: "Unable to subscribe to topic '#{topic}'", service: @service)
    end
  end
end
