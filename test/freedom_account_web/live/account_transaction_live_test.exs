defmodule FreedomAccountWeb.AccountTransactionTest do
  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias FreedomAccount.MoneyUtils
  alias FreedomAccount.Transactions
  alias FreedomAccountWeb.TransactionLive
  alias Phoenix.HTML.Safe

  setup [:create_account, :create_fund, :create_loan]

  describe "Index" do
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
          Factory.deposit(fund, date: :local |> Timex.today() |> Timex.shift(days: i * -1))
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

    test "edits single-fund transaction in listing", %{conn: conn, fund: fund} do
      deposit = Factory.deposit(fund)
      [line_item] = deposit.line_items
      new_date = Factory.date()
      new_memo = Factory.memo()
      new_amount = Factory.money()

      conn
      |> visit(~p"/transactions")
      |> click_link(action_link("#txn-#{deposit.id}"), "Edit")
      |> assert_has(page_title(), text: "Edit Transaction")
      |> assert_has(heading(), text: "Edit Transaction")
      |> assert_has(field_value("#transaction_date", deposit.date))
      |> assert_has(field_value("#transaction_memo", deposit.memo))
      |> assert_has(field_value("#transaction_line_items_0_amount", line_item.amount))
      |> assert_has("label", text: fund.name)
      |> fill_in("Date", with: new_date)
      |> fill_in("Memo", with: new_memo)
      |> fill_in("Amount 0", with: new_amount)
      |> click_button("Save Transaction")
      |> assert_has(flash(:info), text: "Transaction updated successfully")
      |> assert_has(heading(), text: "Transactions")
      |> assert_has(heading(), text: "#{new_amount}")
      |> assert_has(table_cell(), text: "#{new_date}")
      |> assert_has(table_cell(), text: new_memo)
      |> assert_has(role("in"), text: "#{new_amount}")
    end

    test "edits multi-fund transaction in listing", %{account: account, conn: conn, fund: fund1} do
      [fund2, fund3] = more_funds = for _i <- 1..2, do: Factory.fund(account)
      funds = [fund1 | more_funds]
      {:ok, transaction} = Transactions.regular_deposit(account, Factory.date(), funds)
      [line_item1, line_item2, line_item3] = transaction.line_items
      new_date = Factory.date()
      new_memo = Factory.memo()
      [new_amount1, new_amount2, new_amount3] = new_amounts = for _i <- 1..3, do: Factory.money()
      net_amount = MoneyUtils.sum(new_amounts)

      conn
      |> visit(~p"/transactions")
      |> click_link(action_link("#txn-#{transaction.id}"), "Edit")
      |> assert_has(page_title(), text: "Edit Transaction")
      |> assert_has(heading(), text: "Edit Transaction")
      |> assert_has(field_value("#transaction_date", transaction.date))
      |> assert_has(field_value("#transaction_memo", transaction.memo))
      |> assert_has(field_value("#transaction_line_items_0_amount", line_item1.amount))
      |> assert_has(field_value("#transaction_line_items_1_amount", line_item2.amount))
      |> assert_has(field_value("#transaction_line_items_2_amount", line_item3.amount))
      |> assert_has("label", text: Safe.to_iodata(fund1))
      |> assert_has("label", text: Safe.to_iodata(fund2))
      |> assert_has("label", text: Safe.to_iodata(fund3))
      |> fill_in("Date", with: new_date)
      |> fill_in("Memo", with: new_memo)
      |> fill_in("Amount 0", with: new_amount1)
      |> fill_in("Amount 1", with: new_amount2)
      |> fill_in("Amount 2", with: new_amount3)
      |> click_button("Save Transaction")
      |> assert_has(flash(:info), text: "Transaction updated successfully")
      |> assert_has(table_cell(), text: "#{new_date}")
      |> assert_has(table_cell(), text: new_memo)
      |> assert_has(role("in"), text: "#{net_amount}")
    end

    test "edits loan transaction in listing", %{conn: conn, loan: loan} do
      transaction = Factory.lend(loan)
      new_date = Factory.date()
      new_memo = Factory.memo()
      new_amount = Money.negate!(Factory.money())

      conn
      |> visit(~p"/transactions")
      |> click_link(action_link("#txn-#{transaction.id}"), "Edit")
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
      |> assert_has(heading(), text: "Transactions")
      |> assert_has(heading(), text: "#{new_amount}")
      |> assert_has(table_cell(), text: "#{new_date}")
      |> assert_has(table_cell(), text: new_memo)
      |> assert_has(role("out"), text: "#{Money.negate!(new_amount)}")
    end

    test "deletes fund transaction in listing", %{conn: conn, fund: fund} do
      deposit = Factory.deposit(fund)

      conn
      |> visit(~p"/transactions")
      |> click_link(action_link("#txn-#{deposit.id}"), "Delete")
      |> assert_has(heading(), text: "Transactions")
      |> assert_has(heading(), text: "$0.00")
      |> refute_has("#txn-#{deposit.id}")
    end

    test "deletes loan transaction in listing", %{conn: conn, loan: loan} do
      lend = Factory.lend(loan)

      conn
      |> visit(~p"/transactions")
      |> click_link(action_link("#txn-#{lend.id}"), "Delete")
      |> assert_has(heading(), text: "Transactions")
      |> assert_has(heading(), text: "$0.00")
      |> refute_has("#txn-#{lend.id}")
    end

    defp assert_has_all_transactions(session, transactions) do
      Enum.reduce(transactions, session, fn txn, session ->
        assert_has(session, table_cell(), text: "#{txn.date}")
      end)
    end
  end
end
