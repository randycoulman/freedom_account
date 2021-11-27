defmodule FreedomAccountWeb.Resolvers.Account do
  @moduledoc """
  GraphQL resolvers for accounts.
  """

  use FreedomAccountWeb.Resolvers.Base

  alias FreedomAccount.Authentication.User

  @type account :: FreedomAccount.account()
  @type account_input :: %{
          input: FreedomAccount.account_params()
        }

  @spec my_account(args :: %{}, resolution :: resolution) :: result(account)
  def my_account(_args, %{context: context}) do
    with %User{} = user <- Map.get(context, :current_user, {:error, :unauthorized}) do
      FreedomAccount.my_account(user)
    end
  end

  @spec update_account(args :: account_input, resolution :: resolution) ::
          result(account)
  def update_account(%{input: params}, _resolution) do
    with {:ok, account} <- FreedomAccount.update_account(params) do
      {:ok, account}
    end
  end
end
