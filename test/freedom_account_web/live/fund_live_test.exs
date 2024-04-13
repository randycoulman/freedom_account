defmodule FreedomAccountWeb.FundLiveTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory

  @invalid_attrs %{icon: nil, name: nil}

  describe "Index" do
    setup [:create_account]

    test "lists all funds", %{account: account, conn: conn} do
      fund = Factory.fund(account)

      conn
      |> visit(~p"/funds")
      # |> assert_has(page_title(), text: "Funds")
      |> assert_has(heading(), text: "Funds")
      |> assert_has(table_cell(), text: fund.icon)
      |> assert_has(table_cell(), text: fund.name)
    end

    test "shows prompt when list is empty", %{conn: conn} do
      conn
      |> visit(~p"/funds")
      |> assert_has(heading(), text: "Funds")
      |> assert_has("#no-funds", text: "This account has no funds yet. Use the Add Fund button to add one.")
    end

    test "saves new fund", %{conn: conn} do
      attrs = Factory.fund_attrs()

      conn
      |> visit(~p"/funds")
      |> click_link("Add Fund")
      # |> assert_path(~p"/funds/new")
      |> assert_has(page_title(), text: "Add Fund")
      |> assert_has(heading(), text: "Add Fund")
      |> fill_form("#fund-form", fund: @invalid_attrs)
      |> assert_has(field_error("#fund_icon"), text: "can't be blank")
      |> assert_has(field_error("#fund_name"), text: "can't be blank")
      |> fill_form("#fund-form", fund: attrs)
      |> click_button("Save Fund")
      |> assert_path(~p"/funds")
      |> assert_has(flash(:info), text: "Fund created successfully")
      |> assert_has(table_cell(), text: attrs[:icon])
      |> assert_has(table_cell(), text: attrs[:name])
    end

    test "edits fund in listing", %{account: account, conn: conn} do
      fund = Factory.fund(account)
      new_attrs = Factory.fund_attrs()

      conn
      |> visit(~p"/funds")
      |> click_link(action_link("#funds-#{fund.id}"), "Edit")
      # |> assert_path(~p"/funds/#{fund}/edit")
      |> assert_has(page_title(), text: "Edit Fund")
      |> assert_has(heading(), text: "Edit Fund")
      |> fill_form("#fund-form", fund: @invalid_attrs)
      |> assert_has(field_error("#fund_icon"), text: "can't be blank")
      |> assert_has(field_error("#fund_name"), text: "can't be blank")
      |> fill_form("#fund-form", fund: new_attrs)
      |> click_button("Save Fund")
      |> assert_path(~p"/funds")
      |> assert_has(flash(:info), text: "Fund updated successfully")
      |> assert_has(table_cell(), text: new_attrs[:icon])
      |> assert_has(table_cell(), text: new_attrs[:name])
    end

    test "deletes fund in listing", %{account: account, conn: conn} do
      fund = Factory.fund(account)

      conn
      |> visit(~p"/funds")
      |> click_link(action_link("#funds-#{fund.id}"), "Delete")
      |> refute_has("#funds-#{fund.id}")
    end
  end

  describe "Show" do
    setup [:create_account, :create_fund]

    test "drill down to individual fund and back", %{conn: conn, fund: fund} do
      conn
      |> visit(~p"/funds")
      |> click_link("td", fund.name)
      # |> assert_path(~p"/funds/#{fund}")
      # |> assert_has(page_title(), text: "#{fund.icon} #{fund.name}")
      |> assert_has(heading(), text: "#{fund.icon} #{fund.name}")
      |> click_link("Back to Funds")
      |> assert_path(~p"/funds")
      # |> assert_has(page_title(), text: "Funds")
      |> assert_has(heading(), text: "Funds")
    end

    test "displays fund", %{conn: conn, fund: fund} do
      conn
      |> visit(~p"/funds/#{fund}")
      |> assert_has(heading(), text: "#{fund.icon} #{fund.name}")
    end

    test "updates fund within modal", %{conn: conn, fund: fund} do
      updated_attrs = Factory.fund_attrs()

      conn
      |> visit(~p"/funds/#{fund}")
      |> click_link("Edit Details")
      # |> assert_path(~p"/funds/#{fund}/show/edit")
      |> assert_has(page_title(), text: "Edit Fund")
      |> assert_has(heading(), text: "Edit Fund")
      |> fill_form("#fund-form", fund: @invalid_attrs)
      |> assert_has(field_error("#fund_icon"), text: "can't be blank")
      |> assert_has(field_error("#fund_name"), text: "can't be blank")
      |> fill_form("#fund-form", fund: updated_attrs)
      |> click_button("Save Fund")
      |> assert_path(~p"/funds/#{fund}")
      |> assert_has(flash(:info), text: "Fund updated successfully")
      |> assert_has(page_title(), text: "#{updated_attrs[:icon]} #{updated_attrs[:name]}")
      |> assert_has(heading(), text: "#{updated_attrs[:icon]} #{updated_attrs[:name]}")
    end
  end

  defp create_account(_context) do
    %{account: Factory.account()}
  end

  defp create_fund(%{account: account}) do
    %{fund: Factory.fund(account)}
  end
end
