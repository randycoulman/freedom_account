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

    test "allows editing fund", %{conn: conn, fund: fund} do
      conn
      |> visit(~p"/funds/#{fund}")
      |> click_link("Edit Details")
      |> assert_path(~p"/funds/#{fund}/edit")
      |> click_link("Cancel")
      |> assert_has(heading(), text: Safe.to_iodata(fund))
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
