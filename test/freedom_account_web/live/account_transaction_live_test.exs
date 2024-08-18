defmodule FreedomAccountWeb.AccountTransactionTest do
  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias FreedomAccount.MoneyUtils
  alias FreedomAccountWeb.TransactionLive

  # alias FreedomAccount.Transactions
  # alias FreedomAccountWeb.FundTransaction
  # alias Phoenix.HTML.Safe

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
      |> assert_has(role("out"), text: "#{MoneyUtils.negate(withdrawal_line_item.amount)}")
      |> assert_has(table_cell(), text: "#{lend.date}")
      |> assert_has(table_cell(), text: lend.memo)
      |> assert_has(role("out"), text: "#{MoneyUtils.negate(lend.amount)}")
      |> assert_has(table_cell(), text: "#{payment.date}")
      |> assert_has(table_cell(), text: payment.memo)
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

    # test "edits single-fund transaction in listing", %{conn: conn, fund: fund} do
    #   deposit = Factory.deposit(fund)
    #   [line_item] = deposit.line_items
    #   new_date = Factory.date()
    #   new_memo = Factory.memo()
    #   new_amount = Factory.money()

    #   conn
    #   |> visit(~p"/funds/#{fund}")
    #   |> click_link(action_link("#txn-#{line_item.id}"), "Edit")
    #   |> assert_has(page_title(), text: "Edit Transaction")
    #   |> assert_has(heading(), text: "Edit Transaction")
    #   |> assert_has(field_value("#transaction_date", deposit.date))
    #   |> assert_has(field_value("#transaction_memo", deposit.memo))
    #   |> assert_has(field_value("#transaction_line_items_0_amount", line_item.amount))
    #   |> assert_has("label", text: fund.name)
    #   |> fill_in("Date", with: new_date)
    #   |> fill_in("Memo", with: new_memo)
    #   |> fill_in("Amount 0", with: new_amount)
    #   |> click_button("Save Transaction")
    #   |> assert_has(flash(:info), text: "Transaction updated successfully")
    #   |> assert_has(heading(), text: Safe.to_iodata(fund))
    #   |> assert_has(heading(), text: "#{new_amount}")
    #   |> assert_has(sidebar_fund_balance(), text: "#{new_amount}")
    #   |> assert_has(table_cell(), text: "#{new_date}")
    #   |> assert_has(table_cell(), text: new_memo)
    #   |> assert_has(role("deposit"), text: "#{new_amount}")
    # end

    # test "edits multi-fund transaction in listing", %{account: account, conn: conn, fund: fund1} do
    #   [fund2, fund3] = more_funds = for _i <- 1..2, do: Factory.fund(account)
    #   funds = [fund1 | more_funds]
    #   {:ok, transaction} = Transactions.regular_deposit(account, Factory.date(), funds)
    #   [line_item1, line_item2, line_item3] = transaction.line_items
    #   new_date = Factory.date()
    #   new_memo = Factory.memo()
    #   [new_amount1, new_amount2, new_amount3] = for _i <- 1..3, do: Factory.money()

    #   conn
    #   |> visit(~p"/funds/#{fund1}")
    #   |> click_link(action_link("#txn-#{line_item1.id}"), "Edit")
    #   |> assert_has(page_title(), text: "Edit Transaction")
    #   |> assert_has(heading(), text: "Edit Transaction")
    #   |> assert_has(field_value("#transaction_date", transaction.date))
    #   |> assert_has(field_value("#transaction_memo", transaction.memo))
    #   |> assert_has(field_value("#transaction_line_items_0_amount", line_item1.amount))
    #   |> assert_has(field_value("#transaction_line_items_1_amount", line_item2.amount))
    #   |> assert_has(field_value("#transaction_line_items_2_amount", line_item3.amount))
    #   |> assert_has("label", text: Safe.to_iodata(fund1))
    #   |> assert_has("label", text: Safe.to_iodata(fund2))
    #   |> assert_has("label", text: Safe.to_iodata(fund3))
    #   |> fill_in("Date", with: new_date)
    #   |> fill_in("Memo", with: new_memo)
    #   |> fill_in("Amount 0", with: new_amount1)
    #   |> fill_in("Amount 1", with: new_amount2)
    #   |> fill_in("Amount 2", with: new_amount3)
    #   |> click_button("Save Transaction")
    #   |> assert_has(flash(:info), text: "Transaction updated successfully")
    #   |> assert_has(table_cell(), text: "#{new_date}")
    #   |> assert_has(table_cell(), text: new_memo)
    #   |> assert_has(role("deposit"), text: "#{new_amount1}")
    # end

    # test "deletes transaction in listing", %{conn: conn, fund: fund} do
    #   deposit = Factory.deposit(fund)
    #   [line_item] = deposit.line_items

    #   conn
    #   |> visit(~p"/funds/#{fund}")
    #   |> click_link(action_link("#txn-#{line_item.id}"), "Delete")
    #   |> assert_has(heading(), text: Safe.to_iodata(fund))
    #   |> assert_has(heading(), text: "$0.00")
    #   |> assert_has(sidebar_fund_balance(), text: "$0.00")
    #   |> refute_has("#txn-#{line_item.id}")
    # end

    defp assert_has_all_transactions(session, transactions) do
      Enum.reduce(transactions, session, fn txn, session ->
        assert_has(session, table_cell(), text: "#{txn.date}")
      end)
    end
  end
end
