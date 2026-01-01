defmodule FreedomAccountWeb.LoanLive.LoanFormTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias FreedomAccount.MoneyUtils
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
      |> assert_has(heading(), text: MoneyUtils.format(balance))
      |> assert_has(account_balance(), text: MoneyUtils.format(account_balance))
      |> assert_has(sidebar_loan_balance(loan), text: MoneyUtils.format(balance))
      |> assert_has(table_cell(), text: "#{date}")
      |> assert_has(table_cell(), text: memo)
      |> assert_has(role("loan"), text: MoneyUtils.format(amount))
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
      |> assert_has(heading(), text: :usd |> Money.zero() |> MoneyUtils.format())
      |> assert_has(heading(), text: MoneyUtils.format(fund.current_balance))
      |> assert_has(sidebar_loan_balance(loan), text: :usd |> Money.zero() |> MoneyUtils.format())
    end
  end
end
