import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :freedom_account, FreedomAccount.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "freedom_account_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :freedom_account, FreedomAccountWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "v4XpHMCN4hfmplJ9bwjcc/ZdP2eCLM++HLMEU4sq1hEbyOC3qlzpFqua1fQtt1Ll",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
