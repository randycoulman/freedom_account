# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :freedom_account,
  ecto_repos: [FreedomAccount.Repo]

# Configures the endpoint
config :freedom_account, FreedomAccountWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "odok5kW5BGc7DH/58dbxwKM7RJWjsJ7xc6kj3mY1o1LMxlBjeZMXyQYKQjRLfV6x",
  render_errors: [view: FreedomAccountWeb.ErrorView, accepts: ~w(json)],
  pubsub_server: FreedomAccount.PubSub,
  live_view: [signing_salt: "PcFHsb2S"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
