defmodule FreedomAccountWeb.AccountBarTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  @moduletag capture_log: true

  describe "Show" do
    setup [:create_account]

    test "displays account", %{conn: conn, account: account} do
      conn
      |> visit(~p"/")
      |> assert_has(title(), text: "Freedom Account")
      |> assert_has(heading(), text: account.name)
    end

    test "updates account from fund list view", %{conn: conn} do
      conn
      |> visit(~p"/funds")
      |> click_link("Settings")
      |> assert_path(~p"/account/edit")
      |> assert_has(heading(), text: "Edit Account Settings")
      |> click_button("Save Account")
      |> assert_has(page_title(), text: "Funds")
    end

    test "updates account from loan list view", %{conn: conn} do
      conn
      |> visit(~p"/loans")
      |> click_link("Settings")
      |> assert_path(~p"/account/edit")
      |> assert_has(heading(), text: "Edit Account Settings")
      |> click_button("Save Account")
      |> assert_has(page_title(), text: "Loans")
    end

    test "updates account from transaction list view", %{conn: conn} do
      conn
      |> visit(~p"/transactions")
      |> click_link("Settings")
      |> assert_path(~p"/account/edit")
      |> assert_has(heading(), text: "Edit Account Settings")
      |> click_button("Save Account")
      |> assert_has(page_title(), text: "Transactions")
    end
  end
end
