defmodule FreedomAccountWeb.SchemaTest do
  use FreedomAccountWeb.ConnCase, async: true

  @account_query """
  query MyAccount {
    myAccount {
      funds {
        icon
        id
        name
      }
      id
      name
    }
  }
  """

  test "query: myAccount", %{conn: conn} do
    account = build(:account)
    funds = build_list(3, :fund)

    FreedomAccountMock
    |> stub(:my_account, fn -> {:ok, account} end)
    |> stub(:list_funds, fn ^account -> funds end)

    expected_funds =
      Enum.map(funds, fn fund ->
        %{
          "icon" => fund.icon,
          "id" => fund.id,
          "name" => fund.name
        }
      end)

    response =
      conn
      |> post("/api", %{query: @account_query})
      |> json_response(200)

    assert %{
             "data" => %{
               "myAccount" => %{
                 "funds" => expected_funds,
                 "id" => account.id,
                 "name" => account.name
               }
             }
           } == response
  end

  @update_account_mutation """
  mutation UpdateAccount($input: AccountInput!) {
    updateAccount(input: $input) {
      id
      name
    }
  }
  """

  test "mutation: updateAccount", %{conn: conn} do
    account = build(:account)
    name = "NEW NAME"
    updated_account = %{account | name: name}
    params = %{id: account.id, name: name}

    FreedomAccountMock
    |> expect(:update_account, fn ^params -> {:ok, updated_account} end)

    response =
      conn
      |> post("/api", %{
        query: @update_account_mutation,
        variables: %{input: params}
      })
      |> json_response(200)

    assert %{
             "data" => %{
               "updateAccount" => %{
                 "id" => account.id,
                 "name" => name
               }
             }
           } == response
  end
end
