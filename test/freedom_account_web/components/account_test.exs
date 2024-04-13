defmodule FreedomAccountWeb.AccountTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory

  @invalid_attrs %{deposits_per_year: nil, name: nil}

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
      update_attrs = Factory.account_attrs()

      conn
      |> visit(~p"/")
      |> click_link("Settings")
      |> assert_has(heading(), text: "Edit Account Settings")
      |> fill_form("#account-form", account: @invalid_attrs)
      |> assert_has(field_error("#account_name"), text: "can't be blank")
      |> assert_has(field_error("#account_deposits_per_year"), text: "can't be blank")
      |> fill_form("#account-form", account: update_attrs)
      |> click_button("Save Account")
      |> assert_has(flash(:info), text: "Account updated successfully")
      |> assert_has(heading(), text: update_attrs[:name])
      |> assert_has(heading(), text: "Funds")
    end

    test "updates account within modal on fund detail view", %{account: account, conn: conn} do
      fund = Factory.fund(account)
      update_attrs = Factory.account_attrs()

      conn
      |> visit(~p"/funds/#{fund}")
      |> click_link("Settings")
      |> assert_has(heading(), text: "Edit Account Settings")
      |> fill_form("#account-form", account: @invalid_attrs)
      |> assert_has(field_error("#account_name"), text: "can't be blank")
      |> assert_has(field_error("#account_deposits_per_year"), text: "can't be blank")
      |> fill_form("#account-form", account: update_attrs)
      |> click_button("Save Account")
      |> assert_has(flash(:info), text: "Account updated successfully")
      |> assert_has(heading(), text: update_attrs[:name])
      |> assert_has(heading(), text: fund.name)
    end
  end
end
