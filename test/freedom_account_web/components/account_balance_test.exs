defmodule FreedomAccountWeb.AccountBalanceTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias FreedomAccount.Funds
  alias FreedomAccount.MoneyUtils
  alias FreedomAccount.Transactions

  setup [:create_account, :create_funds]

  for page <- [:fund_list, :fund_show] do
    describe "showing the account balance on #{page} page" do
      test "displays account balance", %{conn: conn, funds: funds} = context do
        page = unquote(page)
        path = page_path(page, context)
        total_balance = expected_balance(funds)

        conn
        |> visit(path)
        |> assert_has(heading(), text: "#{total_balance}")
      end

      test "updates balance when transaction is created", %{account: account, conn: conn, funds: funds} = context do
        page = unquote(page)
        path = page_path(page, context)

        session = visit(conn, path)

        {:ok, _transaction} = Transactions.regular_deposit(account, Factory.date(), funds)

        new_balance = account |> Funds.list_active_funds() |> expected_balance()

        assert_has(session, heading(), text: "#{new_balance}")
      end
    end
  end

  defp create_funds(%{account: account}) do
    funds =
      for _i <- 1..5 do
        account |> Factory.fund() |> Factory.with_fund_balance()
      end

    %{funds: funds}
  end

  defp page_path(:fund_list, _context), do: ~p"/funds"
  defp page_path(:fund_show, %{funds: [fund | _rest]} = _context), do: ~p"/funds/#{fund}"

  defp expected_balance(funds) do
    funds |> Enum.map(& &1.current_balance) |> MoneyUtils.sum()
  end
end
