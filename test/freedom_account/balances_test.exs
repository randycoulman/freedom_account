defmodule FreedomAccount.BalancesTest do
  @moduledoc false

  use FreedomAccount.DataCase, async: true

  alias FreedomAccount.Balances
  alias FreedomAccount.Balances.Summary
  alias FreedomAccount.Factory
  alias FreedomAccount.MoneyUtils

  describe "computing an account's balance" do
    setup [:create_account]

    test "has zero balances when account has no funds or loans", %{account: account} do
      assert %Summary{
               funds: Money.zero(:usd),
               loans: Money.zero(:usd),
               total: Money.zero(:usd)
             } == Balances.summary(account)
    end

    test "has zero balances when all funds and loans have no transactions", %{account: account} do
      for _i <- 1..3, do: Factory.fund(account)
      for _i <- 1..3, do: Factory.loan(account)

      assert %Summary{
               funds: Money.zero(:usd),
               loans: Money.zero(:usd),
               total: Money.zero(:usd)
             } == Balances.summary(account)
    end

    test "sums the balances of all funds and loans in the account", %{account: account} do
      funds = for _i <- 1..5, do: account |> Factory.fund() |> Factory.with_fund_balance()
      loans = for _i <- 1..3, do: account |> Factory.loan() |> Factory.with_loan_balance()

      balance = fn list -> list |> Enum.map(& &1.current_balance) |> MoneyUtils.sum() end

      assert %Summary{
               funds: balance.(funds),
               loans: balance.(loans),
               total: balance.(funds ++ loans)
             } == Balances.summary(account)
    end
  end
end
