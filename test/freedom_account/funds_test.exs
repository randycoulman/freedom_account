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

  describe "fetching a fund" do
    test "when fund exists, finds the fund by ID", %{account: account} do
      fund = Factory.fund(account)
      assert {:ok, fund} == Funds.fetch_fund(fund.id)
    end

    test "when fund does not exist, returns an error" do
      assert {:error, :not_found} = Funds.fetch_fund(Factory.id())
    end
  end

  describe "listing funds" do
    test "returns all funds", %{account: account} do
      funds = for _i <- 1..3, do: Factory.fund(account)
      assert Funds.list_funds(account) == funds
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

    test "with invalid data returns an error changeset", %{fund: fund} do
      assert {:error, %Ecto.Changeset{}} = Funds.update_fund(fund, @invalid_attrs)
      assert {:ok, fund} == Funds.fetch_fund(fund.id)
    end

    test "does not allow associating with a different account", %{account: original_account, fund: fund} do
      other_account = Factory.account()
      valid_attrs = Factory.fund_attrs(account_id: other_account.id)

      assert {:ok, %Fund{} = fund} = Funds.update_fund(fund, valid_attrs)
      assert fund.account_id == original_account.id
    end
  end

  # describe "funds" do

  #   import FreedomAccount.FundsFixtures

  #   test "delete_fund/1 deletes the fund" do
  #     fund = fund_fixture()
  #     assert {:ok, %Fund{}} = Funds.delete_fund(fund)
  #     assert_raise Ecto.NoResultsError, fn -> Funds.get_fund!(fund.id) end
  #   end
  # end
end
