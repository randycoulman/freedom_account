defmodule FreedomAccountWeb.FundLive.FormTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias Phoenix.HTML.Safe

  setup [:create_account]

  describe "creating a new fund" do
    test "saves new fund", %{conn: conn} do
      %{budget: budget, icon: icon, name: name, times_per_year: times_per_year} = Factory.fund_attrs()

      conn
      |> visit(~p"/funds/new")
      |> assert_has(page_title(), text: "Add Fund")
      |> assert_has(heading(), text: "Add Fund")
      |> fill_in("Icon", with: "")
      |> fill_in("Name", with: "")
      |> assert_has(field_error("#fund_icon"), text: "can't be blank")
      |> assert_has(field_error("#fund_name"), text: "can't be blank")
      |> fill_in("Icon", with: icon)
      |> fill_in("Name", with: name)
      |> fill_in("Budget", with: budget)
      |> fill_in("Times/Year", with: times_per_year)
      |> click_button("Save Fund")
      |> assert_has(flash(:info), text: "Fund created successfully")
      |> assert_has(fund_icon(), text: icon)
      |> assert_has(fund_name(), text: name)
      |> assert_has(fund_budget(), text: "#{budget}")
      |> assert_has(fund_frequency(), text: "#{times_per_year}")
      |> assert_has(fund_balance(), text: "$0.00")
    end

    test "does not create fund on cancel", %{conn: conn} do
      %{budget: budget, icon: icon, name: name, times_per_year: times_per_year} = Factory.fund_attrs()

      conn
      |> visit(~p"/funds/new")
      |> fill_in("Icon", with: icon)
      |> fill_in("Name", with: name)
      |> fill_in("Budget", with: budget)
      |> fill_in("Times/Year", with: times_per_year)
      |> click_link("Cancel")
      |> refute_has(fund_name(), text: name)
    end
  end

  describe "editing a fund" do
    test "updates fund settings", %{account: account, conn: conn} do
      fund = account |> Factory.fund() |> Factory.with_fund_balance()
      %{budget: budget, icon: icon, name: name, times_per_year: times_per_year} = Factory.fund_attrs()

      conn
      |> visit(~p"/funds/#{fund}/edit")
      |> assert_has(page_title(), text: "Edit Fund")
      |> assert_has(heading(), text: "Edit Fund")
      |> fill_in("Icon", with: "")
      |> fill_in("Name", with: "")
      |> assert_has(field_error("#fund_icon"), text: "can't be blank")
      |> assert_has(field_error("#fund_name"), text: "can't be blank")
      |> fill_in("Icon", with: icon)
      |> fill_in("Name", with: name)
      |> fill_in("Budget", with: budget)
      |> fill_in("Times/Year", with: times_per_year)
      |> click_button("Save Fund")
      |> assert_has(flash(:info), text: "Fund updated successfully")
      |> assert_has(fund_icon(fund), text: icon)
      |> assert_has(fund_name(fund), text: name)
      |> assert_has(fund_budget(fund), text: "#{budget}")
      |> assert_has(fund_frequency(fund), text: "#{times_per_year}")
      |> assert_has(fund_balance(fund), text: "#{fund.current_balance}")
    end

    test "does not update fund on cancel", %{account: account, conn: conn} do
      fund = account |> Factory.fund() |> Factory.with_fund_balance()
      %{budget: budget, icon: icon, name: name, times_per_year: times_per_year} = Factory.fund_attrs()

      conn
      |> visit(~p"/funds/#{fund}/edit")
      |> fill_in("Icon", with: icon)
      |> fill_in("Name", with: name)
      |> fill_in("Budget", with: budget)
      |> fill_in("Times/Year", with: times_per_year)
      |> click_link("Cancel")
      |> assert_has(fund_icon(fund), text: fund.icon)
      |> assert_has(fund_name(fund), text: fund.name)
      |> assert_has(fund_budget(fund), text: "#{fund.budget}")
      |> assert_has(fund_frequency(fund), text: "#{fund.times_per_year}")
      |> assert_has(fund_balance(fund), text: "#{fund.current_balance}")
    end
  end

  describe "returning to calling view" do
    setup :create_fund

    test "returns to fund list by default on save", %{conn: conn, fund: fund} do
      conn
      |> visit(~p"/funds/#{fund}/edit")
      |> click_button("Save Fund")
      |> assert_has(active_tab(), text: "Funds")
    end

    test "returns to fund list by default on cancel", %{conn: conn, fund: fund} do
      conn
      |> visit(~p"/funds/#{fund}/edit")
      |> click_link("Cancel")
      |> assert_has(active_tab(), text: "Funds")
    end

    test "returns to fund list when specified on save", %{conn: conn, fund: fund} do
      conn
      |> visit(~p"/funds/#{fund}/edit?return_to=index")
      |> click_button("Save Fund")
      |> assert_has(active_tab(), text: "Funds")
    end

    test "returns to fund list when specified on cancel", %{conn: conn, fund: fund} do
      conn
      |> visit(~p"/funds/#{fund}/edit?return_to=index")
      |> click_link("Cancel")
      |> assert_has(active_tab(), text: "Funds")
    end

    test "returns to individual fund view when specified on save", %{conn: conn, fund: fund} do
      conn
      |> visit(~p"/funds/#{fund}/edit?return_to=show")
      |> click_button("Save Fund")
      |> assert_has(heading(), text: Safe.to_iodata(fund))
    end

    test "returns to individual fund view when specified on cancel", %{conn: conn, fund: fund} do
      conn
      |> visit(~p"/funds/#{fund}/edit?return_to=show")
      |> click_link("Cancel")
      |> assert_has(heading(), text: Safe.to_iodata(fund))
    end
  end
end
