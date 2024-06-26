defmodule FreedomAccount.PubSub do
  @moduledoc """
  Wrap Phoenix.PubSub with a convenience API.
  """
  alias Phoenix.PubSub

  @type event :: atom()
  @type topic :: PubSub.topic()

  @spec broadcast({:ok, struct()} | {:error, term()}, topic(), event()) :: {:ok, struct()} | {:error, term()}
  def broadcast({:ok, record} = result, topic, event) do
    PubSub.broadcast(__MODULE__, topic, {event, record})
    result
  end

  def broadcast({:error, _error} = result, _topic, _event), do: result

  @spec subscribe(topic()) :: :ok | {:error, term}
  def subscribe(topic) do
    PubSub.subscribe(__MODULE__, topic)
  end
end
