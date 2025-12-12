defmodule FreedomAccountWeb.LoanLive.ShowTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  import Money.Sigil

  alias FreedomAccount.Factory
  alias FreedomAccount.Loans
  alias Phoenix.HTML.Safe

  describe "viewing an individual loan" do
    setup [:create_account, :create_loan]

    test "drills down to individual loan and back", %{conn: conn, loan: loan} do
      conn
      |> visit(~p"/loans")
      |> click_link(loan_card(loan), loan.name)
      |> assert_has(page_title(), text: Safe.to_iodata(loan))
      |> assert_has(heading(), text: Safe.to_iodata(loan))
      |> assert_has(heading(), text: "$0.00")
      |> click_link("Back to Loans")
      |> assert_has(page_title(), text: "Loans")
      |> assert_has(active_tab(), text: "Loans")
    end

    test "displays loan", %{conn: conn, loan: loan} do
      conn
      |> visit(~p"/loans/#{loan}")
      |> assert_has(heading(), text: Safe.to_iodata(loan))
    end

    test "updates loan within modal", %{conn: conn, loan: loan} do
      %{icon: icon, name: name} = Factory.loan_attrs()
      Factory.lend(loan)
      {:ok, loan} = Loans.with_updated_balance(loan)

      conn
      |> visit(~p"/loans/#{loan}")
      |> click_link("Edit Details")
      |> assert_has(page_title(), text: "Edit Loan")
      |> assert_has(heading(), text: "Edit Loan")
      |> fill_in("Icon", with: "")
      |> fill_in("Name", with: "")
      |> assert_has(field_error("#loan_icon"), text: "can't be blank")
      |> assert_has(field_error("#loan_name"), text: "can't be blank")
      |> fill_in("Icon", with: icon)
      |> fill_in("Name", with: name)
      |> click_button("Save Loan")
      |> assert_has(flash(:info), text: "Loan updated successfully")
      |> assert_has(page_title(), text: "#{icon} #{name}")
      |> assert_has(heading(), text: "#{icon} #{name}")
      |> assert_has(heading(), text: "#{loan.current_balance}")
      |> assert_has(sidebar_loan_name(), text: "#{icon} #{name}")
      |> assert_has(sidebar_loan_balance(), text: "#{loan.current_balance}")
    end

    test "allows lending money from a loan", %{conn: conn, loan: loan} do
      conn
      |> visit(~p"/loans/#{loan}")
      |> click_link("Lend")
      |> assert_path(~p"/loans/#{loan}/loans/new")
      |> click_link("Cancel")
      |> assert_has(heading(), text: Safe.to_iodata(loan))
    end

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
      |> visit(~p"/loans/#{loan}")
      |> click_link("Payment")
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
  end
end
