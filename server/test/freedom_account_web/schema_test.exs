defmodule FreedomAccountWeb.SchemaTest do
  use FreedomAccountWeb.ConnCase, async: true

  @account_query """
  query MyAccount {
    myAccount {
      depositsPerYear
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
                 "depositsPerYear" => account.deposits_per_year,
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
      depositsPerYear
      id
      name
    }
  }
  """

  test "mutation: updateAccount", %{conn: conn} do
    account = build(:account)
    deposits_per_year = 26
    name = "NEW NAME"
    updated_account = %{account | deposits_per_year: deposits_per_year, name: name}
    params = %{deposits_per_year: deposits_per_year, id: account.id, name: name}

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
                 "depositsPerYear" => deposits_per_year,
                 "id" => account.id,
                 "name" => name
               }
             }
           } == response
  end
end
