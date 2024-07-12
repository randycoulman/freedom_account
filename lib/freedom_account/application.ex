defmodule FreedomAccount.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  use Boundary, deps: [FreedomAccount, FreedomAccountWeb], top_level?: true

  @impl Application
  def start(_type, _args) do
    children = [
      FreedomAccountWeb.Telemetry,
      FreedomAccount.Repo,
      {DNSCluster, query: Application.get_env(:freedom_account, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: FreedomAccount.PubSub},
      # Start a worker by calling: FreedomAccount.Worker.start_link(arg)
      # {FreedomAccount.Worker, arg},
      # Start to serve requests, typically the last entry
      FreedomAccountWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FreedomAccount.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl Application
  def config_change(changed, _new, removed) do
    FreedomAccountWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
