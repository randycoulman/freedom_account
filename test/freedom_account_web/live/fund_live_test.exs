defmodule FreedomAccountWeb.FundLiveTest do
  @moduledoc false

  use FreedomAccountWeb.FeatureCase, async: true

  alias FreedomAccount.Factory

  @invalid_attrs %{icon: nil, name: nil}

  defp create_account(_context) do
    %{account: Factory.account()}
  end

  describe "Index" do
    setup [:create_account]

    test "lists all funds", %{account: account, conn: conn} do
      fund = Factory.fund(account)

      conn
      |> visit(~p"/")
      |> assert_has("h2", text: "Funds")
      |> assert_has("span", text: fund.icon)
      |> assert_has("span", text: escaped(fund.name))
    end

    test "shows prompt when list is empty", %{conn: conn} do
      conn
      |> visit(~p"/")
      |> assert_has("h2", text: "Funds")
      |> assert_has("#no-funds", text: "This account has no funds yet. Use the Add Fund button to add one.")
    end

    test "saves new fund", %{conn: conn} do
      attrs = Factory.fund_attrs()

      conn
      |> visit(~p"/")
      |> click_link("Add Fund")
      |> assert_has("h2", text: "Add Fund")
      |> fill_form("#fund-form", fund: @invalid_attrs)
      |> assert_has("p", text: "can't be blank")
      |> fill_form("#fund-form", fund: attrs)
      |> click_button("Save Fund")
      |> assert_has("p", text: "Fund created successfully")
      |> assert_has("span", text: attrs[:icon])
      |> assert_has("span", text: escaped(attrs[:name]))
    end

    #   test "updates fund in listing", %{conn: conn, fund: fund} do
    #     {:ok, index_live, _html} = live(conn, ~p"/funds")

    #     assert index_live |> element("#funds-#{fund.id} a", "Edit") |> render_click() =~
    #              "Edit Fund"

    #     assert_patch(index_live, ~p"/funds/#{fund}/edit")

    #     assert index_live
    #            |> form("#fund-form", fund: @invalid_attrs)
    #            |> render_change() =~ "can&#39;t be blank"

    #     assert index_live
    #           |> form("#fund-form", fund: @update_attrs)
    #           |> render_submit()

    #     assert_patch(index_live, ~p"/funds")

    #     html = render(index_live)
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

  #     assert show_live
  #           |> form("#fund-form", fund: @update_attrs)
  #           |> render_submit()

  #     assert_patch(show_live, ~p"/funds")

  #     html = render(show_live)
  #     assert html =~ "Fund updated successfully"
  #     assert html =~ "some updated icon"
  #   end
  # end
end
