defmodule FreedomAccountWeb.Hooks.LoadInitialData.CacheTest do
  use FreedomAccount.DataCase, async: false

  alias FreedomAccount.Factory
  alias FreedomAccount.Funds
  alias FreedomAccountWeb.Hooks.LoadInitialData.Cache

  setup [:create_account, :create_funds]

  describe "adding an element" do
    test "inserts element in sorted order", %{account: account, funds: funds} do
      fund = Factory.fund(account, name: "PPP")
      result = Cache.add(funds, fund)

      assert names(result) == ~w(AAA GGG MMM PPP UUU ZZZ)
    end
  end

  describe "deleting a fund" do
    test "deletes a fund", %{funds: funds} do
      fund = Enum.random(funds)
      result = Cache.delete(funds, fund)

      refute fund in result
    end

    test "deletes fund even if balance is different", %{funds: funds} do
      fund = Enum.random(funds)
      different_balance = %{fund | current_balance: Factory.money()}
      result = Cache.delete(funds, different_balance)

      refute fund in result
      refute different_balance in result
    end
  end

  describe "updating a fund" do
    test "when name doesn't change, updates fund in-place", %{funds: funds} do
      fund = Enum.random(funds)
      updated_fund = %{fund | icon: new_icon(fund.icon)}
      result = Cache.update(funds, updated_fund)

      assert updated_fund in result
      refute fund in result
    end

    test "when name changes, updated fund and moves to correct place", %{funds: funds} do
      fund = Enum.at(funds, 3)
      updated_fund = %{fund | name: "JJJ"}
      result = Cache.update(funds, updated_fund)

      assert names(result) == ~w(AAA GGG JJJ MMM ZZZ)
    end

    test "when updated fund doesn't have a balance, its previous balance is retained", %{funds: funds} do
      fund = Enum.random(funds)
      updated_fund = %{fund | current_balance: nil, icon: new_icon(fund.icon)}
      result = Cache.update(funds, updated_fund)

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

  describe "updating fund activations" do
    test "adds newly-active funds", %{account: account, funds: funds} do
      newly_active_fund = Factory.fund(account, current_balance: Money.zero(:usd), name: "SSS")

      result = Cache.update_activations(funds, [newly_active_fund])

      assert names(result) == ~w(AAA GGG MMM SSS UUU ZZZ)
    end

    test "ignores still-active funds", %{funds: funds} do
      still_active_fund = Enum.random(funds)

      result = Cache.update_activations(funds, [still_active_fund])

      assert result == funds
    end

    test "removes newly-inactive funds", %{funds: funds} do
      {:ok, newly_inactive_fund} =
        funds
        |> Enum.random()
        |> Factory.with_fund_balance(Money.zero(:usd))
        |> Funds.deactivate_fund()

      result = Cache.update_activations(funds, [newly_inactive_fund])

      refute newly_inactive_fund.name in names(result)
    end

    test "ignores still-inactive funds", %{account: account, funds: funds} do
      still_inactive_fund = Factory.inactive_fund(account, current_balance: Money.zero(:usd))

      result = Cache.update_activations(funds, [still_inactive_fund])

      assert result == funds
    end
  end

  describe "updating multiple funds" do
    test "updates all provided funds", %{funds: funds} do
      [fund1, fund2, fund3, fund4, fund5] = funds
      updated_fund2 = %{fund2 | budget: Factory.money()}
      updated_fund4 = %{fund4 | budget: Factory.money()}

      result = Cache.update_all(funds, [updated_fund2, updated_fund4])

      assert [fund1, updated_fund2, fund3, updated_fund4, fund5] == result
    end
  end

  defp create_funds(%{account: account}) do
    funds = for name <- ~w(AAA GGG MMM UUU ZZZ), do: Factory.fund(account, current_balance: Factory.money(), name: name)

    %{funds: funds}
  end

  defp names(funds), do: Enum.map(funds, & &1.name)
end
