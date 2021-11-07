defmodule FreedomAccountWeb.Resolvers.Fund do
  @moduledoc """
  GraphQL resolvers for fund-related operations.
  """

  @type args :: map()
  @type resolution :: Absinthe.Resolution.t()
  @type result :: Absinthe.Type.Field.result()

  @fake_funds [
    %{
      icon: "🏚️",
      id: 1,
      name: "Home Repairs"
    },
    %{
      icon: "🚘",
      id: 2,
      name: "Car Repairs"
    },
    %{
      icon: "💸",
      id: 3,
      name: "Property Taxes"
    }
  ]

  @spec list_funds(args :: args, resolution :: resolution) :: result()
  def(list_funds(_args, _resolution)) do
    {:ok, @fake_funds}
  end
end
