defmodule FreedomAccountWeb.LoanTransactionTest do
  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias FreedomAccount.MoneyUtils
  alias FreedomAccountWeb.LoanTransaction
  alias Phoenix.HTML.Safe

  setup [:create_account, :create_loan]

  describe "Index" do
    test "shows message when loan has no transactions", %{conn: conn, loan: loan} do
      conn
      |> visit(~p"/loans/#{loan}")
      |> assert_has("#no-transactions")
    end

    test "displays transactions", %{conn: conn, loan: loan} do
      lend = Factory.lend(loan)
      payment = Factory.payment(loan)
      balance = Money.add!(lend.amount, payment.amount)

      conn
      |> visit(~p"/loans/#{loan}")
      |> assert_has(table_cell(), text: "#{lend.date}")
      |> assert_has(table_cell(), text: lend.memo)
      |> assert_has(role("loan"), text: "#{MoneyUtils.negate(lend.amount)}")
      |> assert_has(table_cell(), text: "#{payment.date}")
      |> assert_has(table_cell(), text: payment.memo)
      |> assert_has(role("payment"), text: "#{payment.amount}")
      |> assert_has(table_cell(), text: "#{balance}")
    end

    test "paginates transactions", %{conn: conn, loan: loan} do
      page_size = LoanTransaction.Index.page_size()
      count = round(page_size * 2.5)

      transactions =
        for i <- 1..count do
          Factory.lend(loan, date: :local |> Timex.today() |> Timex.shift(days: i * -1))
        end

      [page1, page2, page3] = Enum.chunk_every(transactions, page_size)

      conn
      |> visit(~p"/loans/#{loan}")
      |> assert_has_all_transactions(page1)
      |> assert_has(disabled("button"), text: "Previous Page")
      |> assert_has(enabled("button"), text: "Next Page")
      |> click_button("Next Page")
      |> assert_has_all_transactions(page2)
      |> assert_has(enabled("button"), text: "Previous Page")
      |> assert_has(enabled("button"), text: "Next Page")
      |> click_button("Next Page")
      |> assert_has_all_transactions(page3)
      |> assert_has(enabled("button"), text: "Previous Page")
      |> assert_has(disabled("button"), text: "Next Page")
      |> click_button("Previous Page")
      |> click_button("Previous Page")
      |> assert_has_all_transactions(page1)
      |> assert_has(disabled("button"), text: "Previous Page")
      |> assert_has(enabled("button"), text: "Next Page")
    end

    test "edits transaction in listing", %{conn: conn, loan: loan} do
      transaction = Factory.lend(loan)
      new_date = Factory.date()
      new_memo = Factory.memo()
      new_amount = MoneyUtils.negate(Factory.money())

      conn
      |> visit(~p"/loans/#{loan}")
      |> click_link(action_link("#txn-#{transaction.id}"), "Edit")
      |> assert_has(page_title(), text: "Edit Loan Transaction")
      |> assert_has(heading(), text: "Edit Loan Transaction")
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
      |> assert_has(role("loan"), text: "#{MoneyUtils.negate(new_amount)}")
    end

    test "deletes transaction in listing", %{conn: conn, loan: loan} do
      transaction = Factory.lend(loan)

      conn
      |> visit(~p"/loans/#{loan}")
      |> click_link(action_link("#txn-#{transaction.id}"), "Delete")
      |> assert_has(heading(), text: Safe.to_iodata(loan))
      |> assert_has(heading(), text: "$0.00")
      |> assert_has(sidebar_loan_balance(), text: "$0.00")
      |> refute_has("#txn-#{transaction.id}")
    end

    defp assert_has_all_transactions(session, transactions) do
      Enum.reduce(transactions, session, fn txn, session ->
        assert_has(session, table_cell(), text: "#{txn.date}")
      end)
    end
  end
end
