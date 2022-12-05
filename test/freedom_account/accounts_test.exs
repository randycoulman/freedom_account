defmodule FreedomAccount.AccountsTest do
  @moduledoc false

  use FreedomAccount.DataCase, async: true

  alias FreedomAccount.Accounts
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Factory

  @invalid_attrs %{deposits_per_year: nil, name: nil}

  describe "creating an account" do
    test "creates an account with valid data" do
      valid_attrs = Factory.account_attrs()

      assert {:ok, %Account{} = account} = Accounts.create_account(valid_attrs)
      assert account.deposits_per_year == valid_attrs[:deposits_per_year]
      assert account.name == valid_attrs[:name]
    end

    test "returns error changeset for invalid data" do
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
      update_attrs = Factory.account_attrs()

      assert {:ok, %Account{} = account} = Accounts.update_account(account, update_attrs)
      assert account.deposits_per_year == update_attrs[:deposits_per_year]
      assert account.name == update_attrs[:name]
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
