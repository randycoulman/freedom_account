defmodule FreedomAccountWeb.FundActivationTest do
  use FreedomAccountWeb.ConnCase, async: true

  import Money.Sigil

  alias FreedomAccount.Factory
  alias Phoenix.HTML.Safe

  describe "Show" do
    setup [:create_account, :create_funds]

    test "activates/deactivates funds within modal on fund list view", %{conn: conn, funds: funds} do
      [can_deactivate, inactive, non_zero_balance, to_deactivate] = funds

      conn
      |> visit(~p"/funds")
      |> click_link("Activate/Deactivate")
      |> assert_has(page_title(), text: "Activate/Deactivate")
      |> assert_has(heading(), text: "Activate/Deactivate")
      |> assert_has("label", text: Safe.to_iodata(can_deactivate))
      |> assert_has("label", text: Safe.to_iodata(inactive))
      |> assert_has("label", text: Safe.to_iodata(to_deactivate))
      |> refute_has("label", text: Safe.to_iodata(non_zero_balance))
      |> uncheck(Safe.to_iodata(to_deactivate))
      |> check(Safe.to_iodata(inactive))
      |> click_button("Update Funds")
      |> assert_has(flash(:info), text: "Funds updated successfully")
      |> assert_has(page_title(), text: "Funds")
      |> assert_has(active_tab(), text: "Funds")
      |> assert_has(fund_card(can_deactivate))
      |> assert_has(fund_card(inactive))
      |> assert_has(fund_card(non_zero_balance))
      |> refute_has(fund_card(to_deactivate))
    end
  end

  defp create_funds(%{account: account}) do
    funds = [
      Factory.fund(account, name: "Can Deactivate", current_balance: Money.zero(:usd)),
      Factory.inactive_fund(account, name: "Inactive", current_balance: Money.zero(:usd)),
      account |> Factory.fund(name: "Has Non-Zero Balance") |> Factory.with_fund_balance(~M[150]usd),
      Factory.fund(account, name: "To Deactivate", current_balance: Money.zero(:usd))
    ]

    %{funds: funds}
  end
end
