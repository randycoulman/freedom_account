defmodule FreedomAccountWeb.AccountLiveTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase

  import Phoenix.LiveViewTest

  alias FreedomAccount.Factory

  # @create_attrs %{deposits_per_year: 42, name: "some name"}
  # @update_attrs %{deposits_per_year: 43, name: "some updated name"}
  # @invalid_attrs %{deposits_per_year: nil, name: nil}

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

    # test "updates account within modal", %{conn: conn, account: account} do
    #   {:ok, show_live, _html} = live(conn, ~p"/accounts/#{account}")

    #   assert show_live |> element("a", "Edit") |> render_click() =~
    #            "Edit Account"

    #   assert_patch(show_live, ~p"/accounts/#{account}/show/edit")

    #   assert show_live
    #          |> form("#account-form", account: @invalid_attrs)
    #          |> render_change() =~ "can&#39;t be blank"

    #   {:ok, _, html} =
    #     show_live
    #     |> form("#account-form", account: @update_attrs)
    #     |> render_submit()
    #     |> follow_redirect(conn, ~p"/accounts/#{account}")

    #   assert html =~ "Account updated successfully"
    #   assert html =~ "some updated name"
    # end
  end
end
