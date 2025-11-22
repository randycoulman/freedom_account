# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configure esbuild (the version is required)
config :esbuild,
  freedom_account: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ],
  version: "0.25.4"

config :ex_money,
  default_cldr_backend: FreedomAccount.Cldr

# Configures the endpoint
config :freedom_account, FreedomAccountWeb.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  live_view: [signing_salt: "RD+3ZR5v"],
  pubsub_server: FreedomAccount.PubSub,
  render_errors: [
    formats: [html: FreedomAccountWeb.ErrorHTML, json: FreedomAccountWeb.ErrorJSON],
    layout: false
  ],
  url: [host: "localhost"]

config :freedom_account,
  ecto_repos: [FreedomAccount.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [
    :http_method,
    :http_path,
    :request_id,
    :mfa
    # :endpoint,
  ]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure tailwind (the version is required)
config :tailwind,
  freedom_account: [
    args: ~w(
    --input=assets/css/app.css
    --output=priv/static/assets/css/app.css
    ),

    # Import environment specific config. This must remain at the bottom
    # of this file so it overrides the configuration defined above.
    cd: Path.expand("..", __DIR__)
  ],
  version: "4.1.7"

import_config "#{config_env()}.exs"
