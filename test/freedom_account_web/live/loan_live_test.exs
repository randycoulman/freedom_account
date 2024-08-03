defmodule FreedomAccountWeb.LoanLiveTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  # import Money.Sigil

  alias FreedomAccount.Factory
  # alias FreedomAccount.Loans
  # alias Phoenix.HTML.Safe

  describe "Index" do
    setup [:create_account]

    test "lists all loans", %{account: account, conn: conn} do
      loan = Factory.loan(account)
      Factory.lend(loan)
      # {:ok, loan} = Loans.with_updated_balance(loan)

      conn
      |> visit(~p"/loans")
      |> assert_has(page_title(), text: "Loans")
      |> assert_has(heading(), text: "Loans")
      |> assert_has(table_cell(), text: loan.icon)
      |> assert_has(table_cell(), text: loan.name)

      # |> assert_has(table_cell(), text: to_string(loan.current_balance))
    end

    test "shows prompt when list is empty", %{conn: conn} do
      conn
      |> visit(~p"/loans")
      |> assert_has(heading(), text: "Loans")
      |> assert_has("#no-loans", text: "This account has no active loans. Use the Add Loan button to add one.")
    end

    # test "saves new fund", %{conn: conn} do
    #   %{budget: budget, icon: icon, name: name, times_per_year: times_per_year} = Factory.fund_attrs()

    #   conn
    #   |> visit(~p"/funds")
    #   |> click_link("Add Fund")
    #   |> assert_path(~p"/funds/new")
    #   |> assert_has(page_title(), text: "Add Fund")
    #   |> assert_has(heading(), text: "Add Fund")
    #   |> fill_in("Icon", with: "")
    #   |> fill_in("Name", with: "")
    #   |> assert_has(field_error("#fund_icon"), text: "can't be blank")
    #   |> assert_has(field_error("#fund_name"), text: "can't be blank")
    #   |> fill_in("Icon", with: icon)
    #   |> fill_in("Name", with: name)
    #   |> fill_in("Budget", with: budget)
    #   |> fill_in("Times/Year", with: times_per_year)
    #   |> click_button("Save Fund")
    #   |> assert_has(flash(:info), text: "Fund created successfully")
    #   |> assert_has(table_cell(), text: icon)
    #   |> assert_has(table_cell(), text: name)
    #   |> assert_has(table_cell(), text: "#{budget}")
    #   |> assert_has(table_cell(), text: "#{times_per_year}")
    #   |> assert_has(table_cell(), text: "$0.00")
    # end

    # test "edits fund in listing", %{account: account, conn: conn} do
    #   fund = account |> Factory.fund() |> Factory.with_fund_balance()
    #   %{budget: budget, icon: icon, name: name, times_per_year: times_per_year} = Factory.fund_attrs()

    #   conn
    #   |> visit(~p"/funds")
    #   |> click_link(action_link("#funds-#{fund.id}"), "Edit")
    #   |> assert_has(page_title(), text: "Edit Fund")
    #   |> assert_has(heading(), text: "Edit Fund")
    #   |> fill_in("Icon", with: "")
    #   |> fill_in("Name", with: "")
    #   |> assert_has(field_error("#fund_icon"), text: "can't be blank")
    #   |> assert_has(field_error("#fund_name"), text: "can't be blank")
    #   |> fill_in("Icon", with: icon)
    #   |> fill_in("Name", with: name)
    #   |> fill_in("Budget", with: budget)
    #   |> fill_in("Times/Year", with: times_per_year)
    #   |> click_button("Save Fund")
    #   |> assert_has(flash(:info), text: "Fund updated successfully")
    #   |> assert_has(table_cell(), text: icon)
    #   |> assert_has(table_cell(), text: name)
    #   |> assert_has(table_cell(), text: "#{budget}")
    #   |> assert_has(table_cell(), text: "#{times_per_year}")
    #   |> assert_has(table_cell(), text: "#{fund.current_balance}")
    # end

    # test "deletes fund in listing", %{account: account, conn: conn} do
    #   fund = Factory.fund(account)

    #   conn
    #   |> visit(~p"/funds")
    #   |> click_link(action_link("#funds-#{fund.id}"), "Delete")
    #   |> refute_has("#funds-#{fund.id}")
    # end
  end

  # describe "Show" do
  #   setup [:create_account, :create_fund]

  #   test "drills down to individual fund and back", %{conn: conn, fund: fund} do
  #     conn
  #     |> visit(~p"/funds")
  #     |> click_link("td", fund.name)
  #     |> assert_has(page_title(), text: Safe.to_iodata(fund))
  #     |> assert_has(heading(), text: Safe.to_iodata(fund))
  #     |> assert_has(heading(), text: "$0.00")
  #     |> assert_has(fund_subtitle(), text: "#{fund.budget}")
  #     |> assert_has(fund_subtitle(), text: "#{fund.times_per_year}")
  #     |> click_link("Back to Funds")
  #     |> assert_has(page_title(), text: "Funds")
  #     |> assert_has(heading(), text: "Funds")
  #   end

  #   test "displays fund", %{conn: conn, fund: fund} do
  #     conn
  #     |> visit(~p"/funds/#{fund}")
  #     |> assert_has(heading(), text: Safe.to_iodata(fund))
  #   end

  #   test "updates fund within modal", %{conn: conn, fund: fund} do
  #     %{icon: icon, name: name} = Factory.fund_attrs()
  #     Factory.deposit(fund)
  #     {:ok, fund} = Funds.with_updated_balance(fund)

  #     conn
  #     |> visit(~p"/funds/#{fund}")
  #     |> click_link("Edit Details")
  #     |> assert_has(page_title(), text: "Edit Fund")
  #     |> assert_has(heading(), text: "Edit Fund")
  #     |> fill_in("Icon", with: "")
  #     |> fill_in("Name", with: "")
  #     |> assert_has(field_error("#fund_icon"), text: "can't be blank")
  #     |> assert_has(field_error("#fund_name"), text: "can't be blank")
  #     |> fill_in("Icon", with: icon)
  #     |> fill_in("Name", with: name)
  #     |> click_button("Save Fund")
  #     |> assert_has(flash(:info), text: "Fund updated successfully")
  #     |> assert_has(page_title(), text: "#{icon} #{name}")
  #     |> assert_has(heading(), text: "#{icon} #{name}")
  #     |> assert_has(heading(), text: "#{fund.current_balance}")
  #     |> assert_has(sidebar_fund_name(), text: "#{icon} #{name}")
  #     |> assert_has(sidebar_fund_balance(), text: "#{fund.current_balance}")
  #   end

  #   test "deposits money to a fund", %{conn: conn, fund: fund} do
  #     today = Timex.today(:local)
  #     date = Factory.date()
  #     memo = Factory.memo()
  #     amount = Factory.money()

  #     conn
  #     |> visit(~p"/funds/#{fund}")
  #     |> click_link("#single-fund-deposit", "Deposit")
  #     |> assert_has(page_title(), text: "Deposit")
  #     |> assert_has(heading(), text: "Deposit")
  #     |> assert_has(field_value("#transaction_date", today))
  #     |> assert_has("label", text: Safe.to_iodata(fund))
  #     |> refute_has("#transaction-total")
  #     |> fill_in("Date", with: date)
  #     |> fill_in("Memo", with: memo)
  #     |> click_button("Make Deposit")
  #     |> refute_has("#line-items-error")
  #     |> fill_in("Amount 0", with: amount)
  #     |> click_button("Make Deposit")
  #     |> assert_has(flash(:info), text: "Deposit successful")
  #     |> assert_has(heading(), text: Safe.to_iodata(fund))
  #     |> assert_has(heading(), text: "#{amount}")
  #     |> assert_has(sidebar_fund_balance(), text: "#{amount}")
  #     |> assert_has(table_cell(), text: "#{date}")
  #     |> assert_has(table_cell(), text: memo)
  #     |> assert_has(role("deposit"), text: "#{amount}")
  #   end

  #   test "withdraws money from a fund", %{conn: conn, fund: fund} do
  #     today = Timex.today(:local)
  #     deposit_amount = ~M[5000]usd
  #     date = Factory.date()
  #     memo = Factory.memo()
  #     amount = Factory.money()
  #     balance = Money.sub!(deposit_amount, amount)

  #     Factory.deposit(fund, amount: deposit_amount)

  #     conn
  #     |> visit(~p"/funds/#{fund}")
  #     |> click_link("#single-fund-withdrawal", "Withdraw")
  #     |> assert_has(page_title(), text: "Withdraw")
  #     |> assert_has(heading(), text: "Withdraw")
  #     |> assert_has(field_value("#transaction_date", today))
  #     |> assert_has("label", text: Safe.to_iodata(fund))
  #     |> refute_has("#transaction-total")
  #     |> fill_in("Date", with: date)
  #     |> fill_in("Memo", with: memo)
  #     |> click_button("Make Withdrawal")
  #     |> refute_has("#line-items-error")
  #     |> fill_in("Amount 0", with: amount)
  #     |> click_button("Make Withdrawal")
  #     |> assert_has(flash(:info), text: "Withdrawal successful")
  #     |> assert_has(heading(), text: Safe.to_iodata(fund))
  #     |> assert_has(heading(), text: "#{balance}")
  #     |> assert_has(sidebar_fund_balance(), text: "#{balance}")
  #     |> assert_has(table_cell(), text: "#{date}")
  #     |> assert_has(table_cell(), text: memo)
  #     |> assert_has(role("withdrawal"), text: "#{amount}")
  #   end
  # end
end
