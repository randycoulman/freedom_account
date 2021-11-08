defmodule FreedomAccountWeb.Schema.AccountTypes do
  @moduledoc """
  GraphQL type definitions for accounts.
  """

  use Absinthe.Schema.Notation

  alias FreedomAccountWeb.Resolvers

  import_types FreedomAccountWeb.Schema.FundTypes

  @desc "A Freedom Account"
  object :account do
    @desc "The account's unique ID"
    field :id, non_null(:id)
    @desc "The name of the account"
    field :name, non_null(:string)

    @desc "The individual funds in the account"
    field :funds, non_null(list_of(non_null(:fund))) do
      resolve &Resolvers.Fund.list_funds/3
    end
  end
end
