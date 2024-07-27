defmodule FreedomAccount.RepoTest do
  @moduledoc false

  use FreedomAccount.DataCase, async: true

  import Ecto.Query

  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Error.NotFoundError
  alias FreedomAccount.Factory

  @moduletag capture_log: true

  describe "mapping Ecto responses to ok/error tuples" do
    test "maps successful result to ok tuple" do
      account = Factory.account()

      assert Repo.fetch(Account, account.id) == {:ok, account}
    end

    test "maps unsuccessful result to error tuple" do
      id = Factory.id()

      assert Repo.fetch(Account, id) == {:error, %NotFoundError{details: %{id: id}, entity: Account}}
    end

    test "extracts entity from query" do
      name = Factory.account_name()
      query = from a in Account, where: [name: ^name]

      assert Repo.fetch_one(query) == {:error, %NotFoundError{details: %{}, entity: Account}}
    end
  end

  describe "fetching a single record" do
    test "maps successful result to ok tuple" do
      account = Factory.account()

      assert Repo.fetch_one(Account) == {:ok, account}
    end

    test "maps unsuccessful result to error tuple" do
      assert Repo.fetch_one(Account) == {:error, %NotFoundError{details: %{}, entity: Account}}
    end
  end
end
