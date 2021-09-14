defmodule FreedomAccount.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @spec start(Application.start_type(), start_args :: term()) ::
          {:ok, pid()} | {:ok, pid(), Application.state()} | {:error, reason :: term()}
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      FreedomAccount.Repo,
      # Start the Telemetry supervisor
      FreedomAccountWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: FreedomAccount.PubSub},
      # Start the endpoint when the application starts
      FreedomAccountWeb.Endpoint
      # Starts a worker by calling: FreedomAccount.Worker.start_link(arg)
      # {FreedomAccount.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FreedomAccount.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @spec config_change(changed, new, removed) :: :ok
        when changed: keyword(), new: keyword(), removed: [atom()]
  def config_change(changed, _new, removed) do
    FreedomAccountWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
