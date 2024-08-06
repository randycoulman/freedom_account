defmodule FreedomAccount.BalancesTest do
  @moduledoc false

  use FreedomAccount.DataCase, async: true

  alias FreedomAccount.Balances
  alias FreedomAccount.Factory
  alias FreedomAccount.MoneyUtils

  describe "computing an account's balance" do
    setup [:create_account]

    test "has zero balance when account has no funds or loans", %{account: account} do
      assert account |> Balances.account_balance() |> Money.zero?()
    end

    test "has zero balance when all funds and loans have no transactions", %{account: account} do
      for _i <- 1..3, do: Factory.fund(account)
      for _i <- 1..3, do: Factory.loan(account)

      assert account |> Balances.account_balance() |> Money.zero?()
    end

    test "sums the balances of all funds and loans in the account", %{account: account} do
      funds = for _i <- 1..5, do: account |> Factory.fund() |> Factory.with_fund_balance()
      loans = for _i <- 1..3, do: account |> Factory.loan() |> Factory.with_loan_balance()
      expected = (funds ++ loans) |> Enum.map(& &1.current_balance) |> MoneyUtils.sum()

      assert expected == Balances.account_balance(account)
    end
  end
end
