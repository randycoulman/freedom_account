defmodule FreedomAccountWeb.Resolvers.Fund do
  @moduledoc """
  GraphQL resolvers for fund-related operations.
  """

  use FreedomAccountWeb.Resolvers.Base

  @type account :: FreedomAccount.account()
  @type fund :: %{
          icon: String.t(),
          id: String.t(),
          name: String.t()
        }

  @spec list_funds(account :: account, args :: %{}, resolution :: resolution) :: result([fund])
  def list_funds(account, _args, _resolution) do
    with {:ok, funds} <- FreedomAccount.list_funds(account) do
      {:ok, funds}
    end
  end
end
