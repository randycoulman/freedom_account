defmodule FreedomAccountWeb.LoanLive.ActivationFormTest do
  use FreedomAccountWeb.ConnCase, async: true

  import Money.Sigil

  alias FreedomAccount.Factory
  alias Phoenix.HTML.Safe

  describe "activating/deactivating loans" do
    setup [:create_account, :create_loans]

    test "activates/deactivates loans", %{conn: conn, loans: loans} do
      [can_deactivate, inactive, non_zero_balance, to_deactivate] = loans

      conn
      |> visit(~p"/loans/activate")
      |> assert_has(page_title(), text: "Activate/Deactivate Loans")
      |> assert_has(heading(), text: "Activate/Deactivate Loans")
      |> assert_has("label", text: Safe.to_iodata(can_deactivate))
      |> assert_has("label", text: Safe.to_iodata(inactive))
      |> assert_has("label", text: Safe.to_iodata(to_deactivate))
      |> refute_has("label", text: Safe.to_iodata(non_zero_balance))
      |> uncheck(Safe.to_iodata(to_deactivate))
      |> check(Safe.to_iodata(inactive))
      |> click_button("Update Loans")
      |> assert_has(flash(:info), text: "Loans updated successfully")
      |> assert_has(active_tab(), text: "Loans")
      |> assert_has(loan_card(can_deactivate))
      |> assert_has(loan_card(inactive))
      |> assert_has(loan_card(non_zero_balance))
      |> refute_has(loan_card(to_deactivate))
    end

    test "does not activate/deactivate loans on cancel", %{conn: conn, loans: loans} do
      [can_deactivate, inactive, non_zero_balance, to_deactivate] = loans

      conn
      |> visit(~p"/loans/activate")
      |> assert_has(heading(), text: "Activate/Deactivate Loans")
      |> uncheck(Safe.to_iodata(to_deactivate))
      |> check(Safe.to_iodata(inactive))
      |> click_link("Cancel")
      |> assert_has(active_tab(), text: "Loans")
      |> assert_has(loan_card(can_deactivate))
      |> refute_has(loan_card(inactive))
      |> assert_has(loan_card(non_zero_balance))
      |> assert_has(loan_card(to_deactivate))
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
