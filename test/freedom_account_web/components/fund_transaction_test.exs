defmodule FreedomAccountWeb.FundTransactionTest do
  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias FreedomAccount.MoneyUtils
  alias FreedomAccountWeb.FundTransaction

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

      conn
      |> visit(~p"/funds/#{fund}")
      |> assert_has(table_cell(), text: "#{deposit.date}")
      |> assert_has(table_cell(), text: deposit.memo)
      |> assert_has(role("deposit"), text: "#{deposit_line_item.amount}")
      |> assert_has(table_cell(), text: "#{withdrawal.date}")
      |> assert_has(table_cell(), text: withdrawal.memo)
      |> assert_has(role("withdrawal"), text: "#{MoneyUtils.negate(withdrawal_line_item.amount)}")
    end

    test "paginates transactions", %{conn: conn, fund: fund} do
      page_size = FundTransaction.Index.page_size()
      count = round(page_size * 2.5)

      transactions =
        for i <- 1..count do
          Factory.deposit(fund, date: :local |> Timex.today() |> Timex.shift(days: i * -1))
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

    defp assert_has_all_transactions(session, transactions) do
      Enum.reduce(transactions, session, fn txn, session ->
        assert_has(session, table_cell(), text: "#{txn.date}")
      end)
    end
  end
end
