defmodule FreedomAccountWeb.LoanListTest do
  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias Phoenix.HTML.Safe

  defp create_loans(%{account: account}) do
    loans =
      for _i <- 1..3 do
        Factory.loan(account)
      end

    %{loans: Enum.sort_by(loans, & &1.name)}
  end

  describe "loan list component" do
    setup [:create_account, :create_loans]

    test "displays loan list", %{conn: conn, loans: loans} do
      [loan1, loan2, loan3] = loans

      conn
      |> visit(~p"/loans/#{loan1}")
      |> assert_has(heading(), text: "Loans")
      |> assert_has(link(), text: Safe.to_iodata(loan1))
      |> assert_has(link(), text: Safe.to_iodata(loan2))
      |> assert_has(link(), text: Safe.to_iodata(loan3))
    end

    test "navigates to other loans", %{conn: conn, loans: loans} do
      [loan1, loan2, _rest] = loans

      conn
      |> visit(~p"/loans/#{loan1}")
      |> click_link(loan2.name)
      |> assert_has(heading(), text: Safe.to_iodata(loan2))
    end

    test "returns to loan list when header clicked", %{conn: conn, loans: loans} do
      loan = hd(loans)

      conn
      |> visit(~p"/loans/#{loan}")
      |> click_link(heading_link(), "Loans")
      |> assert_path(~p"/loans")
    end
  end
end
