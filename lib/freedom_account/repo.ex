defmodule FreedomAccount.Repo do
  @moduledoc """
  The primary FreedomAccount data repository.

  Includes utility functions for operations not provided by Ecto.

  See `Ecto.Repo`.
  """
  use Boundary, deps: [FreedomAccount.Error, FreedomAccount.ErrorReporter]

  use Ecto.Repo,
    otp_app: :freedom_account,
    adapter: Ecto.Adapters.Postgres

  alias Ecto.Queryable
  alias Ecto.Schema
  alias FreedomAccount.Error
  alias FreedomAccount.Error.NotFoundError

  require FreedomAccount.ErrorReporter, as: ErrorReporter

  @spec fetch(Queryable.t(), non_neg_integer()) :: {:ok, Schema.t()} | {:error, NotFoundError.t()}
  @spec fetch(Queryable.t(), non_neg_integer(), Keyword.t()) :: {:ok, Schema.t()} | {:error, NotFoundError.t()}
  def fetch(queryable, id, opts \\ []) do
    case get(queryable, id, opts) do
      nil ->
        entity = extract_entity(queryable)
        ErrorReporter.call("Entity of type #{entity} not found", metadata: %{entity: entity, id: id})
        {:error, Error.not_found(details: %{id: id}, entity: entity)}

      result ->
        {:ok, result}
    end
  end

  @spec fetch_one(Queryable.t()) :: {:ok, Schema.t()} | {:error, NotFoundError.t()}
  @spec fetch_one(Queryable.t(), Keyword.t()) ::
          {:ok, Schema.t()} | {:error, NotFoundError.t()}
  def fetch_one(queryable, opts \\ []) do
    case one(queryable, opts) do
      nil ->
        entity = extract_entity(queryable)
        ErrorReporter.call("Entity of type #{entity} not found", metadata: %{entity: entity})
        {:error, Error.not_found(entity: entity)}

      struct ->
        {:ok, struct}
    end
  end

  defp extract_entity(queryable) when is_atom(queryable), do: queryable

  defp extract_entity(%Ecto.Query{} = query) do
    {_table, schema} = query.from.source
    schema
  end

  defp extract_entity(_unknown_queryable), do: :unknown
end
