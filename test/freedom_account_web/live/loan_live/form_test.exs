defmodule FreedomAccountWeb.LoanLive.FormTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias FreedomAccount.MoneyUtils
  alias Phoenix.HTML.Safe

  setup [:create_account]

  describe "creating a new loan" do
    test "saves new loan", %{conn: conn} do
      %{icon: icon, name: name} = Factory.loan_attrs()

      conn
      |> visit(~p"/loans/new")
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

    test "does not create loan on cancel", %{conn: conn} do
      %{icon: icon, name: name} = Factory.loan_attrs()

      conn
      |> visit(~p"/loans/new")
      |> fill_in("Icon", with: icon)
      |> fill_in("Name", with: name)
      |> click_link("Cancel")
      |> refute_has(loan_name(), text: name)
    end
  end

  describe "editing a loan" do
    test "updates loan settings", %{account: account, conn: conn} do
      loan = account |> Factory.loan() |> Factory.with_loan_balance()
      %{icon: icon, name: name} = Factory.loan_attrs()

      conn
      |> visit(~p"/loans/#{loan}/edit")
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
      |> assert_has(loan_balance(loan), text: MoneyUtils.format(loan.current_balance))
    end

    test "does not update loan settings on cancel", %{account: account, conn: conn} do
      loan = account |> Factory.loan() |> Factory.with_loan_balance()
      %{icon: icon, name: name} = Factory.loan_attrs()

      conn
      |> visit(~p"/loans/#{loan}/edit")
      |> fill_in("Icon", with: icon)
      |> fill_in("Name", with: name)
      |> click_link("Cancel")
      |> assert_has(loan_icon(loan), text: loan.icon)
      |> assert_has(loan_name(loan), text: loan.name)
      |> assert_has(loan_balance(loan), text: MoneyUtils.format(loan.current_balance))
    end
  end

  describe "returning to calling view" do
    setup :create_loan

    test "returns to loan list by default on save", %{conn: conn, loan: loan} do
      conn
      |> visit(~p"/loans/#{loan}/edit")
      |> click_button("Save Loan")
      |> assert_has(active_tab(), text: "Loans")
    end

    test "returns to loan list by default on cancel", %{conn: conn, loan: loan} do
      conn
      |> visit(~p"/loans/#{loan}/edit")
      |> click_link("Cancel")
      |> assert_has(active_tab(), text: "Loans")
    end

    test "returns to loan list when specified on save", %{conn: conn, loan: loan} do
      conn
      |> visit(~p"/loans/#{loan}/edit?return_to=index")
      |> click_button("Save Loan")
      |> assert_has(active_tab(), text: "Loans")
    end

    test "returns to loan list when specified on cancel", %{conn: conn, loan: loan} do
      conn
      |> visit(~p"/loans/#{loan}/edit?return_to=index")
      |> click_link("Cancel")
      |> assert_has(active_tab(), text: "Loans")
    end

    test "returns to individual loan view when specified on save", %{conn: conn, loan: loan} do
      conn
      |> visit(~p"/loans/#{loan}/edit?return_to=show")
      |> click_button("Save Loan")
      |> assert_has(heading(), text: Safe.to_iodata(loan))
    end

    test "returns to individual loan view when specified on cancel", %{conn: conn, loan: loan} do
      conn
      |> visit(~p"/loans/#{loan}/edit?return_to=show")
      |> click_link("Cancel")
      |> assert_has(heading(), text: Safe.to_iodata(loan))
    end
  end
end
