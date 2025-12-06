defmodule FreedomAccountWeb.FundLiveTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  import Money.Sigil

  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Factory
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.MoneyUtils
  alias Phoenix.HTML.Safe

  describe "Index" do
    setup [:create_account]

    test "lists all funds", %{account: account, conn: conn} do
      fund = Factory.fund(account)
      Factory.deposit(fund)
      {:ok, fund} = Funds.with_updated_balance(fund)

      conn
      |> visit(~p"/funds")
      |> assert_has(page_title(), text: "Funds")
      |> assert_has(active_tab(), text: "Funds")
      |> assert_has(fund_icon(fund), text: fund.icon)
      |> assert_has(fund_name(fund), text: fund.name)
      |> assert_has(fund_budget(fund), text: "#{fund.budget}")
      |> assert_has(fund_frequency(fund), text: "#{fund.times_per_year}")
      |> assert_has(fund_balance(fund), text: to_string(fund.current_balance))
    end

    test "shows prompt when list is empty", %{conn: conn} do
      conn
      |> visit(~p"/funds")
      |> assert_has(active_tab(), text: "Funds")
      |> assert_has("#no-funds", text: "This account has no funds yet. Use the Add Fund button to add one.")
    end

    test "shows total funds balance", %{account: account, conn: conn} do
      fund = account |> Factory.fund() |> Factory.with_fund_balance()
      _loan = account |> Factory.loan() |> Factory.with_loan_balance()

      conn
      |> visit(~p"/funds")
      |> assert_has(active_tab(), text: "#{fund.current_balance}")
    end

    test "saves new fund", %{conn: conn} do
      %{budget: budget, icon: icon, name: name, times_per_year: times_per_year} = Factory.fund_attrs()

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

    test "edits fund in listing", %{account: account, conn: conn} do
      fund = account |> Factory.fund() |> Factory.with_fund_balance()
      %{budget: budget, icon: icon, name: name, times_per_year: times_per_year} = Factory.fund_attrs()

      conn
      |> visit(~p"/funds")
      |> click_link(fund_action(fund), "Edit")
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

    test "deletes fund in listing", %{account: account, conn: conn} do
      fund = Factory.fund(account)

      conn
      |> visit(~p"/funds")
      |> click_link(action_link("#funds-#{fund.id}"), "Delete")
      |> refute_has("#funds-#{fund.id}")
    end

    test "updates budget from listing", %{account: account, conn: conn} do
      funds =
        1..3
        |> Enum.map(fn _i -> Factory.fund(account) end)
        |> Enum.sort_by(& &1.name)

      [fund0, fund1, fund2] = funds
      attrs = [attrs0, attrs1, attrs2] = Enum.map(funds, fn _fund -> Factory.fund_attrs() end)

      amounts =
        [amount1, amount2, amount3] =
        funds
        |> Enum.zip(attrs)
        |> Enum.map(&regular_deposit_amount(&1, account))

      total = MoneyUtils.sum(amounts)

      conn
      |> visit(~p"/funds")
      |> click_link("Budget")
      |> assert_has(page_title(), text: "Update Budget")
      |> assert_has(heading(), text: "Update Budget")
      |> assert_has("label", text: Safe.to_iodata(fund0))
      |> assert_has("label", text: Safe.to_iodata(fund1))
      |> assert_has("label", text: Safe.to_iodata(fund2))
      |> fill_in("Budget 1", with: "")
      |> fill_in("Times/Year 2", with: "")
      |> assert_has(field_error("#budget_funds_1_budget"), text: "can't be blank")
      |> assert_has(field_error("#budget_funds_2_times_per_year"), text: "can't be blank")
      |> fill_in("Budget 0", with: attrs0[:budget])
      |> fill_in("Times/Year 0", with: attrs0[:times_per_year])
      |> assert_has(role("deposit-amount-0"), with: "#{amount1}")
      |> fill_in("Budget 1", with: attrs1[:budget])
      |> fill_in("Times/Year 1", with: attrs1[:times_per_year])
      |> assert_has(role("deposit-amount-1"), with: "#{amount2}")
      |> fill_in("Budget 2", with: attrs2[:budget])
      |> fill_in("Times/Year 2", with: attrs2[:times_per_year])
      |> assert_has(role("deposit-amount-2"), with: "#{amount3}")
      |> assert_has("#deposit-total", with: "#{total}")
      |> click_button("Update Budget")
      |> assert_has(flash(:info), text: "Budget updated successfully")
      |> assert_has(page_title(), text: "Funds")
      |> assert_has(active_tab(), text: "Funds")
      |> assert_has(fund_budget(fund1), text: "#{attrs1[:budget]}")
      |> assert_has(fund_frequency(fund2), text: "#{attrs2[:times_per_year]}")
    end

    test "does not update budget on cancel", %{account: account, conn: conn} do
      fund = Factory.fund(account)
      attrs = Factory.fund_attrs()
      amount = regular_deposit_amount({fund, attrs}, account)

      conn
      |> visit(~p"/funds")
      |> click_link("Budget")
      |> fill_in("Budget 0", with: attrs[:budget])
      |> fill_in("Times/Year 0", with: attrs[:times_per_year])
      |> assert_has(role("deposit-amount-0"), with: "#{amount}")
      |> click_link("Cancel")
      |> assert_has(active_tab(), text: "Funds")
      |> assert_has(fund_budget(fund), text: "#{fund.budget}")
      |> assert_has(fund_frequency(fund), text: "#{fund.times_per_year}")
    end

    defp regular_deposit_amount({%Fund{} = fund, attrs}, %Account{} = account) do
      fund
      |> Funds.change_fund(attrs)
      |> Funds.regular_deposit_amount(account)
    end
  end

  describe "Show" do
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

    test "deposits money to a fund", %{account: account, conn: conn, fund: fund} do
      other_fund = account |> Factory.fund() |> Factory.with_fund_balance()
      date = Factory.date()
      memo = Factory.memo()
      amount = Factory.money()
      account_balance = Money.add!(other_fund.current_balance, amount)

      conn
      |> visit(~p"/funds/#{fund}")
      |> click_link("#single-fund-deposit", "Deposit")
      |> assert_has(page_title(), text: "Deposit")
      |> assert_has(heading(), text: "Deposit")
      |> assert_has("label", text: Safe.to_iodata(fund))
      |> refute_has("#transaction-total")
      |> fill_in("Date", with: date)
      |> fill_in("Memo", with: memo)
      |> click_button("Make Deposit")
      |> refute_has("#line-items-error")
      |> fill_in("Amount 0", with: amount)
      |> click_button("Make Deposit")
      |> assert_has(flash(:info), text: "Deposit successful")
      |> assert_has(heading(), text: Safe.to_iodata(fund))
      |> assert_has(heading(), text: "#{amount}")
      |> assert_has(heading(), text: "#{account_balance}")
      |> assert_has(sidebar_fund_balance(), text: "#{amount}")
      |> assert_has(table_cell(), text: "#{date}")
      |> assert_has(table_cell(), text: memo)
      |> assert_has(role("deposit"), text: "#{amount}")
    end

    test "withdraws money from a fund", %{account: account, conn: conn, fund: fund} do
      other_fund = account |> Factory.fund() |> Factory.with_fund_balance()
      deposit_amount = ~M[5000]usd
      date = Factory.date()
      memo = Factory.memo()
      amount = Factory.money()
      balance = Money.sub!(deposit_amount, amount)
      account_balance = Money.add!(other_fund.current_balance, balance)

      Factory.deposit(fund, amount: deposit_amount)

      conn
      |> visit(~p"/funds/#{fund}")
      |> click_link("#single-fund-withdrawal", "Withdraw")
      |> assert_has(page_title(), text: "Withdraw")
      |> assert_has(heading(), text: "Withdraw")
      |> assert_has("label", text: Safe.to_iodata(fund))
      |> refute_has("#transaction-total")
      |> fill_in("Date", with: date)
      |> fill_in("Memo", with: memo)
      |> click_button("Make Withdrawal")
      |> refute_has("#line-items-error")
      |> fill_in("Amount 0", with: amount)
      |> click_button("Make Withdrawal")
      |> assert_has(flash(:info), text: "Withdrawal successful")
      |> assert_has(heading(), text: Safe.to_iodata(fund))
      |> assert_has(heading(), text: "#{balance}")
      |> assert_has(heading(), text: "#{account_balance}")
      |> assert_has(sidebar_fund_balance(), text: "#{balance}")
      |> assert_has(table_cell(), text: "#{date}")
      |> assert_has(table_cell(), text: memo)
      |> assert_has(role("withdrawal"), text: "#{amount}")
    end
  end
end
