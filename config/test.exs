import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :freedom_account, FreedomAccount.Repo,
  database: "freedom_account_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  password: "postgres",
  pool_size: System.schedulers_online() * 2,
  pool: Ecto.Adapters.SQL.Sandbox,
  username: "postgres"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :freedom_account, FreedomAccountWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "v4XpHMCN4hfmplJ9bwjcc/ZdP2eCLM++HLMEU4sq1hEbyOC3qlzpFqua1fQtt1Ll",
  server: false

# Only show warnings in the console...
config :logger, :console, level: :warning

# ... but capture all logs in test (for capture_log/1)
config :logger, level: :info

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :phoenix_test, :endpoint, FreedomAccountWeb.Endpoint
