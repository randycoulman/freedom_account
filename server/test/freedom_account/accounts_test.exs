defmodule FreedomAccount.AccountsTest do
  use FreedomAccount.DataCase, async: true

  alias FreedomAccount.Accounts

  describe "retrieving the only account" do
    test "returns the single account if present" do
      account = insert(:account)

      assert {:ok, ^account} = Accounts.only_account()
    end

    test "returns error tuple if no account" do
      assert {:error, :not_found} = Accounts.only_account()
    end

    test "returns error tuple if more than one account" do
      insert_list(2, :account)

      assert_raise Ecto.MultipleResultsError, fn ->
        Accounts.only_account()
      end
    end
  end
end
