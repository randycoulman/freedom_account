defmodule FreedomAccount.BalancesTest do
  @moduledoc false

  use FreedomAccount.DataCase, async: true

  alias FreedomAccount.Balances
  alias FreedomAccount.Factory
  alias FreedomAccount.MoneyUtils

  describe "computing an account's balance" do
    setup [:create_account]

    test "has zero balance when account has no funds", %{account: account} do
      assert Money.zero?(Balances.account_balance(account))
    end

    test "has zero balance when all funds have no transactions", %{account: account} do
      for _i <- 1..3, do: Factory.fund(account)

      assert Money.zero?(Balances.account_balance(account))
    end

    test "sums the balances of all funds in the account", %{account: account} do
      funds = for _i <- 1..5, do: account |> Factory.fund() |> Factory.with_balance()
      expected = funds |> Enum.map(& &1.current_balance) |> MoneyUtils.sum()

      assert expected == Balances.account_balance(account)
    end
  end
end
