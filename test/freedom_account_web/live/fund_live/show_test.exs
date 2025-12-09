defmodule FreedomAccountWeb.FundLive.ShowTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  import Money.Sigil

  alias FreedomAccount.Factory
  alias FreedomAccount.Funds
  alias Phoenix.HTML.Safe

  describe "viewing an individual fund" do
    setup [:create_account, :create_fund]

    test "drills down to individual fund and back", %{account: account, conn: conn, fund: fund} do
      per_deposit = Funds.regular_deposit_amount(fund, account)

      conn
      |> visit(~p"/funds")
      |> click_link(fund_card(fund), fund.name)
      |> assert_has(page_title(), text: Safe.to_iodata(fund))
      |> assert_has(heading(), text: Safe.to_iodata(fund))
      |> assert_has(heading(), text: "$0.00")
      |> assert_has(fund_subtitle(), text: "#{fund.budget}")
      |> assert_has(fund_subtitle(), text: "#{fund.times_per_year}")
      |> assert_has(fund_subtitle(), text: "#{per_deposit}")
      |> click_link("Back to Funds")
      |> assert_has(page_title(), text: "Funds")
      |> assert_has(active_tab(), text: "Funds")
    end

    test "displays fund", %{conn: conn, fund: fund} do
      conn
      |> visit(~p"/funds/#{fund}")
      |> assert_has(heading(), text: Safe.to_iodata(fund))
    end

    test "updates fund within modal", %{conn: conn, fund: fund} do
      %{icon: icon, name: name} = Factory.fund_attrs()
      Factory.deposit(fund)
      {:ok, fund} = Funds.with_updated_balance(fund)

      conn
      |> visit(~p"/funds/#{fund}")
      |> click_link("Edit Details")
      |> assert_has(page_title(), text: "Edit Fund")
      |> assert_has(heading(), text: "Edit Fund")
      |> fill_in("Icon", with: "")
      |> fill_in("Name", with: "")
      |> assert_has(field_error("#fund_icon"), text: "can't be blank")
      |> assert_has(field_error("#fund_name"), text: "can't be blank")
      |> fill_in("Icon", with: icon)
      |> fill_in("Name", with: name)
      |> click_button("Save Fund")
      |> assert_has(flash(:info), text: "Fund updated successfully")
      |> assert_has(page_title(), text: "#{icon} #{name}")
      |> assert_has(heading(), text: "#{icon} #{name}")
      |> assert_has(heading(), text: "#{fund.current_balance}")
      |> assert_has(sidebar_fund_name(), text: "#{icon} #{name}")
      |> assert_has(sidebar_fund_balance(), text: "#{fund.current_balance}")
    end

    test "allows depositing money to a fund", %{conn: conn, fund: fund} do
      conn
      |> visit(~p"/funds/#{fund}")
      |> click_link("Deposit")
      |> assert_path(~p"/funds/#{fund}/deposits/new")
      |> click_link("Cancel")
      |> assert_has(heading(), text: Safe.to_iodata(fund))
    end

    test "allows withdrawing money from a fund", %{conn: conn, fund: fund} do
      Factory.deposit(fund, amount: ~M[5000]usd)

      conn
      |> visit(~p"/funds/#{fund}")
      |> click_link("Withdraw")
      |> refute_has(flash(:error))
      |> assert_path(~p"/funds/#{fund}/withdrawals/new")
      |> click_link("Cancel")
      |> assert_has(heading(), text: Safe.to_iodata(fund))
    end
  end
end
