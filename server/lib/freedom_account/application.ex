defmodule FreedomAccount.Application do
  @moduledoc false

  use Application

  @spec start(Application.start_type(), start_args :: term()) ::
          {:ok, pid()} | {:ok, pid(), Application.state()} | {:error, reason :: term()}
  def start(_type, _args) do
    children = [
      FreedomAccount.Repo,
      FreedomAccountWeb.Telemetry,
      {Phoenix.PubSub, name: FreedomAccount.PubSub},
      FreedomAccountWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: FreedomAccount.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @spec config_change(changed, new, removed) :: :ok
        when changed: keyword(), new: keyword(), removed: [atom()]
  def config_change(changed, _new, removed) do
    FreedomAccountWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
