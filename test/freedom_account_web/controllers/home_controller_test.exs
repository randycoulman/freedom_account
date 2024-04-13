defmodule FreedomAccountWeb.HomeControllerTest do
  use FreedomAccountWeb.ConnCase, async: true

  test "redirects to fund list page", %{conn: conn} do
    conn
    |> visit(~p"/")
    |> assert_path(~p"/funds")

    # |> assert_has(page_title(), "Funds")
  end
end
