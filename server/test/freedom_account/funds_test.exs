defmodule FreedomAccount.FundsTest do
  use FreedomAccount.DataCase, async: true

  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund

  describe "creating a fund" do
    setup do
      account = insert(:account)
      params = params_for(:fund)

      ~M{account, params}
    end

    test "returns the created fund", ~M{account, params} do
      ~M{icon, name} = params

      assert {:ok, %Fund{icon: ^icon, name: ^name}} = Funds.create_fund(account, params)
    end

    test "associates the fund to its account", ~M{account, params} do
      {:ok, fund} = Funds.create_fund(account, params)
      assert fund.account_id == account.id
    end

    test "uses provided ID", ~M{account, params} do
      id = generate_id()
      params = Map.put(params, :id, id)

      {:ok, fund} = Funds.create_fund(account, params)
      assert fund.id == id
    end

    test "returns a changeset error if the icon is missing", ~M{account, params} do
      params = Map.put(params, :icon, "")

      assert {:error, changeset} = Funds.create_fund(account, params)

      assert "can't be blank" in errors_on(changeset).icon
    end

    test "returns a changeset error if the name is blank", ~M{account, params} do
      params = Map.put(params, :name, "")

      assert {:error, changeset} = Funds.create_fund(account, params)

      assert "can't be blank" in errors_on(changeset).name
    end
  end

  describe "listing funds" do
    test "returns all funds for an account" do
      account = insert(:account)
      funds = insert_list(3, :fund, account: account)

      listed_funds = Funds.list_funds(account)

      assert fund_ids(funds) == fund_ids(listed_funds)
    end
  end

  defp fund_ids(funds) do
    funds |> Enum.map(& &1.id) |> Enum.sort()
  end
end
