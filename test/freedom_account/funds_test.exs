defmodule FreedomAccount.FundsTest do
  @moduledoc false

  use FreedomAccount.DataCase, async: true

  import Assertions
  import Money.Sigil

  alias Ecto.Changeset
  alias FreedomAccount.Factory
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.PubSub

  @invalid_attrs %{icon: nil, name: nil}

  setup [:create_account]

  describe "creating a changeset for the budget" do
    test "returns the changeset", %{account: account} do
      funds = for _i <- 1..3, do: Factory.fund(account)

      assert %Changeset{} = changeset = Funds.change_budget(funds)
      assert changeset |> Changeset.get_embed(:funds) |> length() == 3
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

    test "publishes a fund created event", %{account: account} do
      valid_attrs = Factory.fund_attrs()

      PubSub.subscribe(Funds.pubsub_topic())

      {:ok, fund} = Funds.create_fund(account, valid_attrs)

      assert_received({:fund_created, ^fund})
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

    test "publishes a fund deleted event", %{fund: fund} do
      fund_id = fund.id
      PubSub.subscribe(Funds.pubsub_topic())

      :ok = Funds.delete_fund(fund)

      assert_received({:fund_deleted, %Fund{id: ^fund_id}})
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
      funds = for _i <- 1..3, do: Factory.fund(account, current_balance: Money.zero(:usd))

      %{funds: funds}
    end

    test "returns all funds sorted by name", %{account: account, funds: funds} do
      sorted_funds = Enum.sort_by(funds, & &1.name)
      assert Funds.list_funds(account) == sorted_funds
    end

    test "includes current balance of each fund", %{account: account, funds: funds} do
      calculate_amount = &Money.mult!(~M[10.00]usd, &1.id)

      Enum.each(funds, fn fund ->
        Factory.deposit(fund, amount: calculate_amount.(fund))
      end)

      account
      |> Funds.list_funds()
      |> Enum.each(fn fund ->
        assert fund.current_balance == calculate_amount.(fund)
      end)
    end

    test "filters by a list of ids when provided", %{account: account, funds: funds} do
      [fund1, _fund2, fund3] = funds

      result = Funds.list_funds(account, [fund1.id, fund3.id])

      fields = Map.keys(fund1) -- [:current_balance]
      assert_lists_equal(result, [fund1, fund3], &assert_maps_equal(&1, &2, fields))
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

    test "publishes a budget updated event", %{account: account} do
      funds = for _n <- 1..3, do: Factory.fund(account)
      valid_attrs = Factory.budget_attrs(funds)

      PubSub.subscribe(Funds.pubsub_topic())

      {:ok, updated_funds} = Funds.update_budget(funds, valid_attrs)

      assert_received({:budget_updated, ^updated_funds})
    end

    test "with invalid data returns an error changeset", %{account: account} do
      funds = [
        Factory.fund(account, current_balance: Money.zero(:usd)),
        Factory.fund(account, current_balance: Money.zero(:usd))
      ]

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

    test "publishes a fund updated event", %{fund: fund} do
      valid_attrs = Factory.fund_attrs()

      PubSub.subscribe(Funds.pubsub_topic())

      {:ok, updated_fund} = Funds.update_fund(fund, valid_attrs)

      assert_received({:fund_updated, ^updated_fund})
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
