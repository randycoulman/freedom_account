defmodule FreedomAccount.AccountsTest do
  @moduledoc false

  use FreedomAccount.DataCase, async: true

  alias FreedomAccount.Accounts
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Factory

  @invalid_attrs %{deposits_per_year: nil, name: nil}

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
      assert {:error, %Ecto.Changeset{}} = Accounts.create_account(@invalid_attrs)
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

  describe "updating an account's settings" do
    test "update_account/2 with valid data updates the account" do
      account = Factory.account()
      updated_deposits = Factory.deposit_count()
      updated_name = Factory.account_name()
      update_attrs = %{deposits_per_year: updated_deposits, name: updated_name}

      assert {:ok, %Account{} = account} = Accounts.update_account(account, update_attrs)
      assert account.deposits_per_year == updated_deposits
      assert account.name == updated_name
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = Factory.account()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_account(account, @invalid_attrs)
      assert account == Accounts.only_account()
    end
  end

  describe "creating a changeset for an account" do
    test "returns the changeset" do
      account = Factory.account()
      assert %Ecto.Changeset{} = Accounts.change_account(account)
    end
  end
end
