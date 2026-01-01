defmodule FreedomAccountWeb.SidebarTest do
  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias FreedomAccount.MoneyUtils
  alias Phoenix.HTML.Safe

  defp create_funds(%{account: account}) do
    funds =
      for _i <- 1..3 do
        account |> Factory.fund() |> Factory.with_fund_balance()
      end

    %{funds: Enum.sort_by(funds, & &1.name)}
  end

  defp create_loans(%{account: account}) do
    loans =
      for _i <- 1..3 do
        account |> Factory.loan() |> Factory.with_loan_balance()
      end

    %{loans: Enum.sort_by(loans, & &1.name)}
  end

  describe "sidebar component" do
    setup [:create_account, :create_funds, :create_loans]

    test "displays both funds and loans on fund show page", %{conn: conn, funds: funds} do
      fund = hd(funds)

      conn
      |> visit(~p"/funds/#{fund}")
      |> assert_has(heading(), text: "Funds")
      |> assert_has(heading(), text: "Loans")
    end

    test "displays both funds and loans on loan show page", %{conn: conn, loans: loans} do
      loan = hd(loans)

      conn
      |> visit(~p"/loans/#{loan}")
      |> assert_has(heading(), text: "Funds")
      |> assert_has(heading(), text: "Loans")
    end

    test "displays simple list of funds", %{conn: conn, funds: funds} do
      [fund1, fund2, fund3] = funds

      conn
      |> visit(~p"/funds/#{fund1}")
      |> assert_has(heading(), text: "Funds")
      |> assert_has(link(), text: Safe.to_iodata(fund1))
      |> assert_has(link(), text: Safe.to_iodata(fund2))
      |> assert_has(link(), text: Safe.to_iodata(fund3))
    end

    test "navigates to other funds", %{conn: conn, funds: funds} do
      [fund1, fund2, _rest] = funds

      conn
      |> visit(~p"/funds/#{fund1}")
      |> click_link(fund2.name)
      |> assert_has(heading(), text: Safe.to_iodata(fund2))
    end

    test "returns to fund list when header clicked", %{conn: conn, funds: funds} do
      fund = hd(funds)

      conn
      |> visit(~p"/funds/#{fund}")
      |> click_link(heading_link(), "Funds")
      |> assert_path(~p"/funds")
    end

    test "displays simple list of loans", %{conn: conn, loans: loans} do
      [loan1, loan2, loan3] = loans

      conn
      |> visit(~p"/loans/#{loan1}")
      |> assert_has(heading(), text: "Loans")
      |> assert_has(link(), text: Safe.to_iodata(loan1))
      |> assert_has(link(), text: Safe.to_iodata(loan2))
      |> assert_has(link(), text: Safe.to_iodata(loan3))
    end

    test "navigates to other loans", %{conn: conn, loans: loans} do
      [loan1, loan2, _rest] = loans

      conn
      |> visit(~p"/loans/#{loan1}")
      |> click_link(loan2.name)
      |> assert_has(heading(), text: Safe.to_iodata(loan2))
    end

    test "returns to loan list when header clicked", %{conn: conn, loans: loans} do
      loan = hd(loans)

      conn
      |> visit(~p"/loans/#{loan}")
      |> click_link(heading_link(), "Loans")
      |> assert_path(~p"/loans")
    end

    test "displays balances in headers", %{conn: conn, funds: funds, loans: loans} do
      funds_balance = funds |> Enum.map(& &1.current_balance) |> MoneyUtils.sum()
      loans_balance = loans |> Enum.map(& &1.current_balance) |> MoneyUtils.sum()

      conn
      |> visit(~p"/funds/#{hd(funds)}")
      |> assert_has(heading(), text: MoneyUtils.format(funds_balance))
      |> assert_has(heading(), text: MoneyUtils.format(loans_balance))
    end
  end
end
