defmodule FreedomAccount.Repo do
  use Ecto.Repo,
    otp_app: :freedom_account,
    adapter: Ecto.Adapters.Postgres
end
