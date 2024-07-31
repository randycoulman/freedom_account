defmodule FreedomAccountWeb.ActivationTest do
  use FreedomAccountWeb.ConnCase, async: true

  import Money.Sigil

  alias FreedomAccount.Factory
  alias Phoenix.HTML.Safe

  describe "Show" do
    setup [:create_account, :create_funds]

    test "activates/deactivates funds within modal on fund list view", %{conn: conn, funds: funds} do
      [can_deactivate, inactive, non_zero_balance, to_deactivate] = Enum.map(funds, &Safe.to_iodata/1)

      conn
      |> visit(~p"/")
      |> click_link("Activate/Deactivate")
      |> assert_has(page_title(), text: "Activate/Deactivate")
      |> assert_has(heading(), text: "Activate/Deactivate")
      |> assert_has("label", text: can_deactivate)
      |> assert_has("label", text: inactive)
      |> assert_has("label", text: to_deactivate)
      |> refute_has("label", text: non_zero_balance)
      |> uncheck(to_deactivate)
      |> check(inactive)
      |> click_button("Update Funds")
      |> assert_has(flash(:info), text: "Funds updated successfully")
      |> assert_has(page_title(), text: "Funds")
      |> assert_has(heading(), text: "Funds")
      |> assert_has(table_cell(), text: "Can Deactivate")
      |> assert_has(table_cell(), text: "Inactive")
      |> assert_has(table_cell(), text: "Has Non-Zero Balance")
      |> refute_has(table_cell(), text: "To Deactivate")
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
