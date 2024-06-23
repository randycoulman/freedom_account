defmodule FreedomAccount.FundsTest do
  @moduledoc false

  use FreedomAccount.DataCase, async: true

  import Assertions
  import Money.Sigil

  alias Ecto.Changeset
  alias FreedomAccount.Factory
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund

  @invalid_attrs %{icon: nil, name: nil}

  setup [:create_account]

  describe "creating a changeset for the budget" do
    test "returns the changeset", %{account: account} do
      funds = for _i <- 1..3, do: Factory.fund(account)

      assert %Changeset{} = changeset = Funds.change_budget(funds)
      assert changeset |> get_embed(:funds) |> length() == 3
    end
  end

  describe "creating a changeset for a fund" do
    test "returns the changeset", %{account: account} do
      fund = Factory.fund(account)
      assert %Changeset{} = Funds.change_fund(fund)
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
      assert {:error, %Changeset{valid?: false}} = Funds.create_fund(account, @invalid_attrs)
    end
  end

  describe "deleting a fund" do
    setup :create_fund

    test "deletes the fund", %{account: account, fund: fund} do
      assert :ok = Funds.delete_fund(fund)
      assert {:error, :not_found} == Funds.fetch_fund(account, fund.id)
    end

    test "disallows delete a fund with line items", %{fund: fund} do
      Factory.deposit(fund)
      assert {:error, :fund_has_transactions} = Funds.delete_fund(fund)
    end
  end

  describe "fetching a fund" do
    test "when fund exists for the provided account, finds the fund by ID", %{account: account} do
      fund = Factory.fund(account)
      assert {:ok, fund} == Funds.fetch_fund(account, fund.id)
    end

    test "when fund exists for the provided account, include current balance when requested", %{
      account: account
    } do
      fund = Factory.fund(account)

      Enum.each(
        [~M[9.95]usd, ~M[5.05]usd, ~M[27.00]usd],
        &Factory.deposit(fund, amount: &1)
      )

      {:ok, fund} = Funds.fetch_fund_with_balance(account, fund.id)
      assert fund.current_balance == ~M[42.00]usd
    end

    test "returns zero balance when fund has no line items", %{account: account} do
      fund = Factory.fund(account)

      {:ok, fund} = Funds.fetch_fund_with_balance(account, fund.id)
      assert fund.current_balance == Money.zero(:usd)
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

    test "includes current balance of each fund when requested", %{account: account, funds: funds} do
      calculate_amount = &Money.mult!(~M[10.00]usd, &1.id)

      Enum.each(funds, fn fund ->
        Factory.deposit(fund, amount: calculate_amount.(fund))
      end)

      account
      |> Funds.list_funds_with_balances()
      |> Enum.each(fn fund ->
        assert fund.current_balance == calculate_amount.(fund)
      end)
    end
  end

  describe "updating the budget" do
    test "saves budget values for all funds", %{account: account} do
      funds = for _n <- 1..3, do: Factory.fund(account)
      valid_attrs = Factory.budget_attrs(funds)

      assert {:ok, updated_funds} = Funds.update_budget(funds, valid_attrs)

      valid_attrs.funds
      |> Enum.zip(updated_funds)
      |> Enum.each(fn {{_index, attrs}, fund} ->
        assert fund.budget == attrs[:budget]
        assert fund.times_per_year == attrs[:times_per_year]
      end)
    end

    test "with invalid data returns an error changeset", %{account: account} do
      funds = [Factory.fund(account), Factory.fund(account)]

      invalid_attrs =
        funds
        |> Factory.budget_attrs()
        |> update_in([:funds, "1"], &Map.put(&1, :budget, nil))

      assert {:error, %Changeset{valid?: false} = changeset} = Funds.update_budget(funds, invalid_attrs)
      assert [%Changeset{valid?: true}, %Changeset{valid?: false}] = Changeset.get_embed(changeset, :funds)
      assert_lists_equal(funds, Funds.list_funds(account))
    end
  end

  describe "updating a fund" do
    setup :create_fund

    test "with valid data updates the fund", %{fund: fund} do
      valid_attrs = Factory.fund_attrs()

      assert {:ok, %Fund{} = fund} = Funds.update_fund(fund, valid_attrs)
      assert fund.icon == valid_attrs[:icon]
      assert fund.name == valid_attrs[:name]
    end

    test "with invalid data returns an error changeset", %{account: account, fund: fund} do
      assert {:error, %Changeset{valid?: false}} = Funds.update_fund(fund, @invalid_attrs)
      assert {:ok, fund} == Funds.fetch_fund(account, fund.id)
    end

    test "does not allow associating with a different account", %{account: original_account, fund: fund} do
      other_account = Factory.account()
      valid_attrs = Factory.fund_attrs(account_id: other_account.id)

      assert {:ok, %Fund{} = fund} = Funds.update_fund(fund, valid_attrs)
      assert fund.account_id == original_account.id
    end
  end

  describe "updating a fund's balance" do
    setup :create_fund

    test "returns the fund with it's latest current balance", %{fund: fund} do
      amount = Factory.money()
      Factory.deposit(fund, amount: amount)

      assert {:ok, %Fund{current_balance: ^amount}} = Funds.with_updated_balance(fund)
    end
  end
end
