defmodule FreedomAccountWeb.Hooks.LoadInitialData.FundCacheTest do
  use FreedomAccount.DataCase, async: false

  alias FreedomAccount.Factory
  alias FreedomAccountWeb.Hooks.LoadInitialData.FundCache

  setup [:create_account, :create_funds]

  describe "adding a fund" do
    test "inserts fund in sorted order", %{account: account, funds: funds} do
      fund = Factory.fund(account, name: "PPP")
      result = FundCache.add_fund(funds, fund)

      assert names(result) == ~w(AAA GGG MMM PPP UUU ZZZ)
    end
  end

  describe "deleting a fund" do
    test "deletes a fund", %{funds: funds} do
      fund = Enum.random(funds)
      result = FundCache.delete_fund(funds, fund)

      refute fund in result
    end

    test "deletes fund even if balance is different", %{funds: funds} do
      fund = Enum.random(funds)
      different_balance = %{fund | current_balance: Factory.money()}
      result = FundCache.delete_fund(funds, different_balance)

      refute fund in result
      refute different_balance in result
    end
  end

  describe "updating a fund" do
    test "when name doesn't change, updates fund in-place", %{funds: funds} do
      fund = Enum.random(funds)
      updated_fund = %{fund | icon: new_icon(fund.icon)}
      result = FundCache.update_fund(funds, updated_fund)

      assert updated_fund in result
      refute fund in result
    end

    test "when name changes, updated fund and moves to correct place", %{funds: funds} do
      fund = Enum.at(funds, 3)
      updated_fund = %{fund | name: "JJJ"}
      result = FundCache.update_fund(funds, updated_fund)

      assert names(result) == ~w(AAA GGG JJJ MMM ZZZ)
    end

    test "when updated fund doesn't have a balance, its previous balance is retained", %{funds: funds} do
      fund = Enum.random(funds)
      updated_fund = %{fund | current_balance: nil, icon: new_icon(fund.icon)}
      result = FundCache.update_fund(funds, updated_fund)

      expected = %{updated_fund | current_balance: fund.current_balance}

      assert expected in result
      refute fund in result
      refute updated_fund in result
    end

    # We were seeing spurious test failures when the new icon was the same as
    # the previous one. This guarantees that we'll always get a new icon.
    defp new_icon(original_icon) do
      case Factory.fund_icon() do
        ^original_icon -> new_icon(original_icon)
        icon -> icon
      end
    end
  end

  describe "updating multiple funds" do
    test "updates all provided funds", %{funds: funds} do
      [fund1, fund2, fund3, fund4, fund5] = funds
      updated_fund2 = %{fund2 | budget: Factory.money()}
      updated_fund4 = %{fund4 | budget: Factory.money()}

      result = FundCache.update_all(funds, [updated_fund2, updated_fund4])

      assert [fund1, updated_fund2, fund3, updated_fund4, fund5] == result
    end
  end

  # Update all funds - use for budget
  # Convert transaction updates to use PubSub/FundCache

  defp create_funds(%{account: account}) do
    funds = for name <- ~w(AAA GGG MMM UUU ZZZ), do: Factory.fund(account, current_balance: Factory.money(), name: name)

    %{funds: funds}
  end

  defp names(funds), do: Enum.map(funds, & &1.name)
end
