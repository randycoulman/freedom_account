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
  Fetches a single struct from the data store where the primary key matches the
  given id.

  Returns an `:ok` tuple if the struct is found and `{:error, :not_found}` if
  not. If the struct in the queryable has no or more than one primary key, it
  will raise an argument error.

  See `Repo.get/2` for more details, as this function wraps it.
  """
  @spec fetch(Queryable.t(), non_neg_integer()) :: {:ok, Schema.t()} | {:error, :not_found}
  @spec fetch(Queryable.t(), non_neg_integer(), Keyword.t()) :: {:ok, Schema.t()} | {:error, :not_found}
  def fetch(queryable, id, opts \\ []) do
    case get(queryable, id, opts) do
      nil -> {:error, :not_found}
      result -> {:ok, result}
    end
  end

  @doc """
  Fetches a single result from a query.

  Returns an `:ok` tuple if the struct is found and `{:error, :not_found}` if
  not. Raises if more than one entry.

  See `Repo.one/2` for more details, as this function wraps it.
  """
  @spec fetch_one(Queryable.t()) :: {:ok, Schema.t()} | {:error, :not_found}
  @spec fetch_one(Queryable.t(), Keyword.t()) ::
          {:ok, Schema.t()} | {:error, :not_found}
  def fetch_one(queryable, opts \\ []) do
    case one(queryable, opts) do
      nil -> {:error, :not_found}
      struct -> {:ok, struct}
    end
  end
end
