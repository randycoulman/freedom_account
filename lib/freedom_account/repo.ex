defmodule FreedomAccount.Repo do
  @moduledoc """
  The primary FreedomAccount data repository.

  Includes utility functions for operations not provided by Ecto.

  See `Ecto.Repo`.
  """

  use Ecto.Repo,
    otp_app: :freedom_account,
    adapter: Ecto.Adapters.Postgres

  alias Ecto.Queryable
  alias Ecto.Schema

  @doc """
  Fetches a single result from a query.

  Returns an `:ok` tuple if the struct is found and `{:error, :not_found}` if
  not. Raises if more than one entry.

  See `Repo.one/2` for more details, as this function wraps it.
  """
  @spec fetch_one(queryable :: Queryable.t()) :: {:ok, Schema.t()} | {:error, :not_found}
  @spec fetch_one(queryable :: Queryable.t(), opts :: Keyword.t()) ::
          {:ok, Schema.t()} | {:error, :not_found}
  def fetch_one(queryable, opts \\ []) do
    case one(queryable, opts) do
      nil -> {:error, :not_found}
      struct -> {:ok, struct}
    end
  end
end
