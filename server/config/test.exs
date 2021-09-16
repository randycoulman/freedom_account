import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :freedom_account, FreedomAccountWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :freedom_account, FreedomAccount.Repo, pool: Ecto.Adapters.SQL.Sandbox
