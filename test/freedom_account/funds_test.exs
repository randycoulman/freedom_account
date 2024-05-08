defmodule FreedomAccount.FundsTest do
  @moduledoc false

  use FreedomAccount.DataCase, async: true

  alias FreedomAccount.Factory
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund

  @invalid_attrs %{icon: nil, name: nil}

  defp create_account(_context) do
    account = Factory.account()
    %{account: account}
  end

  setup [:create_account]

  describe "creating a changeset for a fund" do
    test "returns the changeset", %{account: account} do
      fund = Factory.fund(account)
      assert %Ecto.Changeset{} = Funds.change_fund(fund)
    end
  end

  describe "creating a fund" do
    test "creates a fund with valid data", %{account: account} do
      valid_attrs = Factory.fund_attrs()

      assert {:ok, %Fund{} = fund} = Funds.create_fund(account, valid_attrs)
      assert fund.icon == valid_attrs[:icon]
      assert fund.name == valid_attrs[:name]
    end

    test "associates the fund to its account", %{account: account} do
      valid_attrs = Factory.fund_attrs()

      {:ok, fund} = Funds.create_fund(account, valid_attrs)
      assert fund.account_id == account.id
    end

    test "returns error changeset for invalid data", %{account: account} do
      assert {:error, %Ecto.Changeset{}} = Funds.create_fund(account, @invalid_attrs)
    end
  end

  describe "deleting a fund" do
    test "deletes the fund", %{account: account} do
      fund = Factory.fund(account)
      assert :ok = Funds.delete_fund(fund)
      assert {:error, :not_found} == Funds.fetch_fund(account, fund.id)
    end
  end

  describe "fetching a fund" do
    test "when fund exists for the provided account, finds the fund by ID", %{account: account} do
      fund = Factory.fund(account)
      assert {:ok, fund} == Funds.fetch_fund(account, fund.id)
    end

    test "when fund exists for the provided account, include current balance (random, for now) when requested", %{
      account: account
    } do
      fund = Factory.fund(account)
      {:ok, fund} = Funds.fetch_fund_with_balance(account, fund.id)
      refute fund.current_balance == nil
    end

    test "when fund exists, but for a different account, returns an error", %{account: account} do
      other_account = Factory.account()
      fund = Factory.fund(other_account)

      assert {:error, :not_found} = Funds.fetch_fund(account, fund.id)
    end

    test "when fund does not exist, returns an error", %{account: account} do
      assert {:error, :not_found} = Funds.fetch_fund(account, Factory.id())
    end
  end

  describe "listing funds" do
    setup %{account: account} do
      funds = for _i <- 1..3, do: Factory.fund(account)

      %{funds: funds}
    end

    test "returns all funds", %{account: account, funds: funds} do
      sorted_funds = Enum.sort_by(funds, & &1.name)
      assert Funds.list_funds(account) == sorted_funds
    end

    test "includes current balance (random, for now) of each fund when requested", %{account: account} do
      for fund <- Funds.list_funds_with_balances(account) do
        refute fund.current_balance == nil
      end
    end
  end

  describe "updating a fund" do
    setup %{account: account} do
      [fund: Factory.fund(account)]
    end

    test "with valid data updates the fund", %{fund: fund} do
      valid_attrs = Factory.fund_attrs()

      assert {:ok, %Fund{} = fund} = Funds.update_fund(fund, valid_attrs)
      assert fund.icon == valid_attrs[:icon]
      assert fund.name == valid_attrs[:name]
    end

    test "with invalid data returns an error changeset", %{account: account, fund: fund} do
      assert {:error, %Ecto.Changeset{}} = Funds.update_fund(fund, @invalid_attrs)
      assert {:ok, fund} == Funds.fetch_fund(account, fund.id)
    end

    test "does not allow associating with a different account", %{account: original_account, fund: fund} do
      other_account = Factory.account()
      valid_attrs = Factory.fund_attrs(account_id: other_account.id)

      assert {:ok, %Fund{} = fund} = Funds.update_fund(fund, valid_attrs)
      assert fund.account_id == original_account.id
    end
  end
end
