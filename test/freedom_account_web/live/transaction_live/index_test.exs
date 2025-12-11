defmodule FreedomAccountWeb.TransactionLive.IndexTest do
  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias FreedomAccount.LocalTime
  alias FreedomAccount.MoneyUtils
  alias FreedomAccountWeb.TransactionLive
  alias Phoenix.HTML.Safe

  setup [:create_account, :create_fund, :create_loan]

  describe "listing account transactions" do
    test "shows message when account has no transactions", %{conn: conn} do
      conn
      |> visit(~p"/transactions")
      |> assert_has("#no-transactions")
    end

    test "displays transactions", %{conn: conn, account: account, fund: fund, loan: loan} do
      deposit = Factory.deposit(fund)
      [deposit_line_item] = deposit.line_items
      withdrawal = Factory.withdrawal(account, fund)
      [withdrawal_line_item] = withdrawal.line_items
      lend = Factory.lend(loan)
      payment = Factory.payment(loan)
      balance = MoneyUtils.sum([deposit_line_item.amount, withdrawal_line_item.amount, lend.amount, payment.amount])

      conn
      |> visit(~p"/transactions")
      |> assert_has(table_cell(), text: "#{deposit.date}")
      |> assert_has(table_cell(), text: deposit.memo)
      |> assert_has(role("in"), text: "#{deposit_line_item.amount}")
      |> assert_has(table_cell(), text: "#{withdrawal.date}")
      |> assert_has(table_cell(), text: withdrawal.memo)
      |> assert_has(table_cell(), count: 2, text: Safe.to_iodata(fund))
      |> assert_has(role("out"), text: "#{Money.negate!(withdrawal_line_item.amount)}")
      |> assert_has(table_cell(), text: "#{lend.date}")
      |> assert_has(table_cell(), text: lend.memo)
      |> assert_has(role("out"), text: "#{Money.negate!(lend.amount)}")
      |> assert_has(table_cell(), text: "#{payment.date}")
      |> assert_has(table_cell(), text: payment.memo)
      |> assert_has(table_cell(), count: 2, text: Safe.to_iodata(loan))
      |> assert_has(role("in"), text: "#{payment.amount}")
      |> assert_has(table_cell(), text: "#{balance}")
    end

    test "paginates transactions", %{conn: conn, fund: fund} do
      page_size = TransactionLive.Index.page_size()
      count = round(page_size * 2.5)

      transactions =
        for i <- 1..count do
          Factory.deposit(fund, date: Date.shift(LocalTime.today(), day: i * -1))
        end

      [page1, page2, page3] = Enum.chunk_every(transactions, page_size)

      conn
      |> visit(~p"/transactions")
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

    test "allows editing fund transaction in listing", %{conn: conn, fund: fund} do
      deposit = Factory.deposit(fund)

      conn
      |> visit(~p"/transactions")
      |> click_link(action_link("#txn-#{deposit.id}"), "Edit")
      |> assert_path(~p"/transactions/#{deposit}/edit", query_params: %{"type" => "fund"})
      |> click_link("Cancel")
      |> assert_has(active_tab(), text: "Transactions")
    end

    test "allows editing loan transaction in listing", %{conn: conn, loan: loan} do
      transaction = Factory.lend(loan)

      conn
      |> visit(~p"/transactions")
      |> click_link(action_link("#txn-#{transaction.id}"), "Edit")
      |> assert_path(~p"/transactions/#{transaction}/edit", query_params: %{"type" => "loan"})
      |> click_link("Cancel")
      |> assert_has(active_tab(), text: "Transactions")
    end

    test "deletes fund transaction in listing", %{conn: conn, fund: fund} do
      deposit = Factory.deposit(fund)

      conn
      |> visit(~p"/transactions")
      |> click_link(action_link("#txn-#{deposit.id}"), "Delete")
      |> assert_has(active_tab(), text: "Transactions")
      |> assert_has(account_balance(), text: "$0.00")
      |> refute_has("#txn-#{deposit.id}")
    end

    test "deletes loan transaction in listing", %{conn: conn, loan: loan} do
      lend = Factory.lend(loan)

      conn
      |> visit(~p"/transactions")
      |> click_link(action_link("#txn-#{lend.id}"), "Delete")
      |> assert_has(active_tab(), text: "Transactions")
      |> assert_has(account_balance(), text: "$0.00")
      |> refute_has("#txn-#{lend.id}")
    end

    defp assert_has_all_transactions(session, transactions) do
      Enum.reduce(transactions, session, fn txn, session ->
        assert_has(session, table_cell(), text: "#{txn.date}")
      end)
    end
  end
end
