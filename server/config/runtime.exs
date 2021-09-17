# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.

database_url =
  case config_env() do
    :dev ->
      "ecto://postgres:postgres@localhost/freedom_account_dev"

    :test ->
      "ecto://postgres:postgres@localhost/freedom_account_test#{System.get_env("MIX_TEST_PARTITION")}"

    :prod ->
      System.get_env("DATABASE_URL") ||
        raise """
        environment variable DATABASE_URL is missing.
        For example: ecto://USER:PASS@HOST/DATABASE
        """
  end

config :freedom_account, FreedomAccount.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.
#
# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.

if config_env() == :prod do
  host =
    System.get_env("HOSTNAME") ||
      raise """
      environment variable HOSTNAME is missing.
      """

  port = String.to_integer(System.get_env("PORT") || "8080")

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  config :freedom_account, FreedomAccountWeb.Endpoint,
    # cache_static_manifest: "priv/static/cache_manifest.json"
    http: [
      port: port,
      transport_options: [socket_opts: [:inet6]]
    ],
    secret_key_base: secret_key_base,
    server: true,
    url: [host: host, port: port]
end

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :freedom_account, FreedomAccountWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.