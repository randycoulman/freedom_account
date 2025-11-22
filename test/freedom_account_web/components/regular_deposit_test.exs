defmodule FreedomAccountWeb.RegularDepositTest do
  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Factory
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.LocalTime

  describe "Show" do
    setup [:create_account, :create_funds]

    test "makes regular deposit within modal on fund list view", %{account: account, conn: conn, funds: funds} do
      [fund1, fund2, fund3] = funds
      [balance1, balance2, balance3] = Enum.map(funds, &expected_balance(&1, account))

      conn
      |> visit(~p"/funds")
      |> click_link("Regular Deposit")
      |> assert_has(page_title(), text: "Regular Deposit")
      |> assert_has(heading(), text: "Regular Deposit")
      |> assert_has(field_value("#inputs_date", "#{LocalTime.today()}"))
      |> fill_in("Date", with: "")
      |> assert_has(field_error("#inputs_date"), text: "can't be blank")
      |> fill_in("Date", with: Factory.date())
      |> click_button("Make Deposit")
      |> assert_has(flash(:info), text: "Regular deposit successful")
      |> assert_has(page_title(), text: "Funds")
      |> assert_has(active_tab(), text: "Funds")
      |> assert_has(fund_balance(fund1), text: "#{balance1}")
      |> assert_has(fund_balance(fund2), text: "#{balance2}")
      |> assert_has(fund_balance(fund3), text: "#{balance3}")
    end
  end

  defp create_funds(%{account: account}) do
    funds =
      for _i <- 1..3 do
        account |> Factory.fund() |> Factory.with_fund_balance()
      end

    %{funds: Enum.sort_by(funds, & &1.name)}
  end

  defp expected_balance(%Fund{} = fund, %Account{} = account) do
    fund
    |> Funds.regular_deposit_amount(account)
    |> Money.add!(fund.current_balance)
  end
end
