defmodule FreedomAccountWeb.FundLive.WithdrawalFormTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  import Money.Sigil

  alias FreedomAccount.Factory
  alias Phoenix.HTML.Safe

  describe "making a withdrawal" do
    setup [:create_account, :create_fund]

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
      |> visit(~p"/funds/#{fund}/withdrawals/new")
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

    test "does not make deposit on cancel", %{account: account, conn: conn, fund: fund} do
      other_fund = account |> Factory.fund() |> Factory.with_fund_balance()
      deposit_amount = ~M[5000]usd
      date = Factory.date()
      memo = Factory.memo()
      amount = Factory.money()
      account_balance = Money.add!(other_fund.current_balance, deposit_amount)

      Factory.deposit(fund, amount: deposit_amount)

      conn
      |> visit(~p"/funds/#{fund}/withdrawals/new")
      |> fill_in("Date", with: date)
      |> fill_in("Memo", with: memo)
      |> fill_in("Amount 0", with: amount)
      |> click_link("Cancel")
      |> assert_has(heading(), text: Safe.to_iodata(fund))
      |> assert_has(heading(), text: "#{deposit_amount}")
      |> assert_has(heading(), text: "#{account_balance}")
      |> assert_has(sidebar_fund_balance(), text: "#{deposit_amount}")
    end
  end
end
