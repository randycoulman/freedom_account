defmodule FreedomAccountWeb.RegularWithdrawalTest do
  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory

  describe "Show" do
    setup [:create_account, :create_funds]

    test "makes regular withdrawal within modal on fund list view", %{conn: conn, funds: funds} do
      [{amount1, balance1}, {amount2, balance2}, {amount3, balance3}] =
        for fund <- funds do
          amount = fund.current_balance |> Money.mult!(:rand.uniform()) |> Money.round()
          balance = Money.sub!(fund.current_balance, amount)
          {amount, balance}
        end

      total1 = amount1
      total2 = Money.add!(total1, amount2)
      total3 = Money.add!(total2, amount3)

      conn
      |> visit(~p"/")
      |> click_link("Regular Withdrawal")
      |> assert_has(page_title(), text: "Regular Withdrawal")
      |> assert_has(heading(), text: "Regular Withdrawal")
      |> assert_has(field_value("#transaction_date", "#{Timex.today(:local)}"))
      |> assert_has("#transaction-total", text: "#{Money.zero(:usd)}")
      |> fill_in("Date", with: "")
      |> assert_has(field_error("#transaction_date"), text: "can't be blank")
      |> fill_in("Date", with: Factory.date())
      |> fill_in("Memo", with: "Cover expenses")
      |> click_button("Make Withdrawal")
      |> assert_has("#line-items-error", text: "Requires at least one line item with a non-zero amount")
      |> fill_in("Amount 0", with: "#{amount1}")
      |> assert_has("#transaction-total", text: "#{total1}")
      |> fill_in("Amount 1", with: "#{amount2}")
      |> assert_has("#transaction-total", text: "#{total2}")
      |> fill_in("Amount 2", with: "#{amount3}")
      |> assert_has("#transaction-total", text: "#{total3}")
      |> click_button("Make Withdrawal")
      |> assert_has(flash(:info), text: "Withdrawal successful")
      |> assert_has(page_title(), text: "Funds")
      |> assert_has(heading(), text: "Funds")
      |> assert_has(table_cell(), text: "#{balance1}")
      |> assert_has(table_cell(), text: "#{balance2}")
      |> assert_has(table_cell(), text: "#{balance3}")
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
