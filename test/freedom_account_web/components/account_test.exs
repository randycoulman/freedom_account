defmodule FreedomAccountWeb.AccountTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory

  defp create_account(_context) do
    %{account: Factory.account()}
  end

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
      |> visit(~p"/")
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
      |> assert_has(heading(), text: "Funds")
    end

    test "updates account within modal on fund detail view", %{account: account, conn: conn} do
      fund = Factory.fund(account)
      %{deposits_per_year: deposits, name: name} = Factory.account_attrs()

      conn
      |> visit(~p"/funds/#{fund}")
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
      |> assert_has(page_title(), text: fund.name)
      |> assert_has(heading(), text: name)
      |> assert_has(heading(), text: fund.name)
    end
  end
end
