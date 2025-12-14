defmodule FreedomAccountWeb.LoanLive.ShowTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  alias Phoenix.HTML.Safe

  describe "viewing an individual loan" do
    setup [:create_account, :create_loan]

    test "drills down to individual loan and back", %{conn: conn, loan: loan} do
      conn
      |> visit(~p"/loans")
      |> click_link(loan_card(loan), loan.name)
      |> assert_has(page_title(), text: Safe.to_iodata(loan))
      |> assert_has(heading(), text: Safe.to_iodata(loan))
      |> assert_has(heading(), text: "$0.00")
      |> click_link("Back to Loans")
      |> assert_has(page_title(), text: "Loans")
      |> assert_has(active_tab(), text: "Loans")
    end

    test "displays loan", %{conn: conn, loan: loan} do
      conn
      |> visit(~p"/loans/#{loan}")
      |> assert_has(heading(), text: Safe.to_iodata(loan))
    end

    test "allows editing loan", %{conn: conn, loan: loan} do
      conn
      |> visit(~p"/loans/#{loan}")
      |> click_link("Edit Details")
      |> assert_path(~p"/loans/#{loan}/edit")
      |> click_link("Cancel")
      |> assert_has(heading(), text: Safe.to_iodata(loan))
    end

    test "allows lending money from a loan", %{conn: conn, loan: loan} do
      conn
      |> visit(~p"/loans/#{loan}")
      |> click_link("Lend")
      |> assert_path(~p"/loans/#{loan}/loans/new")
      |> click_link("Cancel")
      |> assert_has(heading(), text: Safe.to_iodata(loan))
    end

    test "allows receiving payment on a loan", %{conn: conn, loan: loan} do
      conn
      |> visit(~p"/loans/#{loan}")
      |> click_link("Payment")
      |> assert_path(~p"/loans/#{loan}/payments/new")
      |> click_link("Cancel")
      |> assert_has(heading(), text: Safe.to_iodata(loan))
    end
  end
end
