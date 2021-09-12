use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :freedom_account, FreedomAccountWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :freedom_account, FreedomAccount.Repo,
  username: "postgres",
  password: "postgres",
  database: "freedom_account_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
