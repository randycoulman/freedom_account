defmodule FreedomAccountWeb.AccountBarTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias Phoenix.HTML.Safe

  @moduletag capture_log: true

  describe "Show" do
    setup [:create_account]

    test "displays account", %{conn: conn, account: account} do
      conn
      |> visit(~p"/")
      |> assert_has(title(), text: "Freedom Account")
      |> assert_has(heading(), text: account.name)
    end

    test "updates account within modal on fund list view", %{conn: conn} do
      %{deposits_per_year: deposits, name: name} = Factory.account_attrs()

      conn
      |> visit(~p"/funds")
      |> click_link("Settings")
      |> assert_has(page_title(), text: "Edit Account Settings")
      |> assert_has(heading(), text: "Edit Account Settings")
      |> fill_in("Name", with: "")
      |> fill_in("Deposits / year", with: "")
      |> assert_has(field_error("#account_name"), text: "can't be blank")
      |> assert_has(field_error("#account_deposits_per_year"), text: "can't be blank")
      |> fill_in("Name", with: name)
      |> fill_in("Deposits / year", with: deposits)
      |> click_button("Save Account")
      |> assert_has(flash(:info), text: "Account updated successfully")
      |> assert_has(page_title(), text: "Funds")
      |> assert_has(heading(), text: name)
      |> assert_has(active_tab(), text: "Funds")
    end

    test "updates account within modal on loan list view", %{conn: conn} do
      %{deposits_per_year: deposits, name: name} = Factory.account_attrs()

      conn
      |> visit(~p"/loans")
      |> click_link("Settings")
      |> assert_has(page_title(), text: "Edit Account Settings")
      |> assert_has(heading(), text: "Edit Account Settings")
      |> fill_in("Name", with: "")
      |> fill_in("Deposits / year", with: "")
      |> assert_has(field_error("#account_name"), text: "can't be blank")
      |> assert_has(field_error("#account_deposits_per_year"), text: "can't be blank")
      |> fill_in("Name", with: name)
      |> fill_in("Deposits / year", with: deposits)
      |> click_button("Save Account")
      |> assert_has(flash(:info), text: "Account updated successfully")
      |> assert_has(page_title(), text: "Loans")
      |> assert_has(heading(), text: name)
      |> assert_has(active_tab(), text: "Loans")
    end

    test "updates account within modal on transaction list view", %{conn: conn} do
      %{deposits_per_year: deposits, name: name} = Factory.account_attrs()

      conn
      |> visit(~p"/transactions")
      |> click_link("Settings")
      |> assert_has(page_title(), text: "Edit Account Settings")
      |> assert_has(heading(), text: "Edit Account Settings")
      |> fill_in("Name", with: "")
      |> fill_in("Deposits / year", with: "")
      |> assert_has(field_error("#account_name"), text: "can't be blank")
      |> assert_has(field_error("#account_deposits_per_year"), text: "can't be blank")
      |> fill_in("Name", with: name)
      |> fill_in("Deposits / year", with: deposits)
      |> click_button("Save Account")
      |> assert_has(flash(:info), text: "Account updated successfully")
      |> assert_has(page_title(), text: "Transactions")
      |> assert_has(heading(), text: name)
      |> assert_has(active_tab(), text: "Transactions")
    end

    test "selects default fund", %{account: account, conn: conn} do
      funds = for _i <- 1..5, do: Factory.fund(account)
      default_fund = Enum.random(funds)

      conn
      |> visit(~p"/funds/account")
      |> select("Default fund", option: Safe.to_iodata(default_fund))
      |> click_button("Save Account")
      |> assert_has(flash(:info), text: "Account updated successfully")
      |> click_link("Settings")
      |> assert_has(heading(), text: "Edit Account Settings")
      |> assert_has(selected_option("#default-fund"), text: Safe.to_iodata(default_fund))
    end
  end
end
