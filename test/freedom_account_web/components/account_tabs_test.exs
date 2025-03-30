defmodule FreedomAccountWeb.AccountTabsTest do
  @moduledoc false
  use FreedomAccountWeb.ConnCase, async: true

  setup :create_account

  describe "switching tabs" do
    test "only funds tab is active on fund list page", %{conn: conn} do
      conn
      |> visit(~p"/funds")
      |> assert_has(active_tab(), text: "Funds")
      |> assert_has(inactive_tab(), text: "Loans")
      |> assert_has(inactive_tab(), text: "Transactions")
    end

    test "only loans tab is active on loan list page", %{conn: conn} do
      conn
      |> visit(~p"/loans")
      |> assert_has(active_tab(), text: "Loans")
      |> assert_has(inactive_tab(), text: "Funds")
      |> assert_has(inactive_tab(), text: "Transactions")
    end

    test "only transactions tab is active on transaction list page", %{conn: conn} do
      conn
      |> visit(~p"/transactions")
      |> assert_has(active_tab(), text: "Transactions")
      |> assert_has(inactive_tab(), text: "Funds")
      |> assert_has(inactive_tab(), text: "Loans")
    end

    test "shows balances on funds and loans tabs", %{conn: conn} do
      conn
      |> visit(~p"/")
      |> assert_has(active_tab(), text: "$0.00")
      |> assert_has(inactive_tab(), text: "$0.00")
    end

    test "can switch tabs", %{conn: conn} do
      conn
      |> visit(~p"/funds")
      |> click_link("Loans")
      |> assert_has(active_tab(), text: "Loans")
      |> assert_has(inactive_tab(), text: "Funds")
      |> assert_has(inactive_tab(), text: "Transactions")
      |> click_link("Transactions")
      |> assert_has(active_tab(), text: "Transactions")
      |> assert_has(inactive_tab(), text: "Funds")
      |> assert_has(inactive_tab(), text: "Loans")
      |> click_link("Funds")
      |> assert_has(active_tab(), text: "Funds")
      |> assert_has(inactive_tab(), text: "Loans")
      |> assert_has(inactive_tab(), text: "Transactions")
    end
  end
end
