defmodule FreedomAccountWeb.Schema.AccountTypes do
  @moduledoc """
  GraphQL type definitions for accounts.
  """

  use Absinthe.Schema.Notation

  alias FreedomAccountWeb.Resolvers.Fund

  import_types FreedomAccountWeb.Schema.FundTypes

  @desc "A Freedom Account"
  object :account do
    @desc "How many regular deposits will be made per year?"
    field :deposits_per_year, non_null(:integer)
    @desc "The account's unique ID"
    field :id, non_null(:id)
    @desc "The name of the account"
    field :name, non_null(:string)

    @desc "The individual funds in the account"
    field :funds, non_null(list_of(non_null(:fund))) do
      resolve &Fund.list_funds/3
    end
  end

  @desc "Account settings input"
  input_object :account_input do
    @desc "How many regular deposits will be made per year?"
    field :deposits_per_year, non_null(:integer)
    @desc "The account's unique ID"
    field :id, non_null(:id)
    @desc "The name of the account"
    field :name, non_null(:string)
  end
end
