defmodule FreedomAccountWeb.FundLive.IndexTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias FreedomAccount.Funds

  describe "listing all funds" do
    setup [:create_account]

    test "lists all funds", %{account: account, conn: conn} do
      fund = Factory.fund(account)
      Factory.deposit(fund)
      {:ok, fund} = Funds.with_updated_balance(fund)

      conn
      |> visit(~p"/funds")
      |> assert_has(page_title(), text: "Funds")
      |> assert_has(active_tab(), text: "Funds")
      |> assert_has(fund_icon(fund), text: fund.icon)
      |> assert_has(fund_name(fund), text: fund.name)
      |> assert_has(fund_budget(fund), text: "#{fund.budget}")
      |> assert_has(fund_frequency(fund), text: "#{fund.times_per_year}")
      |> assert_has(fund_balance(fund), text: to_string(fund.current_balance))
    end

    test "shows prompt when list is empty", %{conn: conn} do
      conn
      |> visit(~p"/funds")
      |> assert_has(active_tab(), text: "Funds")
      |> assert_has("#no-funds", text: "This account has no funds yet. Use the Add Fund button to add one.")
    end

    test "shows total funds balance", %{account: account, conn: conn} do
      fund = account |> Factory.fund() |> Factory.with_fund_balance()
      _loan = account |> Factory.loan() |> Factory.with_loan_balance()

      conn
      |> visit(~p"/funds")
      |> assert_has(active_tab(), text: "#{fund.current_balance}")
    end

    test "allows creating a new fund", %{conn: conn} do
      conn
      |> visit(~p"/funds")
      |> click_link("Add Fund")
      |> assert_path(~p"/funds/new")
      |> click_link("Cancel")
      |> assert_has(active_tab(), text: "Funds")
    end

    test "edits fund in listing", %{account: account, conn: conn} do
      fund = account |> Factory.fund() |> Factory.with_fund_balance()
      %{budget: budget, icon: icon, name: name, times_per_year: times_per_year} = Factory.fund_attrs()

      conn
      |> visit(~p"/funds")
      |> click_link(fund_action(fund), "Edit")
      |> assert_has(page_title(), text: "Edit Fund")
      |> assert_has(heading(), text: "Edit Fund")
      |> fill_in("Icon", with: "")
      |> fill_in("Name", with: "")
      |> assert_has(field_error("#fund_icon"), text: "can't be blank")
      |> assert_has(field_error("#fund_name"), text: "can't be blank")
      |> fill_in("Icon", with: icon)
      |> fill_in("Name", with: name)
      |> fill_in("Budget", with: budget)
      |> fill_in("Times/Year", with: times_per_year)
      |> click_button("Save Fund")
      |> assert_has(flash(:info), text: "Fund updated successfully")
      |> assert_has(fund_icon(fund), text: icon)
      |> assert_has(fund_name(fund), text: name)
      |> assert_has(fund_budget(fund), text: "#{budget}")
      |> assert_has(fund_frequency(fund), text: "#{times_per_year}")
      |> assert_has(fund_balance(fund), text: "#{fund.current_balance}")
    end

    test "deletes fund in listing", %{account: account, conn: conn} do
      fund = Factory.fund(account)

      conn
      |> visit(~p"/funds")
      |> click_link(action_link("#funds-#{fund.id}"), "Delete")
      |> refute_has("#funds-#{fund.id}")
    end

    test "allows activating/deactivating funds from listing", %{account: account, conn: conn} do
      _fund = Factory.fund(account)

      conn
      |> visit(~p"/funds")
      |> click_link("Activate/Deactivate")
      |> assert_path(~p"/funds/activate")
      |> click_link("Cancel")
      |> assert_has(active_tab(), text: "Funds")
    end

    test "allows making a regular deposit from listing", %{conn: conn} do
      conn
      |> visit(~p"/funds")
      |> click_link("Regular Deposit")
      |> assert_path(~p"/funds/regular_deposit")
      |> click_link("Cancel")
      |> assert_has(active_tab(), text: "Funds")
    end

    test "allows making a regular withdrawal from listing", %{account: account, conn: conn} do
      _fund = Factory.fund(account)

      conn
      |> visit(~p"/funds")
      |> click_link("Regular Withdrawal")
      |> assert_path(~p"/funds/regular_withdrawal")
      |> click_link("Cancel")
      |> assert_has(active_tab(), text: "Funds")
    end

    test "allows updating budget from listing", %{account: account, conn: conn} do
      _fund = Factory.fund(account)

      conn
      |> visit(~p"/funds")
      |> click_link("Budget")
      |> assert_path(~p"/funds/budget")
      |> click_link("Cancel")
      |> assert_has(active_tab(), text: "Funds")
    end
  end
end
