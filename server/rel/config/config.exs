use Mix.Config

config :freedom_account, FreedomAccount.Repo,
  username: System.get_env("POSTGRES_USER"),
  password: System.get_env("POSTGRES_PASSWORD"),
  database: System.get_env("POSTGRES_DB"),
  hostname: System.get_env("POSTGRES_HOST"),
  pool_size: 15

port = String.to_integer(System.get_env("PORT") || "8080")

config :freedom_account, FreedomAccountWeb.Endpoint,
  # cache_static_manifest: "priv/static/cache_manifest.json",
  http: [port: port],
  root: ".",
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  server: true,
  url: [host: System.get_env("HOSTNAME"), port: port]
