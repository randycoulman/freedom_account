defmodule FreedomAccountWeb.FundLive.TransactionFormTest do
  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias FreedomAccount.Transactions
  alias Phoenix.HTML.Safe

  setup [:create_account, :create_fund]

  describe "updating transactions" do
    test "edits single-fund transaction", %{conn: conn, fund: fund} do
      deposit = Factory.deposit(fund)
      [line_item] = deposit.line_items
      new_date = Factory.date()
      new_memo = Factory.memo()
      new_amount = Factory.money()

      conn
      |> visit(~p"/funds/#{fund}/transactions/#{deposit}/edit")
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
      |> assert_has(heading(), text: Safe.to_iodata(fund))
      |> assert_has(heading(), text: "#{new_amount}")
      |> assert_has(sidebar_fund_balance(), text: "#{new_amount}")
      |> assert_has(table_cell(), text: "#{new_date}")
      |> assert_has(table_cell(), text: new_memo)
      |> assert_has(role("deposit"), text: "#{new_amount}")
    end

    test "edits multi-fund transaction", %{account: account, conn: conn, fund: fund1} do
      [fund2, fund3] = more_funds = for _i <- 1..2, do: Factory.fund(account)
      funds = [fund1 | more_funds]
      {:ok, transaction} = Transactions.regular_deposit(account, Factory.date(), funds)
      [line_item1, line_item2, line_item3] = transaction.line_items
      new_date = Factory.date()
      new_memo = Factory.memo()
      [new_amount1, new_amount2, new_amount3] = for _i <- 1..3, do: Factory.money()

      conn
      |> visit(~p"/funds/#{fund1}/transactions/#{transaction}/edit")
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
      |> assert_has(role("deposit"), text: "#{new_amount1}")
    end

    test "does not update transaction on cancel", %{conn: conn, fund: fund} do
      deposit = Factory.deposit(fund)
      [line_item] = deposit.line_items
      new_date = Factory.date()
      new_memo = Factory.memo()
      new_amount = Factory.money()

      conn
      |> visit(~p"/funds/#{fund}/transactions/#{deposit}/edit")
      |> fill_in("Date", with: new_date)
      |> fill_in("Memo", with: new_memo)
      |> fill_in("Amount 0", with: new_amount)
      |> click_link("Cancel")
      |> assert_has(heading(), text: Safe.to_iodata(fund))
      |> assert_has(heading(), text: "#{line_item.amount}")
      |> assert_has(sidebar_fund_balance(), text: "#{line_item.amount}")
    end
  end
end
