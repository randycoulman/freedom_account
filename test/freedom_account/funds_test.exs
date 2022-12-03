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

  describe "creating a fund" do
    setup [:create_account]

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

  describe "listing funds" do
    setup [:create_account]

    test "returns all funds", %{account: account} do
      funds = for _i <- 1..3, do: Factory.fund(account)
      assert Funds.list_funds(account) == funds
    end
  end

  # describe "funds" do

  #   import FreedomAccount.FundsFixtures

  #   test "get_fund!/1 returns the fund with given id" do
  #     fund = fund_fixture()
  #     assert Funds.get_fund!(fund.id) == fund
  #   end

  #   test "update_fund/2 with valid data updates the fund" do
  #     fund = fund_fixture()
  #     update_attrs = %{icon: "some updated icon", name: "some updated name"}

  #     assert {:ok, %Fund{} = fund} = Funds.update_fund(fund, update_attrs)
  #     assert fund.icon == "some updated icon"
  #     assert fund.name == "some updated name"
  #   end

  #   test "update_fund/2 with invalid data returns error changeset" do
  #     fund = fund_fixture()
  #     assert {:error, %Ecto.Changeset{}} = Funds.update_fund(fund, @invalid_attrs)
  #     assert fund == Funds.get_fund!(fund.id)
  #   end

  #   test "delete_fund/1 deletes the fund" do
  #     fund = fund_fixture()
  #     assert {:ok, %Fund{}} = Funds.delete_fund(fund)
  #     assert_raise Ecto.NoResultsError, fn -> Funds.get_fund!(fund.id) end
  #   end

  #   test "change_fund/1 returns a fund changeset" do
  #     fund = fund_fixture()
  #     assert %Ecto.Changeset{} = Funds.change_fund(fund)
  #   end
  # end
end
