defmodule FreedomAccount.Repo do
  @moduledoc """
  The FreedomAccount data repository.
  """

  use Ecto.Repo,
    otp_app: :freedom_account,
    adapter: Ecto.Adapters.Postgres
end
