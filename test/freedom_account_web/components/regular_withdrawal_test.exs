defmodule FreedomAccountWeb.RegularWithdrawalTest do
  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias Phoenix.HTML.Safe

  describe "Show" do
    setup [:create_account, :create_funds]

    test "makes regular withdrawal within modal on fund list view", %{conn: conn, funds: funds} do
      [{amount1, balance1}, {amount2, balance2}, {amount3, balance3}] =
        for fund <- funds do
          amount = Money.mult!(fund.current_balance, :rand.uniform())
          balance = Money.sub!(fund.current_balance, amount)
          {amount, balance}
        end

      conn
      |> visit(~p"/")
      |> click_link("Regular Withdrawal")
      |> assert_has(page_title(), text: "Regular Withdrawal")
      |> assert_has(heading(), text: "Regular Withdrawal")
      |> assert_has(field_value("#transaction_date", "#{Timex.today(:local)}"))
      |> fill_in("Date", with: "")
      |> assert_has(field_error("#transaction_date"), text: "can't be blank")
      |> fill_in("Date", with: Factory.date())
      |> fill_in("Memo", with: "Cover expenses")
      |> click_button("Make Withdrawal")
      |> assert_has("#line-items-error", text: "Requires at least one line item with a non-zero amount")
      |> fill_in("Amount 0", with: "#{amount1}")
      |> fill_in("Amount 1", with: "#{amount2}")
      |> fill_in("Amount 2", with: "#{amount3}")
      |> click_button("Make Withdrawal")
      |> assert_has(flash(:info), text: "Withdrawal successful")
      |> assert_has(page_title(), text: "Funds")
      |> assert_has(heading(), text: "Funds")
      |> assert_has(table_cell(), text: "#{balance1}")
      |> assert_has(table_cell(), text: "#{balance2}")
      |> assert_has(table_cell(), text: "#{balance3}")
    end

    test "makes regular withdrawal within modal on fund show view", %{conn: conn, funds: funds} do
      [{amount1, balance1}, {amount2, balance2}, {amount3, balance3}] =
        for fund <- funds do
          amount = Money.mult!(fund.current_balance, :rand.uniform())
          balance = Money.sub!(fund.current_balance, amount)
          {amount, balance}
        end

      fund = hd(funds)

      conn
      |> visit(~p"/funds/#{fund}")
      |> click_link("Regular Withdrawal")
      |> assert_has(page_title(), text: "Regular Withdrawal")
      |> assert_has(heading(), text: "Regular Withdrawal")
      |> fill_in("Memo", with: "Cover expenses")
      |> fill_in("Amount 0", with: "#{amount1}")
      |> fill_in("Amount 1", with: "#{amount2}")
      |> fill_in("Amount 2", with: "#{amount3}")
      |> click_button("Make Withdrawal")
      |> assert_has(flash(:info), text: "Withdrawal successful")
      |> assert_has(page_title(), text: Safe.to_iodata(fund.name))
      |> assert_has(heading(), text: Safe.to_iodata(fund.name))
      |> assert_has(heading(), text: "#{balance1}")
      |> assert_has(sidebar_fund_balance(), text: "#{balance1}")
      |> assert_has(sidebar_fund_balance(), text: "#{balance2}")
      |> assert_has(sidebar_fund_balance(), text: "#{balance3}")
    end
  end

  defp create_funds(%{account: account}) do
    funds =
      for _i <- 1..3 do
        account |> Factory.fund() |> Factory.with_balance()
      end

    %{funds: Enum.sort_by(funds, & &1.name)}
  end
end
