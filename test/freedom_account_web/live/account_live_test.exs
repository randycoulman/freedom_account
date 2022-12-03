defmodule FreedomAccountWeb.AccountLiveTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase

  import Phoenix.LiveViewTest

  alias FreedomAccount.Factory

  @invalid_attrs %{deposits_per_year: nil, name: nil}

  defp create_account(_context) do
    account = Factory.account()
    %{account: account}
  end

  describe "Show" do
    setup [:create_account]

    test "displays account", %{conn: conn, account: account} do
      {:ok, _show_live, html} = live(conn, ~p"/")

      assert html =~ "Freedom Account"
      assert html =~ account.name
    end

    test "updates account within modal", %{conn: conn} do
      updated_deposits = Factory.deposit_count()
      updated_name = Factory.account_name()
      update_attrs = %{deposits_per_year: updated_deposits, name: updated_name}

      {:ok, show_live, _html} = live(conn, ~p"/")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Account Settings"

      assert_patch(show_live, ~p"/edit")

      assert show_live
             |> form("#account-form", account: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _live, html} =
        show_live
        |> form("#account-form", account: update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert html =~ "Account updated successfully"
      assert html =~ updated_name
    end
  end
end
