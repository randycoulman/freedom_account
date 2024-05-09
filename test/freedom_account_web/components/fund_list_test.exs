defmodule FreedomAccountWeb.FundListTest do
  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory

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
      |> assert_has(link(), text: "#{fund1.icon} #{fund1.name}")
      |> assert_has(link(), text: "#{fund2.icon} #{fund2.name}")
      |> assert_has(link(), text: "#{fund3.icon} #{fund3.name}")
    end

    test "navigates to other funds", %{conn: conn, funds: funds} do
      [fund1, fund2, _rest] = funds

      conn
      |> visit(~p"/funds/#{fund1}")
      |> click_link(fund2.name)
      |> assert_has(heading(), text: "#{fund2.icon} #{fund2.name}")
    end
  end
end
