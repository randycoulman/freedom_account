defmodule FreedomAccountWeb.Resolvers.Fund do
  @moduledoc """
  GraphQL resolvers for fund-related operations.
  """

  use FreedomAccountWeb.Resolvers.Base

  @type account :: FreedomAccount.account()
  @type create_args :: %{
          account_id: FreedomAccount.account_id(),
          input: FreedomAccount.fund_params()
        }
  @type fund :: FreedomAccount.fund()

  @spec create_fund(args :: create_args, resolution :: resolution) :: result(fund)
  def create_fund(%{account_id: account_id, input: params}, _resolution) do
    FreedomAccount.create_fund(account_id, params)
  end

  @spec list_funds(account :: account, args :: %{}, resolution :: resolution) :: result([fund])
  def list_funds(account, _args, _resolution) do
    {:ok, FreedomAccount.list_funds(account)}
  end
end
