defmodule FreedomAccount.FundsTest do
  use FreedomAccount.DataCase, async: true

  alias FreedomAccount.Funds

  describe "listing funds" do
    test "returns all funds for an account" do
      account = insert(:account)
      funds = insert_list(3, :fund, account: account)

      listed_funds = Funds.list_funds(account)

      assert fund_ids(funds) == fund_ids(listed_funds)
    end
  end

  defp fund_ids(funds) do
    funds |> Enum.map(& &1.id) |> Enum.sort()
  end
end
