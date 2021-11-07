defmodule FreedomAccountWeb.Schema do
  @moduledoc """
  GraphQL schema for the FreedomAccount API.
  """

  use Absinthe.Schema

  import_types FreedomAccountWeb.Schema.FundTypes

  alias FreedomAccountWeb.Resolvers

  query do
    @desc "List all funds"
    field :funds, list_of(:fund) do
      resolve &Resolvers.Fund.list_funds/2
    end
  end
end
