defmodule FreedomAccountTest do
  use FreedomAccount.DataCase, async: true

  defmodule Impl do
    use Hammox.Protect, behaviour: FreedomAccount, module: FreedomAccount.Impl
  end

  describe "resetting the test account" do
    test "deletes and recreates the test user's account" do
      user = insert(:user, name: "cypress")
      account = insert(:account, user: user)
      funds = insert_list(2, :fund, account: account)

      assert :ok = Impl.reset_test_account()

      assert Repo.reload!(user) == user
      assert Repo.reload(account) == nil
      refute Repo.reload(funds) |> Enum.any?()

      assert {:ok, new_account} = Impl.my_account(user)
      new_funds = Impl.list_funds(new_account)
      assert length(new_funds) == 3
    end
  end
end
