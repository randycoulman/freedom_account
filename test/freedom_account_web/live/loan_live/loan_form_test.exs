defmodule FreedomAccountWeb.LoanLive.LoanFormTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias Phoenix.HTML.Safe

  describe "lending money" do
    setup [:create_account, :create_loan]

    test "lends money from a loan", %{account: account, conn: conn, loan: loan} do
      fund = account |> Factory.fund() |> Factory.with_fund_balance()
      date = Factory.date()
      memo = Factory.memo()
      amount = Factory.money()
      balance = Money.negate!(amount)
      account_balance = Money.sub!(fund.current_balance, amount)

      conn
      |> visit(~p"/loans/#{loan}/loans/new")
      |> assert_has(page_title(), text: "Lend")
      |> assert_has(heading(), text: "Lend")
      |> fill_in("Date", with: date)
      |> fill_in("Memo", with: memo)
      |> fill_in("Amount", with: amount)
      |> click_button("Lend Money")
      |> assert_has(flash(:info), text: "Money lent successfully")
      |> assert_has(heading(), text: Safe.to_iodata(loan))
      |> assert_has(heading(), text: "#{balance}")
      |> assert_has(heading(), text: "#{account_balance}")
      |> assert_has(sidebar_loan_balance(), text: "#{balance}")
      |> assert_has(table_cell(), text: "#{date}")
      |> assert_has(table_cell(), text: memo)
      |> assert_has(role("loan"), text: "#{amount}")
    end

    test "does not record loan on cancel", %{account: account, conn: conn, loan: loan} do
      fund = account |> Factory.fund() |> Factory.with_fund_balance()
      date = Factory.date()
      memo = Factory.memo()
      amount = Factory.money()

      conn
      |> visit(~p"/loans/#{loan}/loans/new")
      |> fill_in("Date", with: date)
      |> fill_in("Memo", with: memo)
      |> fill_in("Amount", with: amount)
      |> click_link("Cancel")
      |> assert_has(heading(), text: Safe.to_iodata(loan))
      |> assert_has(heading(), text: "#{Money.zero(:usd)}")
      |> assert_has(heading(), text: "#{fund.current_balance}")
      |> assert_has(sidebar_loan_balance(), text: "#{Money.zero(:usd)}")
    end
  end
end
