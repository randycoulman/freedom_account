defmodule FreedomAccountWeb.LoanLiveTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  # import Money.Sigil

  alias FreedomAccount.Factory
  alias FreedomAccount.Loans
  alias FreedomAccount.MoneyUtils
  alias Phoenix.HTML.Safe

  describe "Index" do
    setup [:create_account]

    test "lists all loans", %{account: account, conn: conn} do
      loan = Factory.loan(account)
      Factory.lend(loan)
      {:ok, loan} = Loans.with_updated_balance(loan)

      conn
      |> visit(~p"/loans")
      |> assert_has(page_title(), text: "Loans")
      |> assert_has(heading(), text: "Loans")
      |> assert_has(table_cell(), text: loan.icon)
      |> assert_has(table_cell(), text: loan.name)
      |> assert_has(table_cell(), text: to_string(loan.current_balance))
    end

    test "shows prompt when list is empty", %{conn: conn} do
      conn
      |> visit(~p"/loans")
      |> assert_has(heading(), text: "Loans")
      |> assert_has("#no-loans", text: "This account has no active loans. Use the Add Loan button to add one.")
    end

    test "saves new loan", %{conn: conn} do
      %{icon: icon, name: name} = Factory.loan_attrs()

      conn
      |> visit(~p"/loans")
      |> click_link("Add Loan")
      |> assert_path(~p"/loans/new")
      |> assert_has(page_title(), text: "Add Loan")
      |> assert_has(heading(), text: "Add Loan")
      |> fill_in("Icon", with: "")
      |> fill_in("Name", with: "")
      |> assert_has(field_error("#loan_icon"), text: "can't be blank")
      |> assert_has(field_error("#loan_name"), text: "can't be blank")
      |> fill_in("Icon", with: icon)
      |> fill_in("Name", with: name)
      |> click_button("Save Loan")
      |> assert_has(flash(:info), text: "Loan created successfully")
      |> assert_has(table_cell(), text: icon)
      |> assert_has(table_cell(), text: name)
      |> assert_has(table_cell(), text: "$0.00")
    end

    test "edits loan in listing", %{account: account, conn: conn} do
      loan = account |> Factory.loan() |> Factory.with_loan_balance()
      %{icon: icon, name: name} = Factory.loan_attrs()

      conn
      |> visit(~p"/loans")
      |> click_link(action_link("#loans-#{loan.id}"), "Edit")
      |> assert_has(page_title(), text: "Edit Loan")
      |> assert_has(heading(), text: "Edit Loan")
      |> fill_in("Icon", with: "")
      |> fill_in("Name", with: "")
      |> assert_has(field_error("#loan_icon"), text: "can't be blank")
      |> assert_has(field_error("#loan_name"), text: "can't be blank")
      |> fill_in("Icon", with: icon)
      |> fill_in("Name", with: name)
      |> click_button("Save Loan")
      |> assert_has(flash(:info), text: "Loan updated successfully")
      |> assert_has(table_cell(), text: icon)
      |> assert_has(table_cell(), text: name)
      |> assert_has(table_cell(), text: "#{loan.current_balance}")
    end

    test "deletes loan in listing", %{account: account, conn: conn} do
      loan = Factory.loan(account)

      conn
      |> visit(~p"/loans")
      |> click_link(action_link("#loans-#{loan.id}"), "Delete")
      |> refute_has("#loans-#{loan.id}")
    end
  end

  describe "Show" do
    setup [:create_account, :create_loan]

    test "drills down to individual loan and back", %{conn: conn, loan: loan} do
      conn
      |> visit(~p"/loans")
      |> click_link("td", loan.name)
      |> assert_has(page_title(), text: Safe.to_iodata(loan))
      |> assert_has(heading(), text: Safe.to_iodata(loan))
      |> assert_has(heading(), text: "$0.00")
      |> click_link("Back to Loans")
      |> assert_has(page_title(), text: "Loans")
      |> assert_has(heading(), text: "Loans")
    end

    test "displays loan", %{conn: conn, loan: loan} do
      conn
      |> visit(~p"/loans/#{loan}")
      |> assert_has(heading(), text: Safe.to_iodata(loan))
    end

    test "updates loan within modal", %{conn: conn, loan: loan} do
      %{icon: icon, name: name} = Factory.loan_attrs()
      Factory.lend(loan)
      {:ok, loan} = Loans.with_updated_balance(loan)

      conn
      |> visit(~p"/loans/#{loan}")
      |> click_link("Edit Details")
      |> assert_has(page_title(), text: "Edit Loan")
      |> assert_has(heading(), text: "Edit Loan")
      |> fill_in("Icon", with: "")
      |> fill_in("Name", with: "")
      |> assert_has(field_error("#loan_icon"), text: "can't be blank")
      |> assert_has(field_error("#loan_name"), text: "can't be blank")
      |> fill_in("Icon", with: icon)
      |> fill_in("Name", with: name)
      |> click_button("Save Loan")
      |> assert_has(flash(:info), text: "Loan updated successfully")
      |> assert_has(page_title(), text: "#{icon} #{name}")
      |> assert_has(heading(), text: "#{icon} #{name}")
      |> assert_has(heading(), text: "#{loan.current_balance}")
      |> assert_has(sidebar_loan_name(), text: "#{icon} #{name}")
      |> assert_has(sidebar_loan_balance(), text: "#{loan.current_balance}")
    end

    test "lends money from a loan", %{account: account, conn: conn, loan: loan} do
      fund = account |> Factory.fund() |> Factory.with_fund_balance()
      today = Timex.today(:local)
      date = Factory.date()
      memo = Factory.memo()
      amount = Factory.money()
      balance = MoneyUtils.negate(amount)
      account_balance = Money.sub!(fund.current_balance, amount)

      conn
      |> visit(~p"/loans/#{loan}")
      |> click_link("Lend")
      |> assert_has(page_title(), text: "Lend")
      |> assert_has(heading(), text: "Lend")
      |> assert_has(field_value("#loan_transaction_date", today))
      |> fill_in("Date", with: date)
      |> fill_in("Memo", with: memo)
      |> fill_in("Amount", with: amount)
      |> click_button("Lend Money")
      |> assert_has(flash(:info), text: "Money lent successfully")
      |> assert_has(heading(), text: Safe.to_iodata(loan))
      |> assert_has(heading(), text: "#{balance}")
      |> assert_has(heading(), text: "#{account_balance}")
      |> assert_has(sidebar_loan_balance(), text: "#{balance}")

      # |> assert_has(table_cell(), text: "#{date}")
      # |> assert_has(table_cell(), text: memo)
      # |> assert_has(role("loan"), text: "#{amount}")
    end

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
  end
end
