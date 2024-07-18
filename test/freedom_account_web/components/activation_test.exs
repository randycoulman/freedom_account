defmodule FreedomAccountWeb.ActivationTest do
  use FreedomAccountWeb.ConnCase, async: true

  import Money.Sigil

  alias FreedomAccount.Factory

  describe "Show" do
    setup [:create_account, :create_funds]

    test "activates/deactivates funds within modal on fund list view", %{conn: conn} do
      conn
      |> visit(~p"/")
      |> click_link("Activate/Deactivate")
      |> assert_has(page_title(), text: "Activate/Deactivate")
      |> assert_has(heading(), text: "Activate/Deactivate")
      |> assert_has("label", text: "Can Deactivate")
      |> assert_has("label", text: "Inactive")
      |> assert_has("label", text: "To Deactivate")
      |> refute_has("label", text: "Has Non-Zero Balance")
      |> uncheck("To Deactivate")
      |> check("Inactive")
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
      account |> Factory.fund(name: "Has Non-Zero Balance") |> Factory.with_balance(~M[150]usd),
      Factory.fund(account, name: "To Deactivate", current_balance: Money.zero(:usd))
    ]

    %{funds: funds}
  end
end
