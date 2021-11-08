defmodule FreedomAccountWeb.Resolvers.Account do
  @moduledoc """
  GraphQL resolvers for accounts.
  """

  use FreedomAccountWeb.Resolvers.Base

  @type account :: FreedomAccount.account()

  @spec my_account(args :: %{}, resolution :: resolution) :: result(account)
  def my_account(_args, _resolution) do
    with {:ok, account} <- FreedomAccount.my_account() do
      {:ok, account}
    end
  end
end
