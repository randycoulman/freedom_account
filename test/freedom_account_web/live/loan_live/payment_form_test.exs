defmodule FreedomAccountWeb.LoanLive.PaymentFormTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  import Money.Sigil

  alias FreedomAccount.Factory
  alias Phoenix.HTML.Safe

  describe "accepting a payment on a loan" do
    setup [:create_account, :create_loan]

    test "receives a payment on a loan", %{account: account, conn: conn, loan: loan} do
      fund = account |> Factory.fund() |> Factory.with_fund_balance()
      loan_amount = ~M[5000]usd
      date = Factory.date()
      memo = Factory.memo()
      amount = Factory.money()
      balance = Money.sub!(amount, loan_amount)
      account_balance = Money.add!(fund.current_balance, balance)

      Factory.lend(loan, amount: loan_amount)

      conn
      |> visit(~p"/loans/#{loan}/payments/new")
      |> assert_has(page_title(), text: "Payment")
      |> assert_has(heading(), text: "Payment")
      |> fill_in("Date", with: date)
      |> fill_in("Memo", with: memo)
      |> fill_in("Amount", with: amount)
      |> click_button("Receive Payment")
      |> assert_has(flash(:info), text: "Payment successful")
      |> assert_has(heading(), text: Safe.to_iodata(loan))
      |> assert_has(heading(), text: "#{balance}")
      |> assert_has(heading(), text: "#{account_balance}")
      |> assert_has(sidebar_loan_balance(), text: "#{balance}")
      |> assert_has(table_cell(), text: "#{date}")
      |> assert_has(table_cell(), text: memo)
      |> assert_has(role("payment"), text: "#{amount}")
    end

    test "does not receive a payment on cancel", %{account: account, conn: conn, loan: loan} do
      fund = account |> Factory.fund() |> Factory.with_fund_balance()
      loan_amount = ~M[5000]usd
      date = Factory.date()
      memo = Factory.memo()
      amount = Factory.money()
      balance = Money.negate!(loan_amount)
      account_balance = Money.sub!(fund.current_balance, loan_amount)

      Factory.lend(loan, amount: loan_amount)

      conn
      |> visit(~p"/loans/#{loan}/payments/new")
      |> fill_in("Date", with: date)
      |> fill_in("Memo", with: memo)
      |> fill_in("Amount", with: amount)
      |> click_link("Cancel")
      |> assert_has(heading(), text: Safe.to_iodata(loan))
      |> assert_has(heading(), text: "#{balance}")
      |> assert_has(heading(), text: "#{account_balance}")
      |> assert_has(sidebar_loan_balance(), text: "#{balance}")
    end
  end
end
