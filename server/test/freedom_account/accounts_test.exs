defmodule FreedomAccount.AccountsTest do
  use FreedomAccount.DataCase, async: true

  alias FreedomAccount.Accounts
  alias FreedomAccount.Accounts.Account

  describe "retrieving the account for a user" do
    setup do
      user = insert(:user)
      ~M{user}
    end

    test "returns the user's single account if present", ~M{user} do
      other_user = insert(:user)
      account = insert(:account, user: user)
      _other_account = insert(:account, user: other_user)

      assert {:ok, found} = Accounts.account_for_user(user)
      assert_structs_equal(account, found, [:deposits_per_year, :id, :name])
    end

    test "returns error tuple if no account", ~M{user} do
      assert {:error, :not_found} = Accounts.account_for_user(user)
    end

    test "raises if more than one account", ~M{user} do
      insert_list(2, :account, user: user)

      assert_raise Ecto.MultipleResultsError, fn ->
        Accounts.account_for_user(user)
      end
    end
  end

  describe "finding an account by id" do
    test "returns the account when present" do
      account = insert(:account)
      _other_account = insert(:account)

      assert {:ok, found} = Accounts.find_account(account.id)
      assert_structs_equal(account, found, [:deposits_per_year, :id, :name])
    end

    test "returns not found error when missing" do
      assert {:error, :not_found} = Accounts.find_account(generate_id())
    end
  end

  describe "updating account settings" do
    test "returns the updated account" do
      account = insert(:account)
      account_id = account.id
      name = "NEW NAME"
      params = ~M{id: account_id, name}

      assert {:ok,
              %Account{
                id: ^account_id,
                name: ^name
              }} = Accounts.update_account(params)
    end

    test "returns not found error if no matching account" do
      params = %{id: generate_id(), name: "NEW NAME"}

      assert {:error, :not_found} = Accounts.update_account(params)
    end

    test "returns changeset error if name is blank" do
      account = insert(:account)
      params = %{id: account.id, name: ""}

      assert {:error, changeset} = Accounts.update_account(params)

      assert "can't be blank" in errors_on(changeset).name
    end
  end

  describe "resetting an account" do
    test "deletes and recreates the user's account and funds" do
      user = insert(:user)
      account = insert(:account, user: user)
      funds = insert_list(2, :fund, account: account)

      assert :ok = Accounts.reset_account(account)

      assert Repo.reload(account) == nil
      refute Repo.reload(funds) |> Enum.any?()

      assert {:ok, new_account} = Accounts.account_for_user(user)
      new_funds = Ecto.assoc(new_account, :funds) |> Repo.all()

      assert new_account.name == "Initial Account"

      new_funds
      |> Enum.map(& &1.name)
      |> assert_lists_equal(["Home Repairs", "Car Repairs", "Property Taxes"])
    end
  end
end
