defmodule FreedomAccountWeb.BudgetTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Factory
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.MoneyUtils
  alias Phoenix.HTML.Safe

  describe "Show" do
    setup [:create_account, :create_funds]

    test "updates budget within modal on fund list view", %{account: account, conn: conn, funds: funds} do
      [fund1, fund2, fund3] = Enum.map(funds, &Safe.to_iodata/1)
      attrs = [attrs0, attrs1, attrs2] = Enum.map(funds, fn _fund -> Factory.fund_attrs() end)

      amounts =
        [amount1, amount2, amount3] =
        funds
        |> Enum.zip(attrs)
        |> Enum.map(&regular_deposit_amount(&1, account))

      total = MoneyUtils.sum(amounts)

      conn
      |> visit(~p"/funds")
      |> click_link("Budget")
      |> assert_has(page_title(), text: "Update Budget")
      |> assert_has(heading(), text: "Update Budget")
      |> assert_has("label", text: fund1)
      |> assert_has("label", text: fund2)
      |> assert_has("label", text: fund3)
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
      |> assert_has(page_title(), text: "Funds")
      |> assert_has(heading(), text: "Funds")
      |> assert_has(table_cell(), text: "#{attrs1[:budget]}")
      |> assert_has(table_cell(), text: "#{attrs2[:times_per_year]}")
    end
  end

  defp regular_deposit_amount({%Fund{} = fund, attrs}, %Account{} = account) do
    fund
    |> Funds.change_fund(attrs)
    |> Funds.regular_deposit_amount(account)
  end

  defp create_funds(%{account: account}) do
    funds =
      for _i <- 1..3 do
        Factory.fund(account)
      end

    %{funds: Enum.sort_by(funds, & &1.name)}
  end
end
