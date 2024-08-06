defmodule FreedomAccountWeb.LoanActivationTest do
  use FreedomAccountWeb.ConnCase, async: true

  import Money.Sigil

  alias FreedomAccount.Factory
  alias Phoenix.HTML.Safe

  describe "Show" do
    setup [:create_account, :create_loans]

    test "activates/deactivates loans within modal on loan list view", %{conn: conn, loans: loans} do
      [can_deactivate, inactive, non_zero_balance, to_deactivate] = Enum.map(loans, &Safe.to_iodata/1)

      conn
      |> visit(~p"/loans")
      |> click_link("Activate/Deactivate")
      |> assert_has(page_title(), text: "Activate/Deactivate")
      |> assert_has(heading(), text: "Activate/Deactivate")
      |> assert_has("label", text: can_deactivate)
      |> assert_has("label", text: inactive)
      |> assert_has("label", text: to_deactivate)
      |> refute_has("label", text: non_zero_balance)
      |> uncheck(to_deactivate)
      |> check(inactive)
      |> click_button("Update Loans")
      |> assert_has(flash(:info), text: "Loans updated successfully")
      |> assert_has(page_title(), text: "Loans")
      |> assert_has(heading(), text: "Loans")
      |> assert_has(table_cell(), text: "Can Deactivate")
      |> assert_has(table_cell(), text: "Inactive")
      |> assert_has(table_cell(), text: "Has Non-Zero Balance")
      |> refute_has(table_cell(), text: "To Deactivate")
    end
  end

  defp create_loans(%{account: account}) do
    loans = [
      Factory.loan(account, name: "Can Deactivate", current_balance: Money.zero(:usd)),
      Factory.inactive_loan(account, name: "Inactive", current_balance: Money.zero(:usd)),
      account |> Factory.loan(name: "Has Non-Zero Balance") |> Factory.with_loan_balance(~M[150]usd),
      Factory.loan(account, name: "To Deactivate", current_balance: Money.zero(:usd))
    ]

    %{loans: loans}
  end
end
