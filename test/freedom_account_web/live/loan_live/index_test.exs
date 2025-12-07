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

    test "saves new loan", %{conn: conn} do
      %{icon: icon, name: name} = Factory.loan_attrs()

      conn
      |> visit(~p"/loans")
      |> click_link("Add Loan")
      |> assert_path(~p"/loans/new")
      |> assert_has(page_title(), text: "Add Loan")
      |> assert_has(heading(), text: "Add Loan")
      |> fill_in("Icon", with: "")
      |> fill_in("Name", with: "")
      |> assert_has(field_error("#loan_icon"), text: "can't be blank")
      |> assert_has(field_error("#loan_name"), text: "can't be blank")
      |> fill_in("Icon", with: icon)
      |> fill_in("Name", with: name)
      |> click_button("Save Loan")
      |> assert_has(flash(:info), text: "Loan created successfully")
      |> assert_has(loan_icon(), text: icon)
      |> assert_has(loan_name(), text: name)
      |> assert_has(loan_balance(), text: "$0.00")
    end

    test "edits loan in listing", %{account: account, conn: conn} do
      loan = account |> Factory.loan() |> Factory.with_loan_balance()
      %{icon: icon, name: name} = Factory.loan_attrs()

      conn
      |> visit(~p"/loans")
      |> click_link(action_link("#loans-#{loan.id}"), "Edit")
      |> assert_has(page_title(), text: "Edit Loan")
      |> assert_has(heading(), text: "Edit Loan")
      |> fill_in("Icon", with: "")
      |> fill_in("Name", with: "")
      |> assert_has(field_error("#loan_icon"), text: "can't be blank")
      |> assert_has(field_error("#loan_name"), text: "can't be blank")
      |> fill_in("Icon", with: icon)
      |> fill_in("Name", with: name)
      |> click_button("Save Loan")
      |> assert_has(flash(:info), text: "Loan updated successfully")
      |> assert_has(loan_icon(loan), text: icon)
      |> assert_has(loan_name(loan), text: name)
      |> assert_has(loan_balance(loan), text: "#{loan.current_balance}")
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
