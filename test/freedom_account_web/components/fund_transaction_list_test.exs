defmodule FreedomAccountWeb.FundTransactionListTest do
  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias FreedomAccount.LocalTime
  alias FreedomAccountWeb.FundTransactionList
  alias Phoenix.HTML.Safe

  setup [:create_account, :create_fund]

  describe "Index" do
    test "shows message when fund has no transactions", %{conn: conn, fund: fund} do
      conn
      |> visit(~p"/funds/#{fund}")
      |> assert_has("#no-transactions")
    end

    test "displays transactions", %{conn: conn, account: account, fund: fund} do
      deposit = Factory.deposit(fund)
      [deposit_line_item] = deposit.line_items
      withdrawal = Factory.withdrawal(account, fund)
      [withdrawal_line_item] = withdrawal.line_items
      balance = Money.add!(deposit_line_item.amount, withdrawal_line_item.amount)

      conn
      |> visit(~p"/funds/#{fund}")
      |> assert_has(table_cell(), text: "#{deposit.date}")
      |> assert_has(table_cell(), text: deposit.memo)
      |> assert_has(role("deposit"), text: "#{deposit_line_item.amount}")
      |> assert_has(table_cell(), text: "#{withdrawal.date}")
      |> assert_has(table_cell(), text: withdrawal.memo)
      |> assert_has(role("withdrawal"), text: "#{Money.negate!(withdrawal_line_item.amount)}")
      |> assert_has(table_cell(), text: "#{balance}")
    end

    test "paginates transactions", %{conn: conn, fund: fund} do
      page_size = FundTransactionList.page_size()
      count = round(page_size * 2.5)

      transactions =
        for i <- 1..count do
          Factory.deposit(fund, date: Date.shift(LocalTime.today(), day: i * -1))
        end

      [page1, page2, page3] = Enum.chunk_every(transactions, page_size)

      conn
      |> visit(~p"/funds/#{fund}")
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

    test "allows editing transaction in listing", %{conn: conn, fund: fund} do
      deposit = Factory.deposit(fund)
      [line_item] = deposit.line_items

      conn
      |> visit(~p"/funds/#{fund}")
      |> click_link(action_link("#txn-#{line_item.id}"), "Edit")
      |> assert_path(~p"/funds/#{fund}/transactions/#{deposit}/edit")
      |> click_link("Cancel")
      |> assert_has(heading(), text: Safe.to_iodata(fund))
    end

    test "deletes transaction in listing", %{conn: conn, fund: fund} do
      deposit = Factory.deposit(fund)
      [line_item] = deposit.line_items

      conn
      |> visit(~p"/funds/#{fund}")
      |> click_link(action_link("#txn-#{line_item.id}"), "Delete")
      |> assert_has(heading(), text: Safe.to_iodata(fund))
      |> assert_has(heading(), text: "$0.00")
      |> assert_has(sidebar_fund_balance(), text: "$0.00")
      |> refute_has("#txn-#{line_item.id}")
    end

    defp assert_has_all_transactions(session, transactions) do
      Enum.reduce(transactions, session, fn txn, session ->
        assert_has(session, table_cell(), text: "#{txn.date}")
      end)
    end
  end
end
