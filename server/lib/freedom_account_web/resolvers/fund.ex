defmodule FreedomAccountWeb.Resolvers.Fund do
  @moduledoc """
  GraphQL resolvers for fund-related operations.
  """

  use FreedomAccountWeb.Resolvers.Base

  alias FreedomAccountWeb.Resolvers.Account

  @type account :: Account.account()
  @type fund :: %{
          icon: String.t(),
          id: String.t(),
          name: String.t()
        }

  @fake_funds [
    %{
      icon: "🏚️",
      id: "1",
      name: "Home Repairs"
    },
    %{
      icon: "🚘",
      id: "2",
      name: "Car Repairs"
    },
    %{
      icon: "💸",
      id: "3",
      name: "Property Taxes"
    }
  ]

  @spec list_funds(account :: account, args :: %{}, resolution :: resolution) :: result([fund])
  def list_funds(_account, _args, _resolution) do
    {:ok, @fake_funds}
  end
end
