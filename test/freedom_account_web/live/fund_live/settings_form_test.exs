defmodule FreedomAccountWeb.FundLive.SettingsFormTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory

  describe "creating a new fund" do
    setup [:create_account]

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
      |> assert_has(active_tab(), text: "Funds")
      |> refute_has(fund_name(), text: name)
    end
  end
end
