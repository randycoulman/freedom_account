defmodule FreedomAccountWeb.Schema do
  @moduledoc """
  GraphQL schema for the FreedomAccount API.
  """

  use Absinthe.Schema

  import_types FreedomAccountWeb.Schema.AccountTypes
  import_types FreedomAccountWeb.Schema.UserTypes

  alias FreedomAccountWeb.Resolvers.Account
  alias FreedomAccountWeb.Resolvers.Authentication

  query do
    @desc "My freedom account"
    field :my_account, non_null(:account) do
      resolve &Account.my_account/2
    end
  end

  mutation do
    @desc "Log into the application"
    field :login, non_null(:user) do
      arg :username, non_null(:string)
      resolve &Authentication.login/2

      middleware &Authentication.login_middleware/2
    end

    @desc "Log out of the application"
    field :logout, non_null(:boolean) do
      resolve &Authentication.logout/2

      middleware &Authentication.logout_middleware/2
    end

    @desc "Update account settings"
    field :update_account, non_null(:account) do
      arg :input, non_null(:account_input)

      resolve &Account.update_account/2
    end
  end
end
