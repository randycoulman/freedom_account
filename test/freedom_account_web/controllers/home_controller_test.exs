defmodule FreedomAccountWeb.HomeControllerTest do
  use FreedomAccountWeb.FeatureCase, async: true

  test "redirects to fund list page", %{conn: conn} do
    conn
    |> visit(~p"/")
    |> assert_path(~p"/funds")
  end
end
