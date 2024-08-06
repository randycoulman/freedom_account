defmodule FreedomAccount.FundsTest do
  @moduledoc false

  use FreedomAccount.DataCase, async: true

  import Assertions
  import Money.Sigil

  alias Ecto.Changeset
  alias FreedomAccount.Error.NotAllowedError
  alias FreedomAccount.Error.NotFoundError
  alias FreedomAccount.Factory
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.PubSub

  @moduletag capture_log: true

  @invalid_attrs %{icon: nil, name: nil}

  setup [:create_account]

  describe "creating a changeset for activating/deactivating funds" do
    test "returns a changeset for all inactive funds plus active funds with a zero balance", %{account: account} do
      _funds = [
        Factory.fund(account, name: "Can Deactivate", current_balance: Money.zero(:usd)),
        Factory.inactive_fund(account, name: "Inactive", current_balance: Money.zero(:usd)),
        account |> Factory.fund(name: "Has Non-Zero Balance") |> Factory.with_fund_balance(~M[150]usd),
        Factory.fund(account, name: "To Deactivate", current_balance: Money.zero(:usd))
      ]

      assert %Changeset{} = changeset = Funds.change_activation(account)
      embedded_funds = Changeset.get_embed(changeset, :funds)

      names = Enum.map(embedded_funds, &Changeset.get_field(&1, :name))

      assert_lists_equal(names, ["Can Deactivate", "Inactive", "To Deactivate"])
    end
  end

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

    test "marks the fund as active", %{account: account} do
      valid_attrs = Factory.fund_attrs()

      {:ok, fund} = Funds.create_fund(account, valid_attrs)
      assert fund.active
    end

    test "publishes a fund created event", %{account: account} do
      valid_attrs = Factory.fund_attrs()

      :ok = PubSub.subscribe(Funds.pubsub_topic())

      {:ok, fund} = Funds.create_fund(account, valid_attrs)

      assert_received({:fund_created, ^fund})
    end

    test "returns error changeset for invalid data", %{account: account} do
      assert {:error, %Changeset{valid?: false}} = Funds.create_fund(account, @invalid_attrs)
    end
  end

  describe "deactivating a fund" do
    test "marks the fund as inactive", %{account: account} do
      fund = Factory.fund(account, current_balance: Money.zero(:usd))

      assert {:ok, %Fund{} = updated_fund} = Funds.deactivate_fund(fund)

      refute updated_fund.active
    end

    test "returns error if fund cannot be deactivated", %{account: account} do
      fund = account |> Factory.fund() |> Factory.with_fund_balance()

      assert {:error, %NotAllowedError{}} = Funds.deactivate_fund(fund)
    end
  end

  describe "deleting a fund" do
    setup :create_fund

    test "deletes the fund", %{account: account, fund: fund} do
      assert :ok = Funds.delete_fund(fund)
      assert {:error, %NotFoundError{}} = Funds.fetch_active_fund(account, fund.id)
    end

    test "publishes a fund deleted event", %{fund: fund} do
      fund_id = fund.id
      :ok = PubSub.subscribe(Funds.pubsub_topic())

      :ok = Funds.delete_fund(fund)

      assert_received({:fund_deleted, %Fund{id: ^fund_id}})
    end

    @tag capture_log: true
    test "disallows delete a fund with line items", %{fund: fund} do
      Factory.deposit(fund)
      assert {:error, %NotAllowedError{}} = Funds.delete_fund(fund)
    end
  end

  describe "fetching a fund" do
    test "when fund exists for the provided account, finds the fund by ID", %{account: account} do
      fund = Factory.fund(account)
      assert {:ok, fund} == Funds.fetch_active_fund(account, fund.id)
    end

    test "when fund is inactive, returns an error", %{account: account} do
      fund = Factory.inactive_fund(account)
      assert {:error, %NotFoundError{}} = Funds.fetch_active_fund(account, fund.id)
    end

    test "when fund exists, but for a different account, returns an error", %{account: account} do
      other_account = Factory.account()
      fund = Factory.fund(other_account)

      assert {:error, %NotFoundError{}} = Funds.fetch_active_fund(account, fund.id)
    end

    test "when fund does not exist, returns an error", %{account: account} do
      assert {:error, %NotFoundError{}} = Funds.fetch_active_fund(account, Factory.id())
    end
  end

  describe "listing active funds" do
    setup %{account: account} do
      funds = for _i <- 1..3, do: Factory.fund(account, current_balance: Money.zero(:usd))

      %{funds: funds}
    end

    test "returns all active funds sorted by name", %{account: account, funds: funds} do
      sorted_funds = Enum.sort_by(funds, & &1.name)
      assert Funds.list_active_funds(account) == sorted_funds
    end

    test "includes current balance of each fund", %{account: account, funds: funds} do
      calculate_amount = &Money.mult!(~M[10.00]usd, &1.id)

      Enum.each(funds, fn fund ->
        Factory.deposit(fund, amount: calculate_amount.(fund))
      end)

      account
      |> Funds.list_active_funds()
      |> Enum.each(fn fund ->
        assert fund.current_balance == calculate_amount.(fund)
      end)
    end

    test "filters by a list of ids when provided", %{account: account, funds: funds} do
      [fund1, _fund2, fund3] = funds

      result = Funds.list_active_funds(account, [fund1.id, fund3.id])

      fields = Map.keys(fund1) -- [:current_balance]
      assert_lists_equal(result, [fund1, fund3], &assert_maps_equal(&1, &2, fields))
    end

    test "does not include inactive funds", %{account: account, funds: active_funds} do
      _inactive_fund = Factory.inactive_fund(account)

      assert_lists_equal(Funds.list_active_funds(account), active_funds)
    end
  end

  describe "listing all funds" do
    setup %{account: account} do
      funds = for _i <- 1..3, do: Factory.fund(account, current_balance: Money.zero(:usd))

      %{funds: [Factory.inactive_fund(account, current_balance: Money.zero(:usd)) | funds]}
    end

    test "returns all funds (both active and inactive) sorted by name", %{account: account, funds: funds} do
      sorted_funds = Enum.sort_by(funds, & &1.name)
      assert Funds.list_all_funds(account) == sorted_funds
    end

    test "includes current balance of each fund", %{account: account, funds: funds} do
      calculate_amount = &Money.mult!(~M[10.00]usd, &1.id)

      Enum.each(funds, fn fund ->
        Factory.deposit(fund, amount: calculate_amount.(fund))
      end)

      account
      |> Funds.list_all_funds()
      |> Enum.each(fn fund ->
        assert fund.current_balance == calculate_amount.(fund)
      end)
    end
  end

  describe "regular deposit amount" do
    for {budget, times, periods, expected} <- [
          {~M[1200]usd, 1.0, 24, ~M[50]usd},
          {~M[1200]usd, 2.0, 24, ~M[100]usd},
          {~M[5200]usd, 0.5, 26, ~M[100]usd},
          {~M[5200]usd, 1.0, 24, ~M[216.67]usd},
          {~M[1200]usd, 1.0, 26, ~M[46.15]usd}
        ] do
      test "calculates amount for #{budget} #{times}/year given #{periods} pay periods", %{account: account} do
        budget = unquote(Macro.escape(budget))
        times = unquote(times)
        periods = unquote(periods)
        expected = unquote(Macro.escape(expected))
        fund = Factory.fund(account, budget: budget, times_per_year: times)

        actual = Funds.regular_deposit_amount(fund, periods)

        assert Money.equal?(expected, actual)
      end
    end
  end

  describe "updating fund activation" do
    test "saves active flag for all funds", %{account: account} do
      funds = [
        Factory.fund(account),
        Factory.inactive_fund(account),
        Factory.fund(account)
      ]

      valid_attrs = Factory.funds_activation_attrs(funds)

      assert {:ok, updated_funds} = Funds.update_activation(account, valid_attrs)

      valid_attrs.funds
      |> Enum.zip(updated_funds)
      |> Enum.each(fn {{_index, attrs}, fund} ->
        assert fund.active == attrs[:active]
      end)
    end

    test "publishes an activation updated event", %{account: account} do
      funds = [
        Factory.fund(account),
        Factory.inactive_fund(account),
        Factory.fund(account)
      ]

      valid_attrs = Factory.budget_attrs(funds)

      :ok = PubSub.subscribe(Funds.pubsub_topic())

      {:ok, updated_funds} = Funds.update_activation(account, valid_attrs)

      assert_received({:fund_activation_updated, ^updated_funds})
    end

    test "with invalid data returns an error changeset", %{account: account} do
      funds = [
        Factory.fund(account, current_balance: Money.zero(:usd)),
        Factory.inactive_fund(account, current_balance: Money.zero(:usd))
      ]

      invalid_attrs =
        funds
        |> Factory.funds_activation_attrs()
        |> update_in([:funds, "1"], &Map.put(&1, :active, nil))

      assert {:error, %Changeset{valid?: false} = changeset} = Funds.update_activation(account, invalid_attrs)
      assert [%Changeset{valid?: true}, %Changeset{valid?: false}] = Changeset.get_embed(changeset, :funds)
      assert_lists_equal(funds, Funds.list_all_funds(account))
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

      :ok = PubSub.subscribe(Funds.pubsub_topic())

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
      assert_lists_equal(funds, Funds.list_active_funds(account))
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

      :ok = PubSub.subscribe(Funds.pubsub_topic())

      {:ok, updated_fund} = Funds.update_fund(fund, valid_attrs)

      assert_received({:fund_updated, ^updated_fund})
    end

    test "with invalid data returns an error changeset", %{account: account, fund: fund} do
      assert {:error, %Changeset{valid?: false}} = Funds.update_fund(fund, @invalid_attrs)
      assert {:ok, fund} == Funds.fetch_active_fund(account, fund.id)
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
