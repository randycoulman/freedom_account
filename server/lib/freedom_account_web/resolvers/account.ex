defmodule FreedomAccountWeb.Resolvers.Account do
  @moduledoc """
  GraphQL resolvers for accounts.
  """

  use FreedomAccountWeb.Resolvers.Base

  @type account :: %{
          id: String.t(),
          name: String.t()
        }

  @fake_account %{
    id: "100",
    name: "Initial Account"
  }

  @spec my_account(args :: %{}, resolution :: resolution) :: result(account)
  def my_account(_args, _resolution) do
    {:ok, @fake_account}
  end
end
