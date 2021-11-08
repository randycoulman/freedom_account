defmodule FreedomAccountWeb.Schema do
  @moduledoc """
  GraphQL schema for the FreedomAccount API.
  """

  use Absinthe.Schema

  import_types FreedomAccountWeb.Schema.AccountTypes

  alias FreedomAccountWeb.Resolvers

  query do
    @desc "My freedom account"
    field :my_account, non_null(:account) do
      resolve &Resolvers.Account.my_account/2
    end
  end
end
