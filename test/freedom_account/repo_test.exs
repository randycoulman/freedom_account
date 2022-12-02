defmodule FreedomAccount.RepoTest do
  @moduledoc false

  use FreedomAccount.DataCase, async: true

  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Factory

  describe "fetching a single record" do
    test "maps successful result to ok tuple" do
      account = Factory.account()

      assert Repo.fetch_one(Account) == {:ok, account}
    end

    test "maps unsuccessful result to error tuple" do
      assert Repo.fetch_one(Account) == {:error, :not_found}
    end
  end
end
