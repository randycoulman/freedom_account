defmodule FreedomAccount.PubSub do
  @moduledoc """
  Wrap Phoenix.PubSub with a convenience API.
  """
  alias Ecto.Changeset
  alias FreedomAccount.Error
  alias FreedomAccount.Error.ServiceError
  alias Phoenix.PubSub

  @type event :: atom()
  @type topic :: PubSub.topic()

  @spec broadcast({:ok, result} | {:error, error}, topic(), event()) :: {:ok, result} | {:error, error}
        when result: term(), error: Changeset.t() | Error.t()
  def broadcast({:ok, record} = result, topic, event) do
    PubSub.broadcast(__MODULE__, topic, {event, record})
    result
  end

  def broadcast({:error, _error} = result, _topic, _event), do: result

  @spec subscribe(topic()) :: :ok | {:error, ServiceError.t()}
  def subscribe(topic) do
    case PubSub.subscribe(__MODULE__, topic) do
      :ok -> :ok
      {:error, _error} -> Error.service(message: "Unable to subscribe to topic '#{topic}'", service: :pubsub)
    end
  end
end
