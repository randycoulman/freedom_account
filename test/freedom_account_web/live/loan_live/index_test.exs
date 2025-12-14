defmodule FreedomAccountWeb.LoanLive.IndexTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias FreedomAccount.Loans

  describe "listing all loans" do
    setup [:create_account]

    test "lists all loans", %{account: account, conn: conn} do
      loan = Factory.loan(account)
      Factory.lend(loan)
      {:ok, loan} = Loans.with_updated_balance(loan)

      conn
      |> visit(~p"/loans")
      |> assert_has(page_title(), text: "Loans")
      |> assert_has(active_tab(), text: "Loans")
      |> assert_has(loan_icon(loan), text: loan.icon)
      |> assert_has(loan_name(loan), text: loan.name)
      |> assert_has(loan_balance(loan), text: to_string(loan.current_balance))
    end

    test "shows prompt when list is empty", %{conn: conn} do
      conn
      |> visit(~p"/loans")
      |> assert_has(active_tab(), text: "Loans")
      |> assert_has("#no-loans", text: "This account has no active loans. Use the Add Loan button to add one.")
    end

    test "shows total loans balance", %{account: account, conn: conn} do
      loan = account |> Factory.loan() |> Factory.with_loan_balance()
      _fund = account |> Factory.fund() |> Factory.with_fund_balance()

      conn
      |> visit(~p"/loans")
      |> assert_has(active_tab(), text: "#{loan.current_balance}")
    end

    test "allows creating a new loan from the listing", %{conn: conn} do
      conn
      |> visit(~p"/loans")
      |> click_link("Add Loan")
      |> assert_path(~p"/loans/new")
      |> click_link("Cancel")
      |> assert_has(active_tab(), text: "Loans")
    end

    test "allows editing a loan in listing", %{account: account, conn: conn} do
      loan = account |> Factory.loan() |> Factory.with_loan_balance()

      conn
      |> visit(~p"/loans")
      |> click_link(action_link("#loans-#{loan.id}"), "Edit")
      |> assert_path(~p"/loans/#{loan}/edit")
      |> click_link("Cancel")
      |> assert_has(active_tab(), text: "Loans")
    end

    test "deletes loan in listing", %{account: account, conn: conn} do
      loan = Factory.loan(account)

      conn
      |> visit(~p"/loans")
      |> click_link(action_link("#loans-#{loan.id}"), "Delete")
      |> refute_has("#loans-#{loan.id}")
    end

    test "allows activating/deactivating loans from listing", %{account: account, conn: conn} do
      _loan = Factory.loan(account)

      conn
      |> visit(~p"/loans")
      |> click_link("Activate/Deactivate")
      |> assert_path(~p"/loans/activate")
      |> click_link("Cancel")
      |> assert_has(active_tab(), text: "Loans")
    end
  end
end
