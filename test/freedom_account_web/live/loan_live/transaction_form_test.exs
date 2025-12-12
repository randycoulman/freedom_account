defmodule FreedomAccountWeb.LoanLive.TransactionFormTest do
  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias Phoenix.HTML.Safe

  setup [:create_account, :create_loan]

  describe "updating transactions" do
    test "edits transaction", %{conn: conn, loan: loan} do
      transaction = Factory.lend(loan)
      new_date = Factory.date()
      new_memo = Factory.memo()
      new_amount = Money.negate!(Factory.money())

      conn
      |> visit(~p"/loans/#{loan}/transactions/#{transaction}/edit")
      |> assert_has(page_title(), text: "Edit Loan Transaction")
      |> assert_has(heading(), text: "Edit Loan Transaction")
      |> assert_has(role("loan"), text: Safe.to_iodata(loan))
      |> assert_has(field_value("#loan_transaction_date", transaction.date))
      |> assert_has(field_value("#loan_transaction_memo", transaction.memo))
      |> assert_has(field_value("#loan_transaction_amount", transaction.amount))
      |> fill_in("Date", with: new_date)
      |> fill_in("Memo", with: new_memo)
      |> fill_in("Amount", with: new_amount)
      |> click_button("Save Transaction")
      |> assert_has(flash(:info), text: "Transaction updated successfully")
      |> assert_has(heading(), text: Safe.to_iodata(loan))
      |> assert_has(heading(), text: "#{new_amount}")
      |> assert_has(sidebar_loan_balance(), text: "#{new_amount}")
      |> assert_has(table_cell(), text: "#{new_date}")
      |> assert_has(table_cell(), text: new_memo)
      |> assert_has(role("loan"), text: "#{Money.negate!(new_amount)}")
    end

    test "does not update transaction on cancel", %{conn: conn, loan: loan} do
      transaction = Factory.lend(loan)
      new_date = Factory.date()
      new_memo = Factory.memo()
      new_amount = Money.negate!(Factory.money())

      conn
      |> visit(~p"/loans/#{loan}/transactions/#{transaction}/edit")
      |> fill_in("Date", with: new_date)
      |> fill_in("Memo", with: new_memo)
      |> fill_in("Amount", with: new_amount)
      |> click_link("Cancel")
      |> assert_has(heading(), text: Safe.to_iodata(loan))
      |> assert_has(heading(), text: "#{transaction.amount}")
      |> assert_has(sidebar_loan_balance(), text: "#{transaction.amount}")
    end
  end
end
