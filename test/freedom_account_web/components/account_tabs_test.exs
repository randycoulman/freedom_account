defmodule FreedomAccountWeb.AccountTabsTest do
  @moduledoc false
  use FreedomAccountWeb.ConnCase, async: true

  describe "switching tabs" do
    test "only funds tab is active on fund list page", %{conn: conn} do
      conn
      |> visit(~p"/funds")
      |> assert_has(active_tab(), text: "Funds")
      |> assert_has(inactive_tab(), text: "Loans")
    end

    test "only loans tab is active on loan list page", %{conn: conn} do
      conn
      |> visit(~p"/loans")
      |> assert_has(active_tab(), text: "Loans")
      |> assert_has(inactive_tab(), text: "Funds")
    end

    test "can switch tabs", %{conn: conn} do
      conn
      |> visit(~p"/funds")
      |> click_link("Loans")
      |> assert_has(active_tab(), text: "Loans")
      |> assert_has(inactive_tab(), text: "Funds")
      |> click_link("Funds")
      |> assert_has(active_tab(), text: "Funds")
      |> assert_has(inactive_tab(), text: "Loans")
    end
  end
end
