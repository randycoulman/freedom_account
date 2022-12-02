defmodule FreedomAccount.AccountsTest do
  @moduledoc false

  use FreedomAccount.DataCase, async: true

  alias FreedomAccount.Accounts
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Factory

  describe "creating an account" do
    test "creates an account with valid data" do
      deposits = Factory.deposit_count()
      name = Factory.account_name()
      valid_attrs = %{deposits_per_year: deposits, name: name}

      assert {:ok,
              %Account{
                deposits_per_year: ^deposits,
                name: ^name
              }} = Accounts.create_account(valid_attrs)
    end

    test "create_account/1 with invalid data returns error changeset" do
      invalid_attrs = %{deposits_per_year: nil, name: nil}
      assert {:error, %Ecto.Changeset{}} = Accounts.create_account(invalid_attrs)
    end
  end

  describe "retrieving the only account" do
    test "returns the single account if present" do
      account = Factory.account()

      assert Accounts.only_account() == account
    end

    test "creates a new account if missing" do
      assert %Account{
               deposits_per_year: 24,
               name: "Initial Account"
             } = Accounts.only_account()
    end
  end

  # describe "accounts" do
  #   alias FreedomAccount.Accounts.Account

  #   import FreedomAccount.AccountsFixtures

  #   @invalid_attrs %{deposits_per_year: nil, name: nil}

  #   test "list_accounts/0 returns all accounts" do
  #     account = account_fixture()
  #     assert Accounts.list_accounts() == [account]
  #   end

  #   test "get_account!/1 returns the account with given id" do
  #     account = account_fixture()
  #     assert Accounts.get_account!(account.id) == account
  #   end

  #   test "create_account/1 with valid data creates a account" do
  #     valid_attrs = %{deposits_per_year: 42, name: "some name"}

  #     assert {:ok, %Account{} = account} = Accounts.create_account(valid_attrs)
  #     assert account.deposits_per_year == 42
  #     assert account.name == "some name"
  #   end

  #   test "create_account/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} = Accounts.create_account(@invalid_attrs)
  #   end

  #   test "update_account/2 with valid data updates the account" do
  #     account = account_fixture()
  #     update_attrs = %{deposits_per_year: 43, name: "some updated name"}

  #     assert {:ok, %Account{} = account} = Accounts.update_account(account, update_attrs)
  #     assert account.deposits_per_year == 43
  #     assert account.name == "some updated name"
  #   end

  #   test "update_account/2 with invalid data returns error changeset" do
  #     account = account_fixture()
  #     assert {:error, %Ecto.Changeset{}} = Accounts.update_account(account, @invalid_attrs)
  #     assert account == Accounts.get_account!(account.id)
  #   end

  #   test "delete_account/1 deletes the account" do
  #     account = account_fixture()
  #     assert {:ok, %Account{}} = Accounts.delete_account(account)
  #     assert_raise Ecto.NoResultsError, fn -> Accounts.get_account!(account.id) end
  #   end

  #   test "change_account/1 returns a account changeset" do
  #     account = account_fixture()
  #     assert %Ecto.Changeset{} = Accounts.change_account(account)
  #   end
  # end
end
