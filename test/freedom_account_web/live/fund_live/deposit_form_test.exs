defmodule FreedomAccountWeb.FundLive.DepositFormTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias Phoenix.HTML.Safe

  describe "making a deposit" do
    setup [:create_account, :create_fund]

    test "deposits money to a fund", %{account: account, conn: conn, fund: fund} do
      other_fund = account |> Factory.fund() |> Factory.with_fund_balance()
      date = Factory.date()
      memo = Factory.memo()
      amount = Factory.money()
      account_balance = Money.add!(other_fund.current_balance, amount)

      conn
      |> visit(~p"/funds/#{fund}/deposits/new")
      |> assert_has(page_title(), text: "Deposit")
      |> assert_has(heading(), text: "Deposit")
      |> assert_has("label", text: Safe.to_iodata(fund))
      |> refute_has("#transaction-total")
      |> fill_in("Date", with: date)
      |> fill_in("Memo", with: memo)
      |> click_button("Make Deposit")
      |> refute_has("#line-items-error")
      |> fill_in("Amount 0", with: amount)
      |> click_button("Make Deposit")
      |> assert_has(flash(:info), text: "Deposit successful")
      |> assert_has(heading(), text: Safe.to_iodata(fund))
      |> assert_has(heading(), text: "#{amount}")
      |> assert_has(heading(), text: "#{account_balance}")
      |> assert_has(sidebar_fund_balance(), text: "#{amount}")
      |> assert_has(table_cell(), text: "#{date}")
      |> assert_has(table_cell(), text: memo)
      |> assert_has(role("deposit"), text: "#{amount}")
    end

    test "does not make deposit on cancel", %{account: account, conn: conn, fund: fund} do
      other_fund = account |> Factory.fund() |> Factory.with_fund_balance()
      date = Factory.date()
      memo = Factory.memo()
      amount = Factory.money()

      conn
      |> visit(~p"/funds/#{fund}/deposits/new")
      |> fill_in("Date", with: date)
      |> fill_in("Memo", with: memo)
      |> fill_in("Amount 0", with: amount)
      |> click_link("Cancel")
      |> assert_has(heading(), text: Safe.to_iodata(fund))
      |> assert_has(heading(), text: "#{Money.zero(:usd)}")
      |> assert_has(heading(), text: "#{other_fund.current_balance}")
    end
  end
end
