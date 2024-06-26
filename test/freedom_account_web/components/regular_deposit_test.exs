defmodule FreedomAccountWeb.RegularDepositTest do
  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias Phoenix.HTML.Safe

  describe "Show" do
    setup [:create_account, :create_funds]

    test "makes regular deposit within modal on fund list view", %{account: account, conn: conn, funds: funds} do
      [balance1, balance2, balance3] = Enum.map(funds, &expected_balance(&1, account.deposits_per_year))

      conn
      |> visit(~p"/")
      |> click_link("Regular Deposit")
      |> assert_has(page_title(), text: "Regular Deposit")
      |> assert_has(heading(), text: "Regular Deposit")
      |> assert_has(field_value("#inputs_date", "#{Timex.today(:local)}"))
      |> fill_in("Date", with: "")
      |> assert_has(field_error("#inputs_date"), text: "can't be blank")
      |> fill_in("Date", with: Factory.date())
      |> click_button("Make Deposit")
      |> assert_has(flash(:info), text: "Regular deposit successful")
      |> assert_has(page_title(), text: "Funds")
      |> assert_has(heading(), text: "Funds")
      |> assert_has(table_cell(), text: "#{balance1}")
      |> assert_has(table_cell(), text: "#{balance2}")
      |> assert_has(table_cell(), text: "#{balance3}")
    end

    test "makes regular deposit within modal on fund show view", %{account: account, conn: conn, funds: funds} do
      fund = hd(funds)
      fund_balance = expected_balance(fund, account.deposits_per_year)
      [balance1, balance2, balance3] = Enum.map(funds, &expected_balance(&1, account.deposits_per_year))

      conn
      |> visit(~p"/funds/#{fund}")
      |> click_link("Regular Deposit")
      |> assert_has(page_title(), text: "Regular Deposit")
      |> assert_has(heading(), text: "Regular Deposit")
      |> click_button("Make Deposit")
      |> assert_has(flash(:info), text: "Regular deposit successful")
      |> assert_has(page_title(), text: Safe.to_iodata(fund.name))
      |> assert_has(heading(), text: Safe.to_iodata(fund.name))
      |> assert_has(heading(), text: "#{fund_balance}")
      |> assert_has(sidebar_fund_balance(), text: "#{balance1}")
      |> assert_has(sidebar_fund_balance(), text: "#{balance2}")
      |> assert_has(sidebar_fund_balance(), text: "#{balance3}")
    end
  end

  defp create_funds(%{account: account}) do
    funds =
      for _i <- 1..3 do
        fund = Factory.fund(account, current_balance: Factory.money())
        Factory.deposit(fund, amount: fund.current_balance)
        fund
      end

    %{funds: Enum.sort_by(funds, & &1.name)}
  end

  defp expected_balance(%Fund{} = fund, deposits_per_year) do
    fund
    |> Funds.regular_deposit_amount(deposits_per_year)
    |> Money.add!(fund.current_balance)
  end
end
