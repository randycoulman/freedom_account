defmodule FreedomAccount.AccountsTest do
  use FreedomAccount.DataCase, async: true

  alias FreedomAccount.Accounts
  alias FreedomAccount.Accounts.Account

  describe "retrieving the account for a user" do
    setup do
      %{user: insert(:user)}
    end

    test "returns the user's single account if present", %{user: user} do
      other_user = insert(:user)
      account = insert(:account, user: user)
      _other_account = insert(:account, user: other_user)

      assert {:ok, found} = Accounts.account_for_user(user)
      assert_structs_equal(account, found, [:deposits_per_year, :id, :name])
    end

    test "returns error tuple if no account", %{user: user} do
      assert {:error, :not_found} = Accounts.account_for_user(user)
    end

    test "raises if more than one account", %{user: user} do
      insert_list(2, :account, user: user)

      assert_raise Ecto.MultipleResultsError, fn ->
        Accounts.account_for_user(user)
      end
    end
  end

  describe "retrieving the only account" do
    test "returns the single account if present" do
      account = insert(:account)

      assert {:ok, found} = Accounts.only_account()
      assert_structs_equal(account, found, [:deposits_per_year, :id, :name])
    end

    test "returns error tuple if no account" do
      assert {:error, :not_found} = Accounts.only_account()
    end

    test "raises if more than one account" do
      insert_list(2, :account)

      assert_raise Ecto.MultipleResultsError, fn ->
        Accounts.only_account()
      end
    end
  end

  describe "updating account settings" do
    test "returns the updated account" do
      account = insert(:account)
      account_id = account.id
      name = "NEW NAME"
      params = %{id: account_id, name: name}

      assert {:ok,
              %Account{
                id: ^account_id,
                name: ^name
              }} = Accounts.update_account(params)
    end

    test "returns not found error if no matching account" do
      params = %{id: Ecto.UUID.generate(), name: "NEW NAME"}

      assert {:error, :not_found} = Accounts.update_account(params)
    end

    test "returns changeset error if name is blank" do
      account = insert(:account)
      params = %{id: account.id, name: ""}

      assert {:error, changeset} = Accounts.update_account(params)

      assert "can't be blank" in errors_on(changeset).name
    end
  end
end
