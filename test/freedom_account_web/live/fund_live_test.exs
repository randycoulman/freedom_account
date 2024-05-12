defmodule FreedomAccountWeb.FundLiveTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  import Money.Sigil

  alias FreedomAccount.Factory
  alias Phoenix.HTML.Safe

  describe "Index" do
    setup [:create_account]

    test "lists all funds", %{account: account, conn: conn} do
      fund = Factory.fund(account)

      conn
      |> visit(~p"/funds")
      |> assert_has(page_title(), text: "Funds")
      |> assert_has(heading(), text: "Funds")
      |> assert_has(table_cell(), text: fund.icon)
      |> assert_has(table_cell(), text: fund.name)
      |> assert_has(table_cell(), text: "$0.00")
    end

    test "shows prompt when list is empty", %{conn: conn} do
      conn
      |> visit(~p"/funds")
      |> assert_has(heading(), text: "Funds")
      |> assert_has("#no-funds", text: "This account has no funds yet. Use the Add Fund button to add one.")
    end

    test "saves new fund", %{conn: conn} do
      %{icon: icon, name: name} = Factory.fund_attrs()

      conn
      |> visit(~p"/funds")
      |> click_link("Add Fund")
      |> assert_path(~p"/funds/new")
      |> assert_has(page_title(), text: "Add Fund")
      |> assert_has(heading(), text: "Add Fund")
      |> fill_in("Icon", with: "")
      |> fill_in("Name", with: "")
      |> assert_has(field_error("#fund_icon"), text: "can't be blank")
      |> assert_has(field_error("#fund_name"), text: "can't be blank")
      |> fill_in("Icon", with: icon)
      |> fill_in("Name", with: name)
      |> click_button("Save Fund")
      |> assert_has(flash(:info), text: "Fund created successfully")
      |> assert_has(table_cell(), text: icon)
      |> assert_has(table_cell(), text: name)
    end

    test "edits fund in listing", %{account: account, conn: conn} do
      fund = Factory.fund(account)
      %{icon: icon, name: name} = Factory.fund_attrs()

      conn
      |> visit(~p"/funds")
      |> click_link(action_link("#funds-#{fund.id}"), "Edit")
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
      |> assert_has(table_cell(), text: icon)
      |> assert_has(table_cell(), text: name)
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

    test "drills down to individual fund and back", %{conn: conn, fund: fund} do
      conn
      |> visit(~p"/funds")
      |> click_link("td", fund.name)
      |> assert_has(page_title(), text: Safe.to_iodata(fund))
      |> assert_has(heading(), text: Safe.to_iodata(fund))
      |> assert_has(heading(), text: "$0.00")
      |> click_link("Back to Funds")
      |> assert_has(page_title(), text: "Funds")
      |> assert_has(heading(), text: "Funds")
    end

    test "displays fund", %{conn: conn, fund: fund} do
      conn
      |> visit(~p"/funds/#{fund}")
      |> assert_has(heading(), text: Safe.to_iodata(fund))
    end

    test "updates fund within modal", %{conn: conn, fund: fund} do
      %{icon: icon, name: name} = Factory.fund_attrs()

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
      |> assert_has(sidebar_fund_name(), text: "#{icon} #{name}")
    end

    test "deposits money to a fund", %{conn: conn, fund: fund} do
      today = Timex.today(:local)
      amount = Factory.money()

      conn
      |> visit(~p"/funds/#{fund}")
      |> click_link("Deposit")
      |> assert_has(page_title(), text: "Deposit")
      |> assert_has(heading(), text: "Deposit")
      |> assert_has(field_value("#transaction_date", today))
      |> fill_in("Date", with: Factory.date())
      |> fill_in("Memo", with: Factory.memo())
      |> fill_in("Amount", with: amount)
      |> click_button("Make Deposit")
      |> assert_has(flash(:info), text: "Deposit successful")
      |> assert_has(heading(), text: Safe.to_iodata(fund))
      |> assert_has(heading(), text: "#{amount}")
      |> assert_has(sidebar_fund_balance(), text: "#{amount}")
    end

    test "withdraws money from a fund", %{conn: conn, fund: fund} do
      today = Timex.today(:local)
      deposit_amount = ~M[5000]usd
      amount = Factory.money()
      balance = Money.sub!(deposit_amount, amount)

      Factory.deposit(fund, amount: deposit_amount)

      conn
      |> visit(~p"/funds/#{fund}")
      |> click_link("Withdraw")
      |> assert_has(page_title(), text: "Withdraw")
      |> assert_has(heading(), text: "Withdraw")
      |> assert_has(field_value("#transaction_date", today))
      |> fill_in("Date", with: Factory.date())
      |> fill_in("Memo", with: Factory.memo())
      |> fill_in("Amount", with: amount)
      |> click_button("Make Withdrawal")
      |> assert_has(flash(:info), text: "Withdrawal successful")
      |> assert_has(heading(), text: Safe.to_iodata(fund))
      |> assert_has(heading(), text: "#{balance}")
      |> assert_has(sidebar_fund_balance(), text: "#{balance}")
    end
  end
end
