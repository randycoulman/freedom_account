defmodule FreedomAccountWeb.Schema do
  @moduledoc """
  GraphQL schema for the FreedomAccount API.
  """

  use Absinthe.Schema

  import_types FreedomAccountWeb.Schema.AccountTypes

  alias FreedomAccountWeb.Resolvers.Account

  query do
    @desc "My freedom account"
    field :my_account, non_null(:account) do
      resolve &Account.my_account/2
    end
  end

  mutation do
    @desc "Update account settings"
    field :update_account, non_null(:account) do
      arg :input, non_null(:account_input)

      resolve &Account.update_account/2
    end
  end
end
