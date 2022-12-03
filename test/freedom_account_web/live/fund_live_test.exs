defmodule FreedomAccountWeb.FundLiveTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  # import FreedomAccount.FundsFixtures

  alias FreedomAccount.Factory

  # @create_attrs %{icon: "some icon", name: "some name"}
  # @update_attrs %{icon: "some updated icon", name: "some updated name"}
  # @invalid_attrs %{icon: nil, name: nil}

  defp create_account(_context) do
    account = Factory.account()

    %{account: account}
  end

  describe "Index" do
    setup [:create_account]

    test "lists all funds", %{account: account, conn: conn} do
      fund = Factory.fund(account)
      {:ok, _index_live, html} = live(conn, ~p"/")

      assert html =~ "Funds"
      assert html =~ fund.icon
      assert html =~ fund.name
    end

    test "shows prompt when list is empty", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/")

      assert html =~ "Funds"
      assert html =~ "no funds"
    end

    #   test "saves new fund", %{conn: conn} do
    #     {:ok, index_live, _html} = live(conn, ~p"/funds")

    #     assert index_live |> element("a", "New Fund") |> render_click() =~
    #              "New Fund"

    #     assert_patch(index_live, ~p"/funds/new")

    #     assert index_live
    #            |> form("#fund-form", fund: @invalid_attrs)
    #            |> render_change() =~ "can&#39;t be blank"

    #     {:ok, _, html} =
    #       index_live
    #       |> form("#fund-form", fund: @create_attrs)
    #       |> render_submit()
    #       |> follow_redirect(conn, ~p"/funds")

    #     assert html =~ "Fund created successfully"
    #     assert html =~ "some icon"
    #   end

    #   test "updates fund in listing", %{conn: conn, fund: fund} do
    #     {:ok, index_live, _html} = live(conn, ~p"/funds")

    #     assert index_live |> element("#funds-#{fund.id} a", "Edit") |> render_click() =~
    #              "Edit Fund"

    #     assert_patch(index_live, ~p"/funds/#{fund}/edit")

    #     assert index_live
    #            |> form("#fund-form", fund: @invalid_attrs)
    #            |> render_change() =~ "can&#39;t be blank"

    #     {:ok, _, html} =
    #       index_live
    #       |> form("#fund-form", fund: @update_attrs)
    #       |> render_submit()
    #       |> follow_redirect(conn, ~p"/funds")

    #     assert html =~ "Fund updated successfully"
    #     assert html =~ "some updated icon"
    #   end

    #   test "deletes fund in listing", %{conn: conn, fund: fund} do
    #     {:ok, index_live, _html} = live(conn, ~p"/funds")

    #     assert index_live |> element("#funds-#{fund.id} a", "Delete") |> render_click()
    #     refute has_element?(index_live, "#fund-#{fund.id}")
    #   end
  end

  # describe "Show" do
  #   setup [:create_fund]

  #   test "displays fund", %{conn: conn, fund: fund} do
  #     {:ok, _show_live, html} = live(conn, ~p"/funds/#{fund}")

  #     assert html =~ "Show Fund"
  #     assert html =~ fund.icon
  #   end

  #   test "updates fund within modal", %{conn: conn, fund: fund} do
  #     {:ok, show_live, _html} = live(conn, ~p"/funds/#{fund}")

  #     assert show_live |> element("a", "Edit") |> render_click() =~
  #              "Edit Fund"

  #     assert_patch(show_live, ~p"/funds/#{fund}/show/edit")

  #     assert show_live
  #            |> form("#fund-form", fund: @invalid_attrs)
  #            |> render_change() =~ "can&#39;t be blank"

  #     {:ok, _, html} =
  #       show_live
  #       |> form("#fund-form", fund: @update_attrs)
  #       |> render_submit()
  #       |> follow_redirect(conn, ~p"/funds/#{fund}")

  #     assert html =~ "Fund updated successfully"
  #     assert html =~ "some updated icon"
  #   end
  # end
end
