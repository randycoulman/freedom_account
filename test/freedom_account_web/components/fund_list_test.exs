defmodule FreedomAccountWeb.FundListTest do
  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias Phoenix.HTML.Safe

  defp create_funds(%{account: account}) do
    funds =
      for _i <- 1..3 do
        Factory.fund(account)
      end

    %{funds: Enum.sort_by(funds, & &1.name)}
  end

  describe "fund list component" do
    setup [:create_account, :create_funds]

    test "displays fund list", %{conn: conn, funds: funds} do
      [fund1, fund2, fund3] = funds

      conn
      |> visit(~p"/funds/#{fund1}")
      |> assert_has(heading(), text: "Funds")
      |> assert_has(link(), text: Safe.to_iodata(fund1))
      |> assert_has(link(), text: Safe.to_iodata(fund2))
      |> assert_has(link(), text: Safe.to_iodata(fund3))
    end

    test "navigates to other funds", %{conn: conn, funds: funds} do
      [fund1, fund2, _rest] = funds

      conn
      |> visit(~p"/funds/#{fund1}")
      |> click_link(fund2.name)
      |> assert_has(heading(), text: Safe.to_iodata(fund2))
    end
  end
end
