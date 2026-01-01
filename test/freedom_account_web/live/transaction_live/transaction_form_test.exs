defmodule FreedomAccountWeb.TransactionLive.TransactionFormTest do
  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias FreedomAccount.MoneyUtils
  alias FreedomAccount.Transactions
  alias Phoenix.HTML.Safe

  setup [:create_account, :create_fund, :create_loan]

  describe "updating account transactions" do
    test "edits single-fund transaction", %{conn: conn, fund: fund} do
      deposit = Factory.deposit(fund)
      [line_item] = deposit.line_items
      new_date = Factory.date()
      new_memo = Factory.memo()
      new_amount = Factory.money()

      conn
      |> visit(~p"/transactions/#{deposit}/edit?type=fund")
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
      |> assert_has(active_tab(), text: "Transactions")
      |> assert_has(account_balance(), text: MoneyUtils.format(new_amount))
      |> assert_has(table_cell(), text: "#{new_date}")
      |> assert_has(table_cell(), text: new_memo)
      |> assert_has(role("in"), text: MoneyUtils.format(new_amount))
    end

    test "edits multi-fund transaction", %{account: account, conn: conn, fund: fund1} do
      [fund2, fund3] = more_funds = for _i <- 1..2, do: Factory.fund(account)
      funds = [fund1 | more_funds]
      {:ok, transaction} = Transactions.regular_deposit(account, Factory.date(), funds)
      [line_item1, line_item2, line_item3] = transaction.line_items
      new_date = Factory.date()
      new_memo = Factory.memo()
      [new_amount1, new_amount2, new_amount3] = new_amounts = for _i <- 1..3, do: Factory.money()
      net_amount = MoneyUtils.sum(new_amounts)

      conn
      |> visit(~p"/transactions/#{transaction}/edit?type=fund")
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
      |> assert_has(role("in"), text: MoneyUtils.format(net_amount))
    end

    test "does not update fund transaction on cancel", %{conn: conn, fund: fund} do
      deposit = Factory.deposit(fund)
      [line_item] = deposit.line_items
      new_date = Factory.date()
      new_memo = Factory.memo()
      new_amount = Factory.money()

      conn
      |> visit(~p"/transactions/#{deposit}/edit?type=fund")
      |> fill_in("Date", with: new_date)
      |> fill_in("Memo", with: new_memo)
      |> fill_in("Amount 0", with: new_amount)
      |> click_link("Cancel")
      |> assert_has(active_tab(), text: "Transactions")
      |> assert_has(account_balance(), text: MoneyUtils.format(line_item.amount))
    end

    test "edits loan transaction", %{conn: conn, loan: loan} do
      transaction = Factory.lend(loan)
      new_date = Factory.date()
      new_memo = Factory.memo()
      new_amount = Money.negate!(Factory.money())

      conn
      |> visit(~p"/transactions/#{transaction}/edit?type=loan")
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
      |> assert_has(active_tab(), text: "Transactions")
      |> assert_has(account_balance(), text: MoneyUtils.format(new_amount))
      |> assert_has(table_cell(), text: "#{new_date}")
      |> assert_has(table_cell(), text: new_memo)
      |> assert_has(role("out"), text: MoneyUtils.format(new_amount))
    end

    test "does not update loan transaction on cancel", %{conn: conn, loan: loan} do
      transaction = Factory.lend(loan)
      new_date = Factory.date()
      new_memo = Factory.memo()
      new_amount = Money.negate!(Factory.money())

      conn
      |> visit(~p"/transactions/#{transaction}/edit?type=loan")
      |> fill_in("Date", with: new_date)
      |> fill_in("Memo", with: new_memo)
      |> fill_in("Amount", with: new_amount)
      |> click_link("Cancel")
      |> assert_has(active_tab(), text: "Transactions")
      |> assert_has(account_balance(), text: MoneyUtils.format(transaction.amount))
    end
  end
end
