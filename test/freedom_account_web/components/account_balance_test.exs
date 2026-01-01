defmodule FreedomAccountWeb.AccountBalanceTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias FreedomAccount.Funds
  alias FreedomAccount.Loans
  alias FreedomAccount.MoneyUtils
  alias FreedomAccount.Transactions

  setup :create_account

  for page <- [:fund_list, :fund_show] do
    describe "showing the account balance on #{page} page" do
      setup :create_funds

      test "displays account balance", %{conn: conn, funds: funds} = context do
        page = unquote(page)
        path = page_path(page, context)
        total_balance = expected_balance(funds)

        conn
        |> visit(path)
        |> assert_has(balance(page), text: "#{total_balance}")
      end

      test "updates balance when transaction is created", %{account: account, conn: conn, funds: funds} = context do
        page = unquote(page)
        path = page_path(page, context)

        session = visit(conn, path)

        {:ok, _transaction} = Transactions.regular_deposit(account, Factory.date(), funds)

        new_balance = account |> Funds.list_active_funds() |> expected_balance()

        assert_has(session, balance(page), text: "#{new_balance}")
      end
    end
  end

  for page <- [:loan_list, :loan_show] do
    describe "showing the account balance on #{page} page" do
      setup :create_loans

      test "displays account balance", %{conn: conn, loans: loans} = context do
        page = unquote(page)
        path = page_path(page, context)
        total_balance = expected_balance(loans)

        conn
        |> visit(path)
        |> assert_has(balance(page), text: MoneyUtils.format(total_balance))
      end

      test "updates balance when transaction is created", %{account: account, conn: conn, loans: loans} = context do
        [loan | _rest] = loans
        page = unquote(page)
        path = page_path(page, context)

        session = visit(conn, path)

        _transaction = Factory.lend(loan)

        new_balance = account |> Loans.list_active_loans() |> expected_balance()

        assert_has(session, balance(page), text: MoneyUtils.format(new_balance))
      end
    end
  end

  defp balance(page) when page in [:fund_list, :loan_list], do: active_tab()
  defp balance(page) when page in [:fund_show, :loan_show], do: heading()

  defp create_funds(%{account: account}) do
    funds =
      for _i <- 1..5 do
        account |> Factory.fund() |> Factory.with_fund_balance()
      end

    %{funds: funds}
  end

  defp create_loans(%{account: account}) do
    loans =
      for _i <- 1..5 do
        account |> Factory.loan() |> Factory.with_loan_balance()
      end

    %{loans: loans}
  end

  defp page_path(:fund_list, _context), do: ~p"/funds"
  defp page_path(:fund_show, %{funds: [fund | _rest]} = _context), do: ~p"/funds/#{fund}"
  defp page_path(:loan_list, _context), do: ~p"/loans"
  defp page_path(:loan_show, %{loans: [loan | _rest]} = _context), do: ~p"/loans/#{loan}"

  defp expected_balance(items) do
    items |> Enum.map(& &1.current_balance) |> MoneyUtils.sum()
  end
end
