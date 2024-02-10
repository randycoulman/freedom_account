defmodule FreedomAccountWeb.AccountLiveTest do
  @moduledoc false

  use FreedomAccountWeb.FeatureCase, async: true

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
      |> assert_has("h1", "Freedom Account")
      |> assert_has("h2", escaped(account.name))
    end

    test "updates account within modal", %{conn: conn} do
      update_attrs = Factory.account_attrs()

      conn
      |> visit(~p"/")
      |> click_link("Edit")
      |> assert_has("h2", "Settings")
      |> fill_form("#account-form", account: @invalid_attrs)
      |> assert_has("p", "can't be blank")
      |> fill_form("#account-form", account: update_attrs)
      |> click_button("Save Account")
      |> assert_has("p", "Account updated successfully")
      |> assert_has("h2", escaped(update_attrs[:name]))
    end
  end
end
