defmodule FreedomAccountWeb.FundLive.BudgetTest do
  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Factory
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.MoneyUtils
  alias Phoenix.HTML.Safe

  describe "updating the budget" do
    setup :create_account

    test "updates budget", %{account: account, conn: conn} do
      funds =
        1..3
        |> Enum.map(fn _i -> Factory.fund(account) end)
        |> Enum.sort_by(& &1.name)

      [fund0, fund1, fund2] = funds
      attrs = [attrs0, attrs1, attrs2] = Enum.map(funds, fn _fund -> Factory.fund_attrs() end)

      amounts =
        [amount1, amount2, amount3] =
        funds
        |> Enum.zip(attrs)
        |> Enum.map(&regular_deposit_amount(&1, account))

      total = MoneyUtils.sum(amounts)

      conn
      |> visit(~p"/funds/budget")
      |> assert_has(page_title(), text: "Update Budget")
      |> assert_has(heading(), text: "Update Budget")
      |> assert_has("label", text: Safe.to_iodata(fund0))
      |> assert_has("label", text: Safe.to_iodata(fund1))
      |> assert_has("label", text: Safe.to_iodata(fund2))
      |> fill_in("Budget 1", with: "")
      |> fill_in("Times/Year 2", with: "")
      |> assert_has(field_error("#budget_funds_1_budget"), text: "can't be blank")
      |> assert_has(field_error("#budget_funds_2_times_per_year"), text: "can't be blank")
      |> fill_in("Budget 0", with: attrs0[:budget])
      |> fill_in("Times/Year 0", with: attrs0[:times_per_year])
      |> assert_has(role("deposit-amount-0"), with: "#{amount1}")
      |> fill_in("Budget 1", with: attrs1[:budget])
      |> fill_in("Times/Year 1", with: attrs1[:times_per_year])
      |> assert_has(role("deposit-amount-1"), with: "#{amount2}")
      |> fill_in("Budget 2", with: attrs2[:budget])
      |> fill_in("Times/Year 2", with: attrs2[:times_per_year])
      |> assert_has(role("deposit-amount-2"), with: "#{amount3}")
      |> assert_has("#deposit-total", with: "#{total}")
      |> click_button("Update Budget")
      |> assert_has(flash(:info), text: "Budget updated successfully")
      |> assert_has(active_tab(), text: "Funds")
      |> assert_has(fund_budget(fund1), text: "#{attrs1[:budget]}")
      |> assert_has(fund_frequency(fund2), text: "#{attrs2[:times_per_year]}")
    end

    test "does not update budget on cancel", %{account: account, conn: conn} do
      fund = Factory.fund(account)
      attrs = Factory.fund_attrs()

      conn
      |> visit(~p"/funds/budget")
      |> fill_in("Budget 0", with: attrs[:budget])
      |> fill_in("Times/Year 0", with: attrs[:times_per_year])
      |> click_link("Cancel")
      |> assert_has(active_tab(), text: "Funds")
      |> assert_has(fund_budget(fund), text: "#{fund.budget}")
      |> assert_has(fund_frequency(fund), text: "#{fund.times_per_year}")
    end

    defp regular_deposit_amount({%Fund{} = fund, attrs}, %Account{} = account) do
      fund
      |> Funds.change_fund(attrs)
      |> Funds.regular_deposit_amount(account)
    end
  end
end
